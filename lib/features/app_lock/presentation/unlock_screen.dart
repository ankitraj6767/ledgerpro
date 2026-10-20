import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/security/app_session_controller.dart';
import '../../../shared/components/auth_components.dart';

/// Lock gate shown when a returning user has a valid Supabase session and a
/// configured PIN. Unlocks with PIN or biometrics instead of a full re-login.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _pinController = TextEditingController();
  bool _verifying = false;
  bool _biometricAvailable = false;
  bool _authenticatingBiometrics = false;

  bool get _busy => _verifying || _authenticatingBiometrics;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricOnOpen());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricOnOpen() async {
    final controller = ref.read(appSessionControllerProvider);
    final enabled = await controller.lockService.biometricEnabled;
    if (!mounted || !enabled) return;
    final canUse = await controller.lockService.canUseBiometrics();
    if (!mounted) return;
    setState(() => _biometricAvailable = canUse);
    if (canUse) await _unlockWithBiometrics(auto: true);
  }

  Future<void> _unlockWithBiometrics({bool auto = false}) async {
    if (_busy) return;
    setState(() => _authenticatingBiometrics = true);
    final controller = ref.read(appSessionControllerProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await controller.lockService.authenticateWithBiometrics();
      if (!mounted) return;
      if (ok) {
        _onUnlocked();
      } else if (!auto) {
        // Returned false without throwing (e.g. user dismissed); stay on PIN.
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric unlock was not completed. Enter your PIN.',
            ),
          ),
        );
      }
    } on PlatformException catch (error) {
      if (!mounted || auto) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Biometric unlock unavailable: ${error.message ?? error.code}. Use your PIN.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted || auto) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Biometric unlock failed. Please use your PIN.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _authenticatingBiometrics = false);
    }
  }

  Future<void> _unlockWithPin() async {
    if (_busy) return;
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _verifying = true;
      _error = null;
    });

    final controller = ref.read(appSessionControllerProvider);
    final ok = await controller.lockService.verifyPin(pin);

    if (!mounted) return;
    if (ok) {
      _onUnlocked();
    } else {
      setState(() {
        _verifying = false;
        _error = 'Incorrect PIN. Please try again.';
        _pinController.clear();
      });
    }
  }

  void _onUnlocked() {
    // Opening the lock gate notifies the session controller, which drives the
    // GoRouter redirect (via refreshListenable) to /home. We deliberately do
    // NOT also call context.go here: the previous double navigation (state
    // change + explicit go) could momentarily surface a second/duplicate view
    // on desktop. A single navigation source keeps it in the same window.
    ref.read(appSessionControllerProvider).markUnlocked();
  }

  Future<void> _useDifferentAccount() async {
    final controller = ref.read(appSessionControllerProvider);
    await controller.signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthBrand(),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE1D8C5)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuthPalette.ink,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: AuthPalette.ink.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AuthPalette.gold,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'WELCOME BACK',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthPalette.muted,
              fontSize: 11,
              letterSpacing: 2.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pick up where\nyou left off.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthPalette.ink,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter your PIN to unlock NAVDREAM.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthPalette.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthFieldLabel('Your unlock PIN'),
                TextField(
                  controller: _pinController,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  obscuringCharacter: '●',
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true,
                  maxLength: 8,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AuthPalette.ink,
                    fontSize: 22,
                    letterSpacing: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) => _unlockWithPin(),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter PIN',
                    hintStyle: const TextStyle(
                      color: AuthPalette.muted,
                      fontSize: 15,
                      letterSpacing: 0,
                    ),
                    labelText: 'PIN',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    errorText: _error,
                    errorMaxLines: 3,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  label: _verifying ? 'Unlocking…' : 'Unlock workspace',
                  loading: _verifying,
                  onPressed: _busy ? null : _unlockWithPin,
                  icon: Icons.lock_open_rounded,
                ),
                if (_biometricAvailable) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AuthPalette.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: AuthPalette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AuthPalette.line)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : _unlockWithBiometrics,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AuthPalette.ink,
                      textStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(
                            color: AuthPalette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                      minimumSize: const Size.fromHeight(54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      side: const BorderSide(color: AuthPalette.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded, size: 24),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _authenticatingBiometrics
                                ? 'Checking biometrics…'
                                : 'Use biometrics',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _busy ? null : _useDifferentAccount,
            style: TextButton.styleFrom(
              foregroundColor: AuthPalette.ink,
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            ),
            child: const Text(
              'Sign in with a different account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          const AuthFooter(text: 'A little security. A confident start.'),
        ],
      ),
    );
  }
}
