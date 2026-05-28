import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/constants/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) return null;
    // Supabase.instance.client throws if Supabase.initialize wasn't called.
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isConfigured => _client != null;

  Future<void> sendPhoneOtp(String phone) async {
    final client = _client;
    if (client == null) {
      throw const AuthException('Supabase phone OTP is not configured.');
    }
    await client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthException('Supabase phone OTP is not configured.');
    }
    return client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthException(
        'Supabase is not configured for this build. Rebuild with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.',
      );
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }
}
