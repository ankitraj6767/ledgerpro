import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/security/app_session_controller.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _biometric = true;
  bool _saving = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(appSessionControllerProvider);
    // When there is no PIN yet and the user is signed in, this screen is the
    // mandatory one-time setup step, so we hide the back button.
    final isMandatorySetup = controller.isAuthenticated && !controller.hasPin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMandatorySetup ? 'Set up app lock' : 'App lock'),
        automaticallyImplyLeading: !isMandatorySetup,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Protect local ledger data',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            isMandatorySetup
                ? 'Create a PIN so you can quickly unlock next time without signing in again.'
                : 'PIN is hashed and stored with salt in secure platform storage.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Set PIN (4 to 8 digits)',
              prefixIcon: Icon(Icons.password_outlined),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
              prefixIcon: Icon(Icons.password_outlined),
              counterText: '',
            ),
          ),
          SwitchListTile(
            value: _biometric,
            onChanged: (value) => setState(() => _biometric = value),
            title: const Text('Enable biometric unlock'),
            subtitle: const Text('Uses Android biometrics when available.'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outline),
            label: Text(isMandatorySetup ? 'Save and continue' : 'Save app lock'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(appSessionControllerProvider);
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pin != confirm) {
      messenger.showSnackBar(
        const SnackBar(content: Text('PINs do not match.')),
      );
      return;
    }

    setState(() => _saving = true);
    final wasMandatorySetup = controller.isAuthenticated && !controller.hasPin;

    try {
      await controller.lockService.setPin(pin);
      await controller.lockService.setBiometricEnabled(enabled: _biometric);
      await controller.refreshLockSettings();
      // Setting a PIN implicitly unlocks the current session.
      controller.markUnlocked();

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('App lock saved')),
      );

      if (wasMandatorySetup) {
        context.go(AppRoutes.home);
      } else if (context.canPop()) {
        context.pop();
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
