import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/components/sync_badge.dart';
import '../../../shared/models/ledger_models.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(syncQueueProvider);
    // Local pending counts from the live data already loaded in the app.
    final parties = ref.watch(partiesProvider).value ?? const [];
    final transactions =
        ref.watch(ledgerTransactionsProvider).value ?? const [];
    final pendingLocal = parties
            .where((p) => p.syncStatus != SyncStatus.synced)
            .length +
        transactions.where((t) => t.syncStatus != SyncStatus.synced).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Offline sync queue')),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                Text('Could not load sync queue: $error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(syncQueueProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(syncQueueProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: pendingLocal == 0
                    ? AppTheme.emerald.withValues(alpha: 0.12)
                    : AppTheme.brass.withValues(alpha: 0.12),
                child: ListTile(
                  leading: Icon(
                    pendingLocal == 0
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_sync_outlined,
                  ),
                  title: Text(
                    pendingLocal == 0
                        ? 'All changes synced'
                        : '$pendingLocal change${pendingLocal == 1 ? '' : 's'} pending',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'Entries sync automatically when online.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No queued sync operations.'),
                  ),
                )
              else
                ...items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(
                        item.entityType,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        item.lastError ?? 'Attempts: ${item.attempts}',
                      ),
                      trailing: SyncBadge(status: item.status),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
