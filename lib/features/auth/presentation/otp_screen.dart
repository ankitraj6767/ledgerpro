import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/ledgerpro_design_system.dart';
import '../../../shared/components/navdream_logo.dart';
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
      backgroundColor: InfraColors.graphite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: InfraColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NavdreamLogo(
                      size: 48,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      showBorder: true,
                    ),
                    const SizedBox(height: 28),
                    const LedgerProEyebrow('Secure verification'),
                    const SizedBox(height: 8),
                    Text(
                      'Confirm your access',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phone == null
                          ? 'Enter the one-time code sent to your phone.'
                          : 'Enter the six-digit code sent to $phone.',
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                        prefixIcon: Icon(Icons.pin_outlined),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: (_verifying || phone == null)
                            ? null
                            : _verify,
                        icon: _verifying
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.verified_user_outlined),
                        label: const Text('Verify and continue'),
                      ),
                    ),
                    if (phone == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'No phone number provided. Go back and request a new code.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
