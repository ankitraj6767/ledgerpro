import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_lock_service.dart';

/// Provides the single [AppSessionController] instance to the widget tree.
///
/// This is overridden in `main()` with the instance that is created and
/// initialized before `runApp`, so it is always available synchronously.
final appSessionControllerProvider = Provider<AppSessionController>((ref) {
  throw UnimplementedError(
    'appSessionControllerProvider must be overridden in main()',
  );
});

/// Central source of truth for "is the user signed in" and "is the local
/// app-lock gate currently open".
///
/// Responsibilities:
/// - Track the Supabase auth session (persisted + auto-refreshed by
///   supabase_flutter) and expose it synchronously to the router guard.
/// - Track the local lock state (PIN / biometric) so a returning user with a
///   still-valid session only needs to unlock, not perform a full login.
/// - Auto-lock the app when it has been closed/backgrounded longer than the
///   session window ([_sessionValidity]).
///
/// It is a [ChangeNotifier] so it can drive GoRouter's `refreshListenable`.
class AppSessionController extends ChangeNotifier with WidgetsBindingObserver {
  AppSessionController({AppLockService? lockService})
    : _lock = lockService ?? AppLockService();

  final AppLockService _lock;

  StreamSubscription<AuthState>? _authSub;
  bool _initialized = false;
  bool _hasPin = false;
  bool _unlocked = false;
  bool _demoMode = false;
  bool _validatingWorkspace = false;
  DateTime? _backgroundedAt;

  /// How long a successful unlock stays valid. A returning user is only asked
  /// for their PIN again once the app has been closed/backgrounded for longer
  /// than this window, instead of on every launch.
  static const _sessionValidity = Duration(days: 1);

  AppLockService get lockService => _lock;

  /// Whether a Supabase session currently exists (persisted across restarts).
  bool get isAuthenticated {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  /// Whether a local unlock PIN has been configured.
  bool get hasPin => _hasPin;

  /// Whether the local app-lock gate is currently open.
  bool get isUnlocked => _unlocked;

  /// Whether the user is browsing the offline demo workspace.
  bool get isDemoMode => _demoMode;

  bool get isInitialized => _initialized;

  /// Loads persisted lock state and wires up auth + lifecycle listeners.
  /// Must be awaited before the first frame so the router guard has correct
  /// data immediately.
  Future<void> initialize() async {
    if (_initialized) return;

    WidgetsBinding.instance.addObserver(this);

    // Secure-storage / keychain reads run over a platform channel that can
    // intermittently stall (notably flutter_secure_storage on some Android
    // keystore states). Bound them so a stalled read can never block the
    // first frame; on failure we treat the device as having no PIN, which
    // routes the user to set one rather than leaving a blank launch window.
    _hasPin = await _readHasPin();

    // On cold start, only require an unlock when we have both a session and a
    // PIN AND the previous unlock has expired. Within the session window a
    // returning user goes straight in without re-entering the PIN. Without a
    // PIN the user is routed to set one; without a session, to login.
    if (isAuthenticated && _hasPin) {
      _unlocked = await _isWithinSessionWindow();
    } else {
      _unlocked = true;
    }

    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
        state,
      ) {
        final hasSession = Supabase.instance.client.auth.currentSession != null;
        if (!hasSession) {
          // Signed out: drop the unlock gate and demo flag so the guard sends
          // the user back to login.
          _unlocked = false;
          _demoMode = false;
        }
        // Token refresh / signed-in events simply re-run the router guard.
        notifyListeners();
      });
    } catch (_) {
      // Supabase not configured for this build; auth stays unavailable.
    }

    // Validate workspace access in the background so the first frame is never
    // blocked on a network round-trip. The persisted session is trusted for
    // immediate routing; a genuinely revoked account is signed out moments
    // later by the validation below.
    unawaited(validateActiveWorkspaceAccess());

    _initialized = true;
    notifyListeners();
  }

  /// Reads whether a PIN is configured, tolerating a stalled or failing
  /// secure-storage channel. A timeout/error is treated as "no PIN" so startup
  /// is never blocked waiting on the platform.
  Future<bool> _readHasPin() async {
    try {
      return await _lock.hasPin.timeout(const Duration(seconds: 3));
    } catch (_) {
      return false;
    }
  }

  /// Whether the last successful unlock is still within [_sessionValidity].
  Future<bool> _isWithinSessionWindow() async {
    try {
      final lastUnlocked = await _lock.lastUnlockedAt.timeout(
        const Duration(seconds: 3),
      );
      if (lastUnlocked == null) return false;
      return DateTime.now().toUtc().difference(lastUnlocked) < _sessionValidity;
    } catch (_) {
      // On a stalled/failed read, require an unlock (safer default) rather
      // than blocking startup.
      return false;
    }
  }

  Future<void> validateActiveWorkspaceAccess() async {
    if (_validatingWorkspace || !isAuthenticated) return;
    _validatingWorkspace = true;
    try {
      await Supabase.instance.client.rpc('get_my_infra_workspace').single();
    } on PostgrestException catch (error) {
      // Only sign out when the backend definitively reports that this account
      // no longer belongs to any organization (e.g. a customer login was
      // removed by the owner). Transient problems — a momentarily expired or
      // invalid JWT that auto-refresh will replace, or a network blip — must
      // NOT sign the user out.
      if (error.message.toLowerCase().contains('no organization access')) {
        await signOut();
      }
    } catch (_) {
      // Network/timeout/auth-refresh failures are transient: keep the session
      // and let Supabase's token auto-refresh recover it.
    } finally {
      _validatingWorkspace = false;
    }
  }

  /// Re-reads PIN settings from secure storage (call after the user sets or
  /// changes their PIN).
  Future<void> refreshLockSettings() async {
    _hasPin = await _lock.hasPin;
    notifyListeners();
  }

  /// Opens the local lock gate (after a correct PIN or biometric unlock, or
  /// immediately after setting a PIN for the first time).
  void markUnlocked() {
    _unlocked = true;
    _backgroundedAt = null;
    // Persist the unlock time so a returning user within the session window is
    // not asked for the PIN again. Fire-and-forget: the value is non-critical.
    unawaited(_lock.setLastUnlockedAt(DateTime.now().toUtc()));
    notifyListeners();
  }

  /// Closes the local lock gate, forcing a PIN / biometric unlock.
  void lock() {
    if (!_unlocked) return;
    _unlocked = false;
    notifyListeners();
  }

  /// Enters the read-only demo workspace (used when no Supabase session is
  /// available).
  void enterDemoMode() {
    _demoMode = true;
    notifyListeners();
  }

  /// Signs out of Supabase and clears local session state. The local PIN is
  /// intentionally preserved so the same device owner can unlock next time.
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore: even if the network call fails, clear local state below.
    }
    _unlocked = false;
    _demoMode = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _backgroundedAt ??= DateTime.now();
        // Record the moment the app was last active so the session window is
        // measured from when the user left, even across a full app restart.
        if (_unlocked) {
          unawaited(_lock.setLastUnlockedAt(DateTime.now().toUtc()));
        }
        break;
      case AppLifecycleState.inactive:
        // Transient (e.g. system dialog); don't start the background timer.
        break;
      case AppLifecycleState.resumed:
        unawaited(validateActiveWorkspaceAccess());
        _maybeLockAfterBackground();
        _backgroundedAt = null;
        break;
    }
  }

  void _maybeLockAfterBackground() {
    if (!isAuthenticated || !_hasPin || !_unlocked) return;
    final since = _backgroundedAt;
    if (since == null) return;

    if (DateTime.now().difference(since) >= _sessionValidity) {
      lock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    super.dispose();
  }
}
