import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/sync/offline_sync_service.dart';
import 'package:ledgerpro_mobile/core/sync/queued_mutation_remote.dart';
import 'package:ledgerpro_mobile/data/local/app_database.dart';

void main() {
  late AppDatabase database;
  late _FakeRemote remote;
  late OfflineSyncService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    remote = _FakeRemote();
    service = OfflineSyncService(database: database, api: remote);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> queueMutation({
    String id = 'mutation-1',
    String status = 'pending',
    int attempts = 0,
    DateTime? updatedAt,
  }) {
    final now = DateTime(2026, 6, 1, 10);
    return database.queueMutation(
      LocalPendingMutationsCompanion.insert(
        id: id,
        entityType: 'party',
        entityId: 'party-1',
        action: 'upsert',
        payloadJson: '{"id":"party-1","name":"A"}',
        status: Value(status),
        attempts: Value(attempts),
        createdAt: Value(now),
        updatedAt: Value(updatedAt ?? now),
      ),
    );
  }

  test(
    'marks a mutation synced only after the remote writer succeeds',
    () async {
      await queueMutation();

      final result = await service.syncPending(
        now: DateTime(2026, 6, 1, 10, 1),
      );

      final row =
          (await database.select(database.localPendingMutations).get()).single;
      expect(remote.appliedIds, ['mutation-1']);
      expect(result.synced, 1);
      expect(row.status, 'synced');
      expect(row.lastError, isNull);
    },
  );

  test('keeps a mutation retryable when the remote writer fails', () async {
    remote.failure = StateError('network down');
    await queueMutation();

    final result = await service.syncPending(now: DateTime(2026, 6, 1, 10, 1));

    final row =
        (await database.select(database.localPendingMutations).get()).single;
    expect(result.failed, 1);
    expect(row.status, 'failed');
    expect(row.attempts, 1);
    expect(row.lastError, contains('network down'));
  });

  test('backs off failed mutations before retrying', () async {
    await queueMutation(
      status: 'failed',
      attempts: 4,
      updatedAt: DateTime(2026, 6, 1, 10),
    );

    final early = await service.syncPending(
      now: DateTime(2026, 6, 1, 10, 0, 5),
    );
    expect(early.attempted, 0);
    expect(remote.appliedIds, isEmpty);

    final later = await service.syncPending(
      now: DateTime(2026, 6, 1, 10, 0, 20),
    );
    expect(later.attempted, 1);
    expect(remote.appliedIds, ['mutation-1']);
  });
}

class _FakeRemote implements QueuedMutationRemote {
  final appliedIds = <String>[];
  Object? failure;

  @override
  Future<void> applyQueuedMutation(QueuedMutationRequest mutation) async {
    if (failure != null) throw failure!;
    appliedIds.add(mutation.id);
  }
}
