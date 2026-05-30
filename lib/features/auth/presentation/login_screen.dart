import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../data/repositories/ledger_repository.dart';
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
    final auth = ref.watch(authRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppConstants.appName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Text(
              _emailMode ? 'Email fallback' : 'Phone OTP login',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              auth.isConfigured
                  ? 'Use your internal business account to continue.'
                  : 'Supabase keys are not provided. Demo workspace is available for local review.',
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _emailMode
                  ? Column(
                      key: const ValueKey('email'),
                      children: [
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
                      ],
                    )
                  : TextField(
                      key: const ValueKey('phone'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_android_outlined),
                      ),
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
              icon: Icon(_emailMode ? Icons.sms_outlined : Icons.mail_outline),
              label: Text(_emailMode ? 'Use phone OTP' : 'Use email fallback'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    // Capture the container up front. After a successful sign-in the auth state
    // change triggers the router guard, which unmounts this screen. Using `ref`
    // after that point throws "ref used after unmount", so we use the container
    // (which is not tied to this widget's lifecycle) for post-await work.
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
        await container.read(ledgerRepositoryProvider).ensureWorkspace();
        container.invalidate(ledgerWorkspaceProvider);
        container.invalidate(partiesProvider);
        container.invalidate(ledgerTransactionsProvider);
        container.invalidate(businessSummaryProvider);
        // Navigation is handled by the router guard (it redirects to app-lock
        // setup or home based on session + PIN state), so no manual go() here.
      } else {
        await auth.sendPhoneOtp(_phoneController.text.trim());
        if (mounted) context.push(AppRoutes.otp);
      }
    } catch (error) {
      // Supabase can be "configured" (keys present) but phone OTP can still be disabled
      // in the project's Auth provider settings. In that case, fall back to email mode
      // instead of showing a raw exception string.
      final msg = error.toString().toLowerCase();
      final isPhoneOtpUnavailable =
          !_emailMode &&
          (msg.contains('phone otp is not configured') ||
              (msg.contains('phone') &&
                  msg.contains('otp') &&
                  msg.contains('not configured')) ||
              msg.contains('provider') && msg.contains('not configured'));

      if (isPhoneOtpUnavailable && mounted) {
        setState(() => _emailMode = true);
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Phone OTP login is not enabled for this Supabase project. Please use email sign-in.',
            ),
          ),
        );
        return;
      }

      if (error is AuthException) {
        final m = error.message.trim();
        final normalized = m.toLowerCase();
        if (_emailMode &&
            (normalized.contains('invalid login credentials') ||
                normalized.contains('invalid') &&
                    normalized.contains('credentials'))) {
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
              'Signed in, but workspace setup failed: ${_cleanError(error)}',
            ),
          ),
        );
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Sign-in failed. Please check your credentials or use the demo workspace.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _cleanError(Object error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return error.toString();
  }
}
