import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';

/// Sync queue status. The app currently writes directly to Supabase with
/// online-first behavior, so when connected there are no pending mutations.
/// (Full offline-first Drift queue is planned — see roadmap.)
class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final synced = !projectsAsync.isLoading && !projectsAsync.hasError;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync queue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: synced
                ? InfraColors.green.withValues(alpha: 0.12)
                : InfraColors.orange.withValues(alpha: 0.12),
            child: ListTile(
              leading: Icon(
                synced ? Icons.cloud_done_outlined : Icons.cloud_sync_outlined,
                color: synced ? InfraColors.green : InfraColors.orange,
              ),
              title: Text(
                synced ? 'All changes synced' : 'Syncing…',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Project data is saved to the cloud as you make changes.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Offline support'),
              subtitle: Text(
                'Offline-first local caching and a retrying sync queue are on '
                'the roadmap. You currently need a connection to make changes.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
