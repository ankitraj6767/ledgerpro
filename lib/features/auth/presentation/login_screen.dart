import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '+91');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailMode = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InfraColors.navy,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.apartment, color: InfraColors.gold, size: 48),
            const SizedBox(height: 14),
            Text(
              AppConstants.appName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const Text(
              AppConstants.appTagline,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: InfraColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _emailMode ? 'Email sign-in' : 'Phone OTP login',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to manage your infrastructure projects.',
                    style: TextStyle(color: InfraColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  if (_emailMode) ...[
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ] else
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_android_outlined),
                      ),
                    ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _loading ? null : _continue,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(_emailMode ? 'Sign in' : 'Send OTP'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _emailMode = !_emailMode),
                    icon: Icon(
                      _emailMode ? Icons.sms_outlined : Icons.mail_outline,
                    ),
                    label: Text(
                      _emailMode ? 'Use phone OTP' : 'Use email sign-in',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    final auth = container.read(authRepositoryProvider);
    var signedIn = false;
    try {
      if (_emailMode) {
        await auth.signInWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        signedIn = true;
        try {
          await container.read(infraRepositoryProvider).getMyWorkspace();
        } on PostgrestException catch (error) {
          if (_isMissingWorkspace(error)) {
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
        container.invalidate(dashboardSummaryProvider);
        container.invalidate(projectsProvider);
      } else {
        final phone = _phoneController.text.trim();
        await auth.sendPhoneOtp(phone);
        if (mounted) context.push(AppRoutes.otp, extra: phone);
      }
    } catch (error) {
      final msg = error.toString().toLowerCase();
      final isPhoneOtpUnavailable = !_emailMode && _isPhoneOtpUnavailable(msg);

      if (isPhoneOtpUnavailable && mounted) {
        setState(() => _emailMode = true);
        messenger.showSnackBar(
          SnackBar(content: Text(_phoneOtpFallbackMessage(msg))),
        );
        return;
      }

      if (error is AuthException) {
        final m = error.message.trim();
        final normalized = m.toLowerCase();
        if (_emailMode &&
            normalized.contains('invalid') &&
            normalized.contains('credentials')) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Incorrect email or password.')),
          );
          return;
        }
        if (_emailMode && normalized.contains('email not confirmed')) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Email is not confirmed yet. Please confirm and try again.',
              ),
            ),
          );
          return;
        }
        if (m.isNotEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(m)));
          return;
        }
      }

      if (signedIn) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Signed in, but workspace setup failed: ${_clean(error)}',
            ),
          ),
        );
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sign-in failed. Please check your credentials.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _clean(Object error) {
    if (error is PostgrestException) return error.message;
    return error.toString();
  }

  bool _isMissingWorkspace(PostgrestException error) {
    return error.message.toLowerCase().contains('no organization access');
  }

  bool _isPhoneOtpUnavailable(String normalizedMessage) {
    return normalizedMessage.contains('phone otp is not configured') ||
        (normalizedMessage.contains('phone') &&
            normalizedMessage.contains('otp') &&
            normalizedMessage.contains('not configured')) ||
        (normalizedMessage.contains('provider') &&
            normalizedMessage.contains('not configured')) ||
        normalizedMessage.contains('sms_send_failed') ||
        normalizedMessage.contains('error sending confirmation otp') ||
        normalizedMessage.contains('invalid from number') ||
        normalizedMessage.contains('caller id') ||
        normalizedMessage.contains('twilio.com/docs/errors/21212');
  }

  String _phoneOtpFallbackMessage(String normalizedMessage) {
    if (normalizedMessage.contains('invalid from number') ||
        normalizedMessage.contains('caller id') ||
        normalizedMessage.contains('twilio.com/docs/errors/21212')) {
      return 'Phone OTP provider is misconfigured. Please use email sign-in while SMS is fixed.';
    }
    return 'Phone OTP is not enabled for this project. Please use email sign-in.';
  }
}
