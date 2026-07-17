import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../core/refresh/pull_to_refresh.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import 'infra_home_screen.dart' show ProjectCard;

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  final _searchController = TextEditingController();
  InfraProjectStatus? _statusFilter;
  String? _selectedProjectId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final query = _searchController.text.trim().toLowerCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1000) {
          return _desktopScaffold(projectsAsync, permissions, query);
        }
        return _mobileScaffold(projectsAsync, permissions, query);
      },
    );
  }

  Widget _mobileScaffold(
    AsyncValue<List<InfraProject>> projectsAsync,
    OrgPermissions permissions,
    String query,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: permissions.canManageProjects
          ? FloatingActionButton.extended(
              backgroundColor: InfraColors.navy,
              foregroundColor: Colors.white,
              onPressed: () => context.push(AppRoutes.newProject),
              icon: const Icon(Icons.add),
              label: const Text('Add Project'),
            )
          : null,
      body: Column(
        children: [
          _SearchAndFilters(
            searchController: _searchController,
            filterChipBuilder: _filterChip,
            onSearchChanged: (_) => setState(() {}),
          ),
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateView(
                message: 'Could not load projects: $error',
                onRetry: () => ref.invalidate(projectsProvider),
              ),
              data: (projects) {
                final filtered = _filteredProjects(projects, query);
                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ref.refreshWorkspace(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.search_off,
                          title: 'No matching projects',
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refreshWorkspace(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final project = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onLongPress: permissions.canManageProjects
                              ? () => _confirmDeleteProject(project)
                              : null,
                          child: ProjectCard(project: project),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopScaffold(
    AsyncValue<List<InfraProject>> projectsAsync,
    OrgPermissions permissions,
    String query,
  ) {
    return Scaffold(
      backgroundColor: InfraColors.background,
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: 'Could not load projects: $error',
          onRetry: () => ref.invalidate(projectsProvider),
        ),
        data: (projects) {
          final filtered = _filteredProjects(projects, query);
          if (filtered.isNotEmpty &&
              !filtered.any((p) => p.id == _selectedProjectId)) {
            _selectedProjectId = filtered.first.id;
          }
          final selected = filtered
              .where((p) => p.id == _selectedProjectId)
              .firstOrNull;

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 390,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Projects',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          if (permissions.canManageProjects)
                            IconButton.filled(
                              tooltip: 'Add project',
                              onPressed: () =>
                                  context.push(AppRoutes.newProject),
                              icon: const Icon(Icons.add),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search by name, city, category',
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip('All', null),
                            _filterChip('Active', InfraProjectStatus.active),
                            _filterChip(
                              'Planning',
                              InfraProjectStatus.planning,
                            ),
                            _filterChip('On Hold', InfraProjectStatus.onHold),
                            _filterChip(
                              'Completed',
                              InfraProjectStatus.completed,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? const EmptyState(
                                icon: Icons.search_off,
                                title: 'No matching projects',
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final project = filtered[index];
                                  return _DesktopProjectListTile(
                                    project: project,
                                    selected: project.id == selected?.id,
                                    onTap: () => setState(
                                      () => _selectedProjectId = project.id,
                                    ),
                                    onOpen: () => context.push(
                                      AppRoutes.projectDetail(project.id),
                                      extra: project,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: selected == null
                      ? const EmptyState(
                          icon: Icons.business_outlined,
                          title: 'Select a project',
                        )
                      : _DesktopProjectPreview(
                          project: selected,
                          canManageProjects: permissions.canManageProjects,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<InfraProject> _filteredProjects(
    List<InfraProject> projects,
    String query,
  ) {
    var filtered = projects;
    if (_statusFilter != null) {
      filtered = filtered.where((p) => p.status == _statusFilter).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered.where((p) {
        final hay =
            '${p.name} ${p.locationCity ?? ''} ${p.locationState ?? ''} ${p.category ?? ''}'
                .toLowerCase();
        return hay.contains(query);
      }).toList();
    }
    return filtered;
  }

  Widget _filterChip(String label, InfraProjectStatus? status) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = status),
      ),
    );
  }

  Future<void> _confirmDeleteProject(InfraProject project) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          'This will remove "${project.name}" along with all its investments, '
          'government funds, receipts, and expenses. This cannot be undone '
          'from the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: InfraColors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(infraRepositoryProvider).softDeleteProject(project.id);
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('"${project.name}" deleted.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete project: $error')),
      );
    }
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.searchController,
    required this.filterChipBuilder,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final Widget Function(String label, InfraProjectStatus? status)
  filterChipBuilder;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search by name, city, category',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              filterChipBuilder('All', null),
              filterChipBuilder('Active', InfraProjectStatus.active),
              filterChipBuilder('Planning', InfraProjectStatus.planning),
              filterChipBuilder('On Hold', InfraProjectStatus.onHold),
              filterChipBuilder('Completed', InfraProjectStatus.completed),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DesktopProjectListTile extends StatelessWidget {
  const _DesktopProjectListTile({
    required this.project,
    required this.selected,
    required this.onTap,
    required this.onOpen,
  });

  final InfraProject project;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final location = [
      project.locationCity,
      project.locationState,
    ].where((value) => (value ?? '').isNotEmpty).join(', ');

    return Material(
      color: selected
          ? InfraColors.royalBlue.withValues(alpha: 0.08)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? InfraColors.royalBlue : InfraColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onDoubleTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: _statusLabel(project.status),
                    dbStatus: _statusDb(project.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (location.isNotEmpty)
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: InfraColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 10),
              ProjectProgressBar(percent: project.financialProgressPercent),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopProjectPreview extends ConsumerWidget {
  const _DesktopProjectPreview({
    required this.project,
    required this.canManageProjects,
  });

  final InfraProject project;
  final bool canManageProjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(projectFinancialSummaryProvider(project.id));

    return Container(
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: InfraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusPill(
                            label: _statusLabel(project.status),
                            dbStatus: _statusDb(project.status),
                          ),
                          SizedBox(
                            width: 240,
                            child: ProjectProgressBar(
                              percent: project.financialProgressPercent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.projectDetail(project.id),
                    extra: project,
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
                if (canManageProjects) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.editProject(project.id),
                      extra: project,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: InfraColors.border),
          Expanded(
            child: summary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Could not load: $error')),
              data: (value) => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GridView.count(
                    crossAxisCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _PreviewMetric(
                        label: 'Estimated Cost',
                        paise: project.totalEstimatedCostPaise,
                        icon: Icons.request_quote_outlined,
                        color: InfraColors.navy,
                      ),
                      _PreviewMetric(
                        label: 'Net Investment',
                        paise: value.totalInvestmentPaise,
                        icon: Icons.savings_outlined,
                        color: InfraColors.gold,
                      ),
                      _PreviewMetric(
                        label: 'Govt Received',
                        paise: value.totalGovtReceivedPaise,
                        icon: Icons.account_balance_outlined,
                        color: InfraColors.green,
                      ),
                      _PreviewMetric(
                        label: 'Expenses',
                        paise: value.totalExpensePaise,
                        icon: Icons.receipt_long_outlined,
                        color: InfraColors.red,
                      ),
                      _PreviewMetric(
                        label: 'Balance',
                        paise: value.availableBalancePaise,
                        icon: Icons.account_balance_wallet_outlined,
                        color: InfraColors.royalBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _PreviewAction(
                        icon: Icons.person_add_alt_1_outlined,
                        label: 'Investment',
                        onPressed: () => context.push(
                          AppRoutes.newInvestment(project.id),
                          extra: project,
                        ),
                      ),
                      _PreviewAction(
                        icon: Icons.account_balance_outlined,
                        label: 'Govt Fund',
                        onPressed: () => context.push(
                          AppRoutes.newGovtFund(project.id),
                          extra: project,
                        ),
                      ),
                      _PreviewAction(
                        icon: Icons.receipt_long_outlined,
                        label: 'Expense',
                        onPressed: () => context.push(
                          AppRoutes.newExpense(project.id),
                          extra: project,
                        ),
                      ),
                      _PreviewAction(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Reports',
                        onPressed: () => context.push(
                          AppRoutes.projectReports(project.id),
                          extra: project,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({
    required this.label,
    required this.paise,
    required this.icon,
    required this.color,
  });

  final String label;
  final int paise;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InfraColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: InfraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          AmountText(paise: paise, compact: true, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: InfraColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewAction extends StatelessWidget {
  const _PreviewAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

String _statusLabel(InfraProjectStatus s) => switch (s) {
  InfraProjectStatus.planning => 'Planning',
  InfraProjectStatus.active => 'Active',
  InfraProjectStatus.onHold => 'On Hold',
  InfraProjectStatus.completed => 'Completed',
  InfraProjectStatus.cancelled => 'Cancelled',
};

String _statusDb(InfraProjectStatus s) => switch (s) {
  InfraProjectStatus.planning => 'planning',
  InfraProjectStatus.active => 'active',
  InfraProjectStatus.onHold => 'on_hold',
  InfraProjectStatus.completed => 'completed',
  InfraProjectStatus.cancelled => 'cancelled',
};
