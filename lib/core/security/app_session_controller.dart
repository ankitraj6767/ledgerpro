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
/// - Auto-lock the app when it has been in the background longer than the
///   configured auto-lock window.
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
  int _autoLockMinutes = 2;
  DateTime? _backgroundedAt;

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

    _hasPin = await _lock.hasPin;
    _autoLockMinutes = await _lock.autoLockMinutes;

    // On cold start, require an unlock only when we both have a session and a
    // PIN. Without a PIN the user is routed to set one; without a session they
    // are routed to login.
    _unlocked = !(isAuthenticated && _hasPin);

    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
        state,
      ) {
        final hasSession =
            Supabase.instance.client.auth.currentSession != null;
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

    _initialized = true;
    notifyListeners();
  }

  /// Re-reads PIN + auto-lock settings from secure storage (call after the
  /// user sets or changes their PIN).
  Future<void> refreshLockSettings() async {
    _hasPin = await _lock.hasPin;
    _autoLockMinutes = await _lock.autoLockMinutes;
    notifyListeners();
  }

  /// Opens the local lock gate (after a correct PIN or biometric unlock, or
  /// immediately after setting a PIN for the first time).
  void markUnlocked() {
    _unlocked = true;
    _backgroundedAt = null;
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
        break;
      case AppLifecycleState.inactive:
        // Transient (e.g. system dialog); don't start the background timer.
        break;
      case AppLifecycleState.resumed:
        _maybeLockAfterBackground();
        _backgroundedAt = null;
        break;
    }
  }

  void _maybeLockAfterBackground() {
    if (!isAuthenticated || !_hasPin || !_unlocked) return;
    final since = _backgroundedAt;
    if (since == null) return;

    final elapsed = DateTime.now().difference(since);
    if (elapsed >= Duration(minutes: _autoLockMinutes)) {
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
