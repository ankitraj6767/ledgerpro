import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/widgets/access_denied_screen.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canViewAuditLogs) {
      return const AccessDeniedScreen();
    }

    final logsAsync = ref.watch(infraAuditLogsProvider);
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Audit logs')),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'Could not load audit logs: $e',
          onRetry: () => ref.invalidate(infraAuditLogsProvider),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.manage_search_outlined,
              title: 'No audit activity yet',
              message: 'Project changes will be recorded here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.manage_search_outlined),
                  title: Text(
                    '${log.action} · ${log.entityTable}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(dateFormat.format(log.createdAt.toLocal())),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
