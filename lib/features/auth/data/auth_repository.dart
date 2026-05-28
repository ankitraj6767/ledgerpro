import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  SupabaseClient? get _client {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) return null;
    return Supabase.instance.client;
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
      throw const AuthException('Supabase email login is not configured.');
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }
}
