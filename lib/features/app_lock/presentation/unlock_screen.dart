import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/security/app_session_controller.dart';

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
    if (!enabled) return;
    // Show the biometric button whenever the user enrolled it during setup.
    if (mounted) setState(() => _biometricAvailable = true);
    final canUse = await controller.lockService.canUseBiometrics();
    if (canUse) await _unlockWithBiometrics(auto: true);
  }

  Future<void> _unlockWithBiometrics({bool auto = false}) async {
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
            content: Text('Biometric unlock was not completed. Enter your PIN.'),
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
    }
  }

  Future<void> _unlockWithPin() async {
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
    final controller = ref.read(appSessionControllerProvider);
    controller.markUnlocked();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _useDifferentAccount() async {
    final controller = ref.read(appSessionControllerProvider);
    await controller.signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Welcome back',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Enter your PIN to unlock LedgerPro Mobile.'),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              autofocus: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _unlockWithPin(),
              decoration: InputDecoration(
                labelText: 'PIN',
                prefixIcon: const Icon(Icons.password_outlined),
                errorText: _error,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _verifying ? null : _unlockWithPin,
              icon: _verifying
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_open_outlined),
              label: const Text('Unlock'),
            ),
            if (_biometricAvailable) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _verifying ? null : _unlockWithBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use biometrics'),
              ),
            ],
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _verifying ? null : _useDifferentAccount,
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Sign in with a different account'),
            ),
          ],
        ),
      ),
    );
  }
}
