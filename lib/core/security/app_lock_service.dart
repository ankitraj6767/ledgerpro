import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../platform/platform_capabilities.dart';

class AppLockService {
  AppLockService({
    AppLockKeyValueStore? storage,
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuthentication,
  }) : _storage = storage ?? _defaultStorage(secureStorage),
       _localAuth = localAuthentication ?? LocalAuthentication();

  static const _pinSaltKey = 'ledgerpro.pin.salt';
  static const _pinHashKey = 'ledgerpro.pin.hash';
  static const _biometricEnabledKey = 'ledgerpro.biometric.enabled';
  static const _autoLockMinutesKey = 'ledgerpro.auto_lock.minutes';

  final AppLockKeyValueStore _storage;
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
    if (!PlatformCapabilities.supportsBiometricUnlock) return false;
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
    if (!PlatformCapabilities.supportsBiometricUnlock) return false;
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

  static AppLockKeyValueStore _defaultStorage(
    FlutterSecureStorage? secureStorage,
  ) {
    // Unsigned macOS Flutter builds cannot use Keychain access groups without
    // developer signing, which surfaces as OSStatus -34018 while saving the PIN.
    if (Platform.isMacOS) return const _DesktopAppLockStore();
    return _SecureAppLockStore(secureStorage ?? const FlutterSecureStorage());
  }
}

abstract class AppLockKeyValueStore {
  const AppLockKeyValueStore();

  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});
}

class _SecureAppLockStore extends AppLockKeyValueStore {
  const _SecureAppLockStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }
}

class _DesktopAppLockStore extends AppLockKeyValueStore {
  const _DesktopAppLockStore();

  static const _fileName = 'app_lock.json';

  @override
  Future<String?> read({required String key}) async {
    final values = await _readAll();
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final values = await _readAll();
    values[key] = value;

    final file = await _storageFile();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(values), flush: true);
    if (await file.exists()) await file.delete();
    await temp.rename(file.path);

    if (!Platform.isWindows) {
      try {
        await Process.run('chmod', ['600', file.path]);
      } catch (_) {
        // Best effort only; the PIN value itself is never stored, just a hash.
      }
    }
  }

  Future<Map<String, String>> _readAll() async {
    final file = await _storageFile();
    if (!await file.exists()) return {};

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<File> _storageFile() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      return File('${supportDir.path}${Platform.pathSeparator}$_fileName');
    } catch (_) {
      final fallbackDir = Directory(
        '${Directory.systemTemp.path}${Platform.pathSeparator}navdream',
      );
      return File('${fallbackDir.path}${Platform.pathSeparator}$_fileName');
    }
  }
}
