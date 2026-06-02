import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/security/app_lock_service.dart';

void main() {
  test('stores only a salted hash for the app lock PIN', () async {
    final store = _MemoryAppLockStore();
    final service = AppLockService(storage: store);

    await service.setPin('123456');

    expect(await service.hasPin, isTrue);
    expect(await service.verifyPin('123456'), isTrue);
    expect(await service.verifyPin('654321'), isFalse);
    expect(store.values.values, isNot(contains('123456')));
    expect(store.values['ledgerpro.pin.salt'], isNotNull);
    expect(store.values['ledgerpro.pin.hash'], isNotNull);
  });
}

class _MemoryAppLockStore extends AppLockKeyValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
