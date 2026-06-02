import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../core/network/network_monitor.dart';
import '../../../core/sync/offline_sync_service.dart';

class SyncQueueScreen extends ConsumerStatefulWidget {
  const SyncQueueScreen({super.key});

  @override
  ConsumerState<SyncQueueScreen> createState() => _SyncQueueScreenState();
}

class _SyncQueueScreenState extends ConsumerState<SyncQueueScreen> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(networkMonitorProvider).value ?? true;
    final overviewAsync = ref.watch(syncOverviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync queue')),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: 'Could not load sync queue: $error',
          onRetry: () => ref.invalidate(syncOverviewProvider),
        ),
        data: (overview) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(syncOverviewProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                online: online,
                overview: overview,
                syncing: _syncing,
                onSyncNow: _syncNow,
              ),
              const SizedBox(height: 12),
              if (overview.rows.isEmpty)
                const _EmptyQueueCard()
              else
                ...overview.rows.map((row) => _SyncTableTile(row: row)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncNow() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    try {
      final result = await ref.read(offlineSyncServiceProvider).syncPending();
      ref.invalidate(syncOverviewProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Sync attempted ${result.attempted}; ${result.synced} synced, '
            '${result.failed} failed.',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Sync failed: $error')));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.online,
    required this.overview,
    required this.syncing,
    required this.onSyncNow,
  });

  final bool online;
  final SyncOverview overview;
  final bool syncing;
  final VoidCallback onSyncNow;

  @override
  Widget build(BuildContext context) {
    final color = !online
        ? InfraColors.orange
        : overview.hasErrors
        ? InfraColors.red
        : overview.pendingCount > 0
        ? InfraColors.orange
        : InfraColors.green;
    final title = !online
        ? 'Offline'
        : overview.hasErrors
        ? 'Sync needs attention'
        : overview.pendingCount > 0
        ? '${overview.pendingCount} pending changes'
        : 'All changes synced';
    final lastSynced = overview.lastSyncedAt == null
        ? 'No completed sync yet'
        : 'Last synced ${DateFormat('dd MMM, hh:mm a').format(overview.lastSyncedAt!)}';

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              !online
                  ? Icons.cloud_off_outlined
                  : overview.hasErrors
                  ? Icons.error_outline
                  : overview.pendingCount > 0
                  ? Icons.cloud_sync_outlined
                  : Icons.cloud_done_outlined,
              color: color,
              size: 34,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastSynced,
                    style: const TextStyle(color: InfraColors.textSecondary),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: syncing ? null : onSyncNow,
              icon: syncing
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Sync now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncTableTile extends StatelessWidget {
  const _SyncTableTile({required this.row});

  final SyncEntityOverview row;

  @override
  Widget build(BuildContext context) {
    final hasError = row.failedCount > 0;
    return Card(
      child: ListTile(
        leading: Icon(
          hasError ? Icons.error_outline : Icons.storage_outlined,
          color: hasError ? InfraColors.red : InfraColors.royalBlue,
        ),
        title: Text(
          row.entityType,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(_subtitle(row)),
        trailing: _CountPill(
          label: hasError
              ? '${row.failedCount} failed'
              : '${row.pendingCount} pending',
          color: hasError ? InfraColors.red : InfraColors.orange,
        ),
      ),
    );
  }

  String _subtitle(SyncEntityOverview row) {
    if (row.lastError != null && row.lastError!.isNotEmpty) {
      return row.lastError!;
    }
    if (row.lastSyncedAt != null) {
      return 'Last synced ${DateFormat('dd MMM, hh:mm a').format(row.lastSyncedAt!)}';
    }
    return 'Waiting for first successful sync';
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyQueueCard extends StatelessWidget {
  const _EmptyQueueCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.check_circle_outline, color: InfraColors.green),
        title: Text('No local mutations'),
        subtitle: Text('Queued writes will appear here while offline.'),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
