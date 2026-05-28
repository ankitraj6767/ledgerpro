import 'package:flutter/material.dart';

import '../../../core/security/app_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _pinController = TextEditingController();
  final _service = AppLockService();
  bool _biometric = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App lock')),
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
          const Text(
            'PIN is hashed and stored with salt in secure platform storage.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            decoration: const InputDecoration(
              labelText: 'Set PIN',
              prefixIcon: Icon(Icons.password_outlined),
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
            onPressed: _save,
            icon: const Icon(Icons.lock_outline),
            label: const Text('Save app lock'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.setPin(_pinController.text.trim());
      await _service.setBiometricEnabled(enabled: _biometric);
      messenger.showSnackBar(const SnackBar(content: Text('App lock saved')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}
