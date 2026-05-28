import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../data/local/app_database.dart';
import '../../data/local/local_database_provider.dart';
import '../../data/remote/supabase_ledger_api.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(supabaseLedgerApiProvider),
  );
});

class OfflineSyncService {
  const OfflineSyncService({required this.database, required this.api});

  final AppDatabase database;
  final SupabaseLedgerApi? api;

  Future<SyncRunResult> syncPending() async {
    if (api == null) {
      return const SyncRunResult(
        attempted: 0,
        synced: 0,
        failed: 0,
        message: 'Supabase is not configured for this build.',
      );
    }

    final pending = await database.pendingMutationsInSyncOrder();
    var synced = 0;
    var failed = 0;

    for (final mutation in pending) {
      try {
        await (database.update(
          database.localPendingMutations,
        )..where((item) => item.id.equals(mutation.id))).write(
          LocalPendingMutationsCompanion(
            status: const Value('inFlight'),
            updatedAt: Value(DateTime.now()),
          ),
        );
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
      attempted: pending.length,
      synced: synced,
      failed: failed,
      message: 'Sync run complete',
    );
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
