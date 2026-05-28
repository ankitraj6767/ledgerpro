import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/sync/sync_queue.dart';

void main() {
  PendingMutation mutation({
    required String id,
    required SyncEntityType type,
    required int minute,
  }) {
    return PendingMutation(
      id: id,
      entityType: type,
      entityId: '$type-$id',
      action: SyncMutationAction.create,
      createdAt: DateTime(2026, 5, 27, 10, minute),
    );
  }

  group('SyncQueue', () {
    test('orders mutations by mandatory sync priority', () {
      final queue = SyncQueue([
        mutation(id: 'tx', type: SyncEntityType.transaction, minute: 1),
        mutation(id: 'business', type: SyncEntityType.business, minute: 2),
        mutation(id: 'party', type: SyncEntityType.party, minute: 0),
        mutation(id: 'book', type: SyncEntityType.book, minute: 3),
      ]);

      expect(queue.retryableOrder().map((item) => item.entityType), [
        SyncEntityType.business,
        SyncEntityType.book,
        SyncEntityType.party,
        SyncEntityType.transaction,
      ]);
    });

    test('failed items remain retryable and increment attempts', () {
      final queue = SyncQueue([
        mutation(id: 'tx', type: SyncEntityType.transaction, minute: 1),
      ]);

      queue.markFailed('tx', 'network');
      final retryable = queue.retryableOrder().single;

      expect(retryable.status, SyncMutationStatus.failed);
      expect(retryable.attempts, 1);
      expect(retryable.lastError, 'network');
    });

    test('synced items are not retried', () {
      final queue = SyncQueue([
        mutation(id: 'tx', type: SyncEntityType.transaction, minute: 1),
      ]);

      queue.markSynced('tx');

      expect(queue.retryableOrder(), isEmpty);
    });
  });
}
