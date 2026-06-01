import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../core/security/app_session_controller.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/components/navdream_logo.dart';

/// Global expenses tab: pick a project to view/add expenses.
class GlobalExpensesScreen extends ConsumerWidget {
  const GlobalExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'Could not load projects: $e',
          onRetry: () => ref.invalidate(projectsProvider),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No projects yet',
              message: 'Create a project to start tracking expenses.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Select a project to view or add expenses',
                style: TextStyle(color: InfraColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...projects.map(
                (p) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.business_outlined,
                      color: InfraColors.royalBlue,
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'Total expenses: ₹${(p.totalExpensePaise / 100).toStringAsFixed(2)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.projectDetail(p.id), extra: p),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Global reports tab.
class GlobalReportsScreen extends ConsumerWidget {
  const GlobalReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'Could not load projects: $e',
          onRetry: () => ref.invalidate(projectsProvider),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'No data for reports yet',
              message: 'Create a project to generate financial reports.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Project reports',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...projects.map(
                (p) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: InfraColors.royalBlue,
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text('PDF reports'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.projectReports(p.id), extra: p),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Profile / settings tab.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(organizationProfileProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const NavdreamLogo(
                    size: 56,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    showBorder: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orgAsync.value?.name ?? AppConstants.appName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          orgAsync.value?.ownerName ?? 'Owner',
                          style: const TextStyle(
                            color: InfraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (permissions.canEditSettings)
            _tile(
              context,
              Icons.settings_outlined,
              'Settings',
              AppRoutes.settings,
            ),
          if (permissions.canManageUsers)
            _tile(
              context,
              Icons.group_outlined,
              'Customers',
              AppRoutes.customers,
            ),
          if (permissions.canViewAuditLogs)
            _tile(
              context,
              Icons.manage_search_outlined,
              'Audit logs',
              AppRoutes.auditLogs,
            ),
          _tile(
            context,
            Icons.sync_outlined,
            'Sync queue',
            AppRoutes.syncQueue,
          ),
          _tile(context, Icons.lock_outline, 'App lock', AppRoutes.appLock),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: InfraColors.red),
            onPressed: () async {
              await ref.read(appSessionControllerProvider).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: InfraColors.navy),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
