import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../data/repositories/infra_repository.dart';
import '../data/auth_repository.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.phone});

  final String? phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  bool _verifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Enter the 6 digit code',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            phone == null
                ? 'Enter the OTP sent to your phone.'
                : 'OTP sent to $phone.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'OTP',
              prefixIcon: Icon(Icons.pin_outlined),
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: (_verifying || phone == null) ? null : _verify,
            icon: _verifying
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_user_outlined),
            label: const Text('Verify and continue'),
          ),
          if (phone == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'No phone number provided. Please go back and request an OTP.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _verify() async {
    final phone = widget.phone;
    if (phone == null) return;
    final code = _otpController.text.trim();
    if (code.length < 4) return;

    setState(() => _verifying = true);
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await container
          .read(authRepositoryProvider)
          .verifyPhoneOtp(phone: phone, token: code);
      try {
        await container.read(infraRepositoryProvider).getMyWorkspace();
      } on PostgrestException catch (error) {
        if (error.message.toLowerCase().contains('no organization access')) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'No workspace found. Set up the owner workspace to continue.',
              ),
            ),
          );
          if (mounted) context.go(AppRoutes.onboarding);
          return;
        }
        rethrow;
      }
      container.invalidate(infraWorkspaceProvider);
      // Router guard will route to app-lock setup or home.
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Verification failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }
}
