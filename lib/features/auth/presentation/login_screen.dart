import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/auth_components.dart';
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
  bool _passwordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBrand(dark: true),
          const SizedBox(height: 40),
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AuthPalette.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Build with\n'),
                TextSpan(
                  text: 'confidence.',
                  style: TextStyle(color: AuthPalette.gold),
                ),
              ],
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.12,
              letterSpacing: -1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppConstants.appTagline,
            style: TextStyle(
              color: Color(0xFFAFBFCA),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          AuthCard(
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your workspace awaits',
                    style: TextStyle(
                      color: AuthPalette.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 23,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to manage your infrastructure projects.',
                    style: TextStyle(
                      color: AuthPalette.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _signInMethods(),
                  const SizedBox(height: 24),
                  if (_emailMode) ...[
                    const AuthFieldLabel('Email address'),
                    TextField(
                      controller: _emailController,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'you@company.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                        labelText: 'Email address',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AuthFieldLabel('Password'),
                    TextField(
                      controller: _passwordController,
                      enabled: !_loading,
                      obscureText: !_passwordVisible,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _continue(),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _passwordVisible
                              ? 'Hide password'
                              : 'Show password',
                          onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const AuthFieldLabel('Phone number'),
                    TextField(
                      controller: _phoneController,
                      enabled: !_loading,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onSubmitted: (_) => _continue(),
                      decoration: const InputDecoration(
                        hintText: '+91 98765 43210',
                        labelText: 'Phone number',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'We’ll send a one-time code to your phone.',
                      style: TextStyle(
                        color: AuthPalette.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: _loading
                        ? (_emailMode ? 'Signing in…' : 'Sending code…')
                        : (_emailMode ? 'Sign in' : 'Send OTP'),
                    loading: _loading,
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const AuthFooter(
            text: 'Your projects. One connected workspace.',
            dark: true,
          ),
        ],
      ),
    );
  }

  Widget _signInMethods() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _methodButton(
            email: true,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
          ),
          _methodButton(
            email: false,
            label: 'Phone OTP',
            icon: Icons.sms_outlined,
          ),
        ],
      ),
    );
  }

  Widget _methodButton({
    required bool email,
    required String label,
    required IconData icon,
  }) {
    final selected = _emailMode == email;
    return Expanded(
      child: Semantics(
        selected: selected,
        child: TextButton(
          onPressed: _loading
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _emailMode = email;
                    _passwordVisible = false;
                  });
                },
          style: TextButton.styleFrom(
            backgroundColor: selected ? Colors.white : Colors.transparent,
            foregroundColor: selected ? AuthPalette.ink : AuthPalette.muted,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 7,
            children: [
              Icon(icon, size: 17),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
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
