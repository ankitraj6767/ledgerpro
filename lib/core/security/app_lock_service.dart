import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

class AppLockService {
  AppLockService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuthentication,
  }) : _storage = secureStorage ?? const FlutterSecureStorage(),
       _localAuth = localAuthentication ?? LocalAuthentication();

  static const _pinSaltKey = 'ledgerpro.pin.salt';
  static const _pinHashKey = 'ledgerpro.pin.hash';
  static const _biometricEnabledKey = 'ledgerpro.biometric.enabled';
  static const _autoLockMinutesKey = 'ledgerpro.auto_lock.minutes';

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  Future<bool> get hasPin async =>
      (await _storage.read(key: _pinHashKey)) != null;

  Future<void> setPin(String pin) async {
    _validatePin(pin);
    final salt = const Uuid().v4();
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: _hash(pin, salt));
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _pinSaltKey);
    final expected = await _storage.read(key: _pinHashKey);
    if (salt == null || expected == null) return false;
    return _hash(pin, salt) == expected;
  }

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> get biometricEnabled async =>
      await _storage.read(key: _biometricEnabledKey) == 'true';

  /// Whether the device can actually perform a biometric (or device
  /// credential) check right now.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      final enrolled = await _localAuth.getAvailableBiometrics();
      return canCheck || enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    final supported = await _localAuth.isDeviceSupported();
    if (!supported) return false;
    return _localAuth.authenticate(
      localizedReason: 'Unlock NAVDREAM',
      // Allow fallback to device PIN/pattern/password so unlock still works on
      // devices without enrolled fingerprints/face. biometricOnly:true would
      // throw on such devices and make the button appear to do nothing.
      biometricOnly: false,
      persistAcrossBackgrounding: true,
    );
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _storage.write(key: _autoLockMinutesKey, value: minutes.toString());
  }

  Future<int> get autoLockMinutes async {
    final raw = await _storage.read(key: _autoLockMinutesKey);
    return int.tryParse(raw ?? '') ?? 2;
  }

  String _hash(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  void _validatePin(String pin) {
    if (pin.length < 4 || pin.length > 8 || int.tryParse(pin) == null) {
      throw ArgumentError('PIN must be 4 to 8 digits');
    }
  }
}
