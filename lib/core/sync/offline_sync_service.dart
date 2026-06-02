import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/local_database_provider.dart';
import '../../data/remote/supabase_ledger_api.dart';
import 'queued_mutation_remote.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(supabaseLedgerApiProvider),
  );
});

final syncOverviewProvider = FutureProvider<SyncOverview>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  final rows = await database.select(database.localPendingMutations).get();
  return SyncOverview.fromMutations(rows);
});

class OfflineSyncService {
  const OfflineSyncService({required this.database, required this.api});

  final AppDatabase database;
  final QueuedMutationRemote? api;

  Future<SyncRunResult> syncPending({DateTime? now}) async {
    if (api == null) {
      return const SyncRunResult(
        attempted: 0,
        synced: 0,
        failed: 0,
        message: 'Supabase is not configured for this build.',
      );
    }

    final clock = now ?? DateTime.now();
    final due = (await database.pendingMutationsInSyncOrder())
        .where((mutation) => _isDue(mutation, clock))
        .toList();
    var synced = 0;
    var failed = 0;

    for (final mutation in due) {
      try {
        await (database.update(
          database.localPendingMutations,
        )..where((item) => item.id.equals(mutation.id))).write(
          LocalPendingMutationsCompanion(
            status: const Value('inFlight'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await api!.applyQueuedMutation(_requestFrom(mutation));
        await (database.update(
          database.localPendingMutations,
        )..where((item) => item.id.equals(mutation.id))).write(
          LocalPendingMutationsCompanion(
            status: const Value('synced'),
            lastError: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
        synced++;
      } catch (error) {
        failed++;
        await (database.update(
          database.localPendingMutations,
        )..where((item) => item.id.equals(mutation.id))).write(
          LocalPendingMutationsCompanion(
            status: const Value('failed'),
            attempts: Value(mutation.attempts + 1),
            lastError: Value('$error'),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }

    return SyncRunResult(
      attempted: due.length,
      synced: synced,
      failed: failed,
      message: due.isEmpty
          ? 'No retryable mutations are due yet.'
          : 'Sync run complete',
    );
  }

  bool _isDue(LocalPendingMutation mutation, DateTime now) {
    if (mutation.status == 'pending') return true;
    if (mutation.status != 'failed') return false;
    return !mutation.updatedAt.add(retryDelay(mutation.attempts)).isAfter(now);
  }

  QueuedMutationRequest _requestFrom(LocalPendingMutation mutation) {
    final decoded = jsonDecode(mutation.payloadJson);
    if (decoded is! Map) {
      throw const FormatException(
        'Queued mutation payload must be a JSON map.',
      );
    }
    return QueuedMutationRequest(
      id: mutation.id,
      entityType: mutation.entityType,
      entityId: mutation.entityId,
      action: mutation.action,
      payload: Map<String, dynamic>.from(decoded),
    );
  }

  static Duration retryDelay(int attempts) {
    if (attempts <= 0) return Duration.zero;
    final capped = attempts.clamp(1, 8);
    return Duration(seconds: math.min(300, math.pow(2, capped).toInt()));
  }
}

class SyncRunResult {
  const SyncRunResult({
    required this.attempted,
    required this.synced,
    required this.failed,
    required this.message,
  });

  final int attempted;
  final int synced;
  final int failed;
  final String message;
}

class SyncOverview {
  const SyncOverview({required this.rows});

  final List<SyncEntityOverview> rows;

  int get pendingCount => rows.fold(
    0,
    (sum, row) => sum + row.pendingCount + row.failedCount + row.inFlightCount,
  );

  int get failedCount => rows.fold(0, (sum, row) => sum + row.failedCount);

  DateTime? get lastSyncedAt {
    DateTime? latest;
    for (final row in rows) {
      final value = row.lastSyncedAt;
      if (value == null) continue;
      if (latest == null || value.isAfter(latest)) latest = value;
    }
    return latest;
  }

  bool get hasErrors => failedCount > 0;
  bool get isClean => pendingCount == 0 && !hasErrors;

  static SyncOverview fromMutations(List<LocalPendingMutation> mutations) {
    final byEntity = <String, List<LocalPendingMutation>>{};
    for (final mutation in mutations) {
      byEntity.putIfAbsent(mutation.entityType, () => []).add(mutation);
    }
    final rows = byEntity.entries.map((entry) {
      final items = entry.value;
      DateTime? lastSyncedAt;
      String? lastError;
      var pending = 0;
      var inFlight = 0;
      var failed = 0;
      for (final item in items) {
        switch (item.status) {
          case 'synced':
            if (lastSyncedAt == null || item.updatedAt.isAfter(lastSyncedAt)) {
              lastSyncedAt = item.updatedAt;
            }
            break;
          case 'inFlight':
            inFlight++;
            break;
          case 'failed':
            failed++;
            lastError = item.lastError ?? lastError;
            break;
          default:
            pending++;
            break;
        }
      }
      return SyncEntityOverview(
        entityType: entry.key,
        pendingCount: pending,
        inFlightCount: inFlight,
        failedCount: failed,
        lastSyncedAt: lastSyncedAt,
        lastError: lastError,
      );
    }).toList()..sort((a, b) => a.entityType.compareTo(b.entityType));
    return SyncOverview(rows: rows);
  }
}

class SyncEntityOverview {
  const SyncEntityOverview({
    required this.entityType,
    required this.pendingCount,
    required this.inFlightCount,
    required this.failedCount,
    required this.lastSyncedAt,
    required this.lastError,
  });

  final String entityType;
  final int pendingCount;
  final int inFlightCount;
  final int failedCount;
  final DateTime? lastSyncedAt;
  final String? lastError;
}
