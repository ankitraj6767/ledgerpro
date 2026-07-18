import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../core/money/money.dart';
import '../../../core/refresh/pull_to_refresh.dart';
import '../../../core/richtext/rich_text_document.dart';
import '../../../core/richtext/rich_text_view.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/donut_expense_chart.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import '../data/infra_report_service.dart';
import 'infra_forms.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProject,
    this.initialTabIndex = 0,
  });

  final String projectId;
  final InfraProject? initialProject;

  /// Which tab to open first (0=Overview, 1=Investors, 2=Government Funds,
  /// 3=Expenses, 4=Reports). Defaults to Overview.
  final int initialTabIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final project =
        projectsAsync.value?.where((p) => p.id == projectId).firstOrNull ??
        initialProject;
    final permissions = ref.watch(currentOrgPermissionsProvider);

    if (project == null) {
      if (projectsAsync.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Project not found',
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      initialIndex: initialTabIndex.clamp(0, 4),
      child: Scaffold(
        backgroundColor: InfraColors.background,
        appBar: AppBar(
          title: const Text('Project Details'),
          actions: [
            if (permissions.canManageProjects)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && permissions.canManageProjects) {
                    context.push(
                      AppRoutes.editProject(project.id),
                      extra: project,
                    );
                  } else if (value == 'delete' &&
                      permissions.canManageProjects) {
                    _confirmDeleteProject(context, ref, project);
                  }
                },
                itemBuilder: (context) => [
                  if (permissions.canManageProjects)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit project'),
                    ),
                  if (permissions.canManageProjects)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete project',
                        style: TextStyle(color: InfraColors.red),
                      ),
                    ),
                ],
              ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: InfraColors.gold,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Investors'),
              Tab(text: 'Government Funds'),
              Tab(text: 'Expenses'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(project: project),
            _InvestorsTab(project: project),
            _GovtFundsTab(project: project),
            _ExpensesTab(project: project),
            _ReportsTab(project: project),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProject(
    BuildContext context,
    WidgetRef ref,
    InfraProject project,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          'This will remove "${project.name}" along with all its investments, '
          'government funds, receipts, expenses, and notes. This cannot be '
          'undone from the app.',
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
      // Leave the detail screen after deletion.
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.projects);
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete project: $error')),
      );
    }
  }
}

class _ProjectHeaderCard extends StatelessWidget {
  const _ProjectHeaderCard({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    final location = [
      project.locationCity,
      project.locationState,
    ].where((e) => (e ?? '').isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InfraColors.border),
        boxShadow: [
          BoxShadow(
            color: InfraColors.navy.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: InfraColors.royalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.apartment,
                  color: InfraColors.royalBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: InfraColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: InfraColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              StatusPill(
                label: _statusLabel(project.status),
                dbStatus: _statusDb(project.status),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProjectProgressBar(
                  percent: project.financialProgressPercent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _statusLabel(InfraProjectStatus s) => switch (s) {
    InfraProjectStatus.planning => 'Planning',
    InfraProjectStatus.active => 'Active',
    InfraProjectStatus.onHold => 'On Hold',
    InfraProjectStatus.completed => 'Completed',
    InfraProjectStatus.cancelled => 'Cancelled',
  };

  static String _statusDb(InfraProjectStatus s) => switch (s) {
    InfraProjectStatus.planning => 'planning',
    InfraProjectStatus.active => 'active',
    InfraProjectStatus.onHold => 'on_hold',
    InfraProjectStatus.completed => 'completed',
    InfraProjectStatus.cancelled => 'cancelled',
  };
}

// ---------------------------------------------------------------------------
// Overview tab
// ---------------------------------------------------------------------------
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(projectFinancialSummaryProvider(project.id));
    final expensesAsync = ref.watch(projectExpensesProvider(project.id));
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refreshProject(project.id),
      child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _ProjectHeaderCard(project: project),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Government Funds',
          icon: Icons.account_balance_outlined,
          child: summaryAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Error: $e'),
            data: (s) => Column(
              children: [
                _kv('Amount Sanctioned', s.totalGovtSanctionedPaise),
                _kv(
                  'Received Till Date',
                  s.totalGovtReceivedPaise,
                  color: InfraColors.green,
                ),
                _kv(
                  'Pending Amount',
                  s.pendingGovtPaise,
                  color: InfraColors.orange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Financial Summary',
          icon: Icons.summarize_outlined,
          child: summaryAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Error: $e'),
            data: (s) {
              final balanceColor = s.availableBalancePaise >= 0
                  ? InfraColors.green
                  : InfraColors.red;
              return Column(
                children: [
                  _FundingHealthPanel(summary: s),
                  const SizedBox(height: 14),
                  _kv(
                    'Estimated Project Cost',
                    project.totalEstimatedCostPaise,
                    color: InfraColors.navy,
                  ),
                  _kv(
                    'Net Investment',
                    s.totalInvestmentPaise,
                    color: InfraColors.gold,
                  ),
                  _kv(
                    'Government Fund Received',
                    s.totalGovtReceivedPaise,
                    color: InfraColors.green,
                  ),
                  _kv(
                    'Total Expenses',
                    s.totalExpensePaise,
                    color: InfraColors.red,
                  ),
                  const Divider(height: 22),
                  _kv(
                    'Available Balance',
                    s.availableBalancePaise,
                    color: balanceColor,
                    bold: true,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Expenses Summary',
          icon: Icons.pie_chart_outline,
          child: expensesAsync.when(
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e'),
            data: (expenses) {
              if (expenses.isEmpty) {
                return const Text('No expenses recorded yet.');
              }
              final byCategory = <String, int>{};
              for (final e in expenses) {
                byCategory[e.category] =
                    (byCategory[e.category] ?? 0) + e.amountPaise;
              }
              final entries = byCategory.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final slices = <DonutSlice>[];
              for (var i = 0; i < entries.length; i++) {
                slices.add(
                  DonutSlice(
                    label: entries[i].key,
                    amountPaise: entries[i].value,
                    color: DonutExpenseChart
                        .palette[i % DonutExpenseChart.palette.length],
                  ),
                );
              }
              return DonutExpenseChart(slices: slices);
            },
          ),
        ),
        const SizedBox(height: 12),
        _QuickActions(project: project, permissions: permissions),
      ],
      ),
    );
  }

  Widget _kv(String label, int paise, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InfraColors.textSecondary,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              Money.fromPaise(paise).formatInr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color ?? InfraColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FundingHealthPanel extends StatelessWidget {
  const _FundingHealthPanel({required this.summary});

  final ProjectFinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    final cashIn = summary.cashInPaise;
    final expenses = summary.totalExpensePaise;
    final balance = summary.availableBalancePaise;
    final balanceColor = summary.availableBalancePaise >= 0
        ? InfraColors.green
        : InfraColors.red;
    final spentRatio = cashIn <= 0
        ? (expenses > 0 ? 1.0 : 0.0)
        : (expenses / cashIn).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: balanceColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  balance >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: balanceColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Funding Health',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InfraColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  balance >= 0 ? 'Surplus' : 'Shortfall',
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              Money.fromPaise(balance).formatInr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: balanceColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Net investment + govt received - expenses',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InfraColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: spentRatio,
                backgroundColor: InfraColors.border.withValues(alpha: 0.8),
                valueColor: AlwaysStoppedAnimation<Color>(
                  balance >= 0 ? InfraColors.green : InfraColors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _compactMetric('Cash In', cashIn, InfraColors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _compactMetric('Expenses', expenses, InfraColors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactMetric(String label, int paise, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: InfraColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          Money.fromPaise(paise).formatCompactInr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.project, required this.permissions});

  final InfraProject project;
  final OrgPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (permissions.canAddExpense)
        QuickActionCard(
          icon: Icons.add_card_outlined,
          label: 'Add Expense',
          color: InfraColors.royalBlue,
          onTap: () =>
              context.push(AppRoutes.newExpense(project.id), extra: project),
        ),
      if (permissions.canManageFunds)
        QuickActionCard(
          icon: Icons.account_balance_outlined,
          label: 'Add Fund',
          color: InfraColors.green,
          onTap: () =>
              context.push(AppRoutes.newGovtFund(project.id), extra: project),
        ),
      if (permissions.canManageInvestments)
        QuickActionCard(
          icon: Icons.savings_outlined,
          label: 'Add Investment',
          color: InfraColors.gold,
          onTap: () =>
              context.push(AppRoutes.newInvestment(project.id), extra: project),
        ),
      if (permissions.canAddNotes)
        QuickActionCard(
          icon: Icons.note_add_outlined,
          label: 'Add Note',
          color: InfraColors.orange,
          onTap: () => _addNote(context, project),
        ),
    ];

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    actions[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote(BuildContext context, InfraProject project) async {
    await context.push(AppRoutes.projectNotes(project.id), extra: project);
  }
}

// ---------------------------------------------------------------------------
// Investors tab
// ---------------------------------------------------------------------------
class _FinanceSearchBar extends StatelessWidget {
  const _FinanceSearchBar({
    required this.controller,
    required this.hintText,
    required this.query,
    required this.onChanged,
    required this.onClear,
    this.onAdd,
  });

  final TextEditingController controller;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final isFiltering = query.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controlHeight = constraints.maxWidth < 360 ? 42.0 : 44.0;
          final search = _PremiumSearchField(
            controller: controller,
            hintText: hintText,
            height: controlHeight,
            isFiltering: isFiltering,
            onChanged: onChanged,
            onClear: onClear,
          );
          final addButton = onAdd == null
              ? null
              : _PremiumAddButton(onPressed: onAdd!, size: controlHeight);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: search),
              if (addButton != null) ...[const SizedBox(width: 10), addButton],
            ],
          );
        },
      ),
    );
  }
}

class _PremiumSearchField extends StatelessWidget {
  const _PremiumSearchField({
    required this.controller,
    required this.hintText,
    required this.height,
    required this.isFiltering,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final double height;
  final bool isFiltering;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: InfraColors.border),
        boxShadow: [
          BoxShadow(
            color: InfraColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: InfraColors.royalBlue,
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                cursorColor: InfraColors.royalBlue,
                cursorHeight: 16,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: InfraColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11.5,
                    height: 1.1,
                  ),
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  color: InfraColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  height: 1.1,
                ),
              ),
            ),
          ),
          if (isFiltering)
            Tooltip(
              message: 'Clear search',
              child: IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: InfraColors.textSecondary,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}

class _PremiumAddButton extends StatelessWidget {
  const _PremiumAddButton({required this.onPressed, required this.size});

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add',
      child: Semantics(
        button: true,
        label: 'Add',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: InfraColors.navy,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: InfraColors.navy.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            color: Colors.white,
            iconSize: 24,
            splashRadius: size / 2,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoFinanceMatches extends StatelessWidget {
  const _NoFinanceMatches({
    required this.icon,
    required this.title,
    required this.query,
    required this.messageTail,
  });

  final IconData icon;
  final String title;
  final String query;
  final String messageTail;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: title,
      message: 'No results for "$query". $messageTail',
    );
  }
}

bool _matchesFinanceSearch(Iterable<Object?> fields, String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return true;

  final haystack = fields
      .where((value) => value != null)
      .map((value) => value.toString().toLowerCase())
      .join(' ');

  return query
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .every(haystack.contains);
}

String _searchDate(DateTime? value) {
  if (value == null) return '';
  return '${DateFormat('dd MMM yyyy').format(value)} ${DateFormat('yyyy-MM-dd').format(value)}';
}

class _InvestorsTab extends ConsumerStatefulWidget {
  const _InvestorsTab({required this.project});

  final InfraProject project;

  @override
  ConsumerState<_InvestorsTab> createState() => _InvestorsTabState();
}

class _InvestorsTabState extends ConsumerState<_InvestorsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() => _query = value);

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final investmentsAsync = ref.watch(
      projectInvestmentsProvider(widget.project.id),
    );
    final returnsAsync = ref.watch(
      investmentReturnsProvider(widget.project.id),
    );
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return Column(
      children: [
        Expanded(
          child: investmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateView(
              message: 'Could not load investments: $e',
              onRetry: () =>
                  ref.invalidate(projectInvestmentsProvider(widget.project.id)),
            ),
            data: (investments) {
              final returns = returnsAsync.value ?? <InvestmentReturn>[];
              // Group investments by investor
              final grouped = <String, _InvestorSummary>{};
              for (final inv in investments) {
                final key = inv.investorId;
                grouped.putIfAbsent(
                  key,
                  () => _InvestorSummary(
                    investorId: key,
                    investorName: inv.investorName ?? 'Investor',
                  ),
                );
                grouped[key]!.investments.add(inv);
                grouped[key]!.totalInvestedPaise += inv.amountPaise;
              }
              // Add returns to groups
              for (final ret in returns) {
                final key = ret.investorId;
                grouped.putIfAbsent(
                  key,
                  () => _InvestorSummary(
                    investorId: key,
                    investorName: ret.investorName ?? 'Investor',
                  ),
                );
                grouped[key]!.returns.add(ret);
                grouped[key]!.totalReturnedPaise += ret.amountPaise;
              }
              final summaries = grouped.values.toList()
                ..sort(
                  (a, b) => a.investorName
                      .toLowerCase()
                      .compareTo(b.investorName.toLowerCase()),
                );
              final filtered = summaries
                  .where((s) => _matchesInvestorSummary(s))
                  .toList(growable: false);
              final totalNet = filtered.fold<int>(
                0,
                (sum, s) => sum + s.netInvestmentPaise,
              );
              return Column(
                children: [
                  _FinanceSearchBar(
                    controller: _searchController,
                    hintText: 'Search investors, name, amount',
                    query: _query,
                    onChanged: _setQuery,
                    onClear: _clearSearch,
                    onAdd: permissions.canManageInvestments
                        ? () => context.push(
                            AppRoutes.newInvestment(widget.project.id),
                            extra: widget.project,
                          )
                        : null,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref.refreshProject(widget.project.id),
                      child: investments.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              EmptyState(
                                icon: Icons.savings_outlined,
                                title: 'No investments yet',
                                message:
                                    'Add an investor contribution to this project.',
                              ),
                            ],
                          )
                        : filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              _NoFinanceMatches(
                                icon: Icons.savings_outlined,
                                title: 'No matching investors',
                                query: _query,
                                messageTail:
                                    'Try investor name, payment mode, reference, or amount.',
                              ),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                            children: [
                              ...filtered.map(
                                (summary) => Card(
                                  child: ListTile(
                                    onTap: () => _showInvestorHistory(
                                      context,
                                      summary,
                                      permissions.canManageInvestments,
                                    ),
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFFFF4D6),
                                      child: Icon(
                                        Icons.person,
                                        color: InfraColors.gold,
                                      ),
                                    ),
                                    title: Text(
                                      summary.investorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text(
                                      summary.totalReturnedPaise > 0
                                          ? '${summary.investments.length} investment(s) · ${Money.fromPaise(summary.totalReturnedPaise).formatInr()} returned'
                                          : '${summary.investments.length} investment(s)',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AmountText(
                                          paise: summary.netInvestmentPaise,
                                          color: InfraColors.gold,
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: InfraColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Card(
                                color: InfraColors.navy,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _query.trim().isEmpty
                                            ? 'Net Investment'
                                            : 'Filtered Investment',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        Money.fromPaise(totalNet).formatInr(),
                                        style: const TextStyle(
                                          color: InfraColors.gold,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  bool _matchesInvestorSummary(_InvestorSummary summary) {
    final fields = <Object?>[
      summary.investorName,
      Money.fromPaise(summary.netInvestmentPaise).formatInr(),
      (summary.netInvestmentPaise / 100).toStringAsFixed(2),
      ...summary.investments.expand((i) => [
            i.paymentMode,
            i.referenceNumber,
            richTextToPlain(i.notes),
            _searchDate(i.investmentDate),
          ]),
    ];
    return _matchesFinanceSearch(fields, _query);
  }

  void _showInvestorHistory(
    BuildContext context,
    _InvestorSummary summary,
    bool canManage,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _InvestorHistoryScreen(
          project: widget.project,
          summary: summary,
          canManage: canManage,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Investor summary helper + history screen
// ---------------------------------------------------------------------------
class _InvestorSummary {
  _InvestorSummary({required this.investorId, required this.investorName});

  final String investorId;
  final String investorName;
  final List<ProjectInvestment> investments = [];
  final List<InvestmentReturn> returns = [];
  int totalInvestedPaise = 0;
  int totalReturnedPaise = 0;

  int get netInvestmentPaise => totalInvestedPaise - totalReturnedPaise;
}

class _InvestorHistoryScreen extends ConsumerStatefulWidget {
  const _InvestorHistoryScreen({
    required this.project,
    required this.summary,
    required this.canManage,
  });

  final InfraProject project;
  final _InvestorSummary summary;
  final bool canManage;

  @override
  ConsumerState<_InvestorHistoryScreen> createState() =>
      _InvestorHistoryScreenState();
}

class _InvestorHistoryScreenState
    extends ConsumerState<_InvestorHistoryScreen> {
  bool _generatingPdf = false;

  @override
  Widget build(BuildContext context) {
    // Re-watch to stay fresh
    final investmentsAsync = ref.watch(
      projectInvestmentsProvider(widget.project.id),
    );
    final returnsAsync = ref.watch(
      investmentReturnsProvider(widget.project.id),
    );

    final investments = (investmentsAsync.value ?? widget.summary.investments)
        .where((i) => i.investorId == widget.summary.investorId)
        .toList()
      ..sort((a, b) =>
          (b.investmentDate ?? DateTime(0))
              .compareTo(a.investmentDate ?? DateTime(0)));
    final returns = (returnsAsync.value ?? widget.summary.returns)
        .where((r) => r.investorId == widget.summary.investorId)
        .toList()
      ..sort((a, b) =>
          (b.returnDate ?? DateTime(0))
              .compareTo(a.returnDate ?? DateTime(0)));

    final totalInvested =
        investments.fold<int>(0, (sum, i) => sum + i.amountPaise);
    final totalReturned =
        returns.fold<int>(0, (sum, r) => sum + r.amountPaise);
    final netInvestment = totalInvested - totalReturned;
    final hasRecords = investments.isNotEmpty || returns.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.summary.investorName),
        actions: [
          if (hasRecords)
            _generatingPdf
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: 'Generate PDF statement',
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    onPressed: () => _generatePdf(investments, returns),
                  ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          Card(
            color: InfraColors.navy,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Total Invested',
                    paise: totalInvested,
                    color: InfraColors.gold,
                  ),
                  if (totalReturned > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Total Returned',
                      paise: totalReturned,
                      color: Colors.redAccent,
                    ),
                  ],
                  const Divider(color: Colors.white24, height: 20),
                  _SummaryRow(
                    label: 'Net Investment',
                    paise: netInvestment,
                    color: InfraColors.gold,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Investment history
          Row(
            children: [
              const Icon(Icons.trending_up, color: InfraColors.green, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Investments',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              if (widget.canManage)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            InvestmentFormScreen(project: widget.project),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (investments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No investments recorded.'),
            )
          else
            ...investments.map((inv) => _InvestmentHistoryTile(
                  investment: inv,
                  project: widget.project,
                  canManage: widget.canManage,
                )),
          const SizedBox(height: 20),
          // Returns history
          Row(
            children: [
              const Icon(Icons.trending_down, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Returns',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              if (widget.canManage)
                TextButton.icon(
                  onPressed: _addReturn,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Record Return'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (returns.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No returns recorded.'),
            )
          else
            ...returns.map((ret) => _ReturnHistoryTile(
                  returnEntry: ret,
                  project: widget.project,
                  canManage: widget.canManage,
                )),
        ],
      ),
    );
  }

  void _addReturn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _InvestmentReturnFormScreen(
          project: widget.project,
          investorId: widget.summary.investorId,
          investorName: widget.summary.investorName,
        ),
      ),
    );
  }

  Future<void> _generatePdf(
    List<ProjectInvestment> investments,
    List<InvestmentReturn> returns,
  ) async {
    setState(() => _generatingPdf = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      const service = InfraReportService();
      final file = await service.investorStatementPdf(
        organizationName: org.name,
        project: widget.project,
        investorName: widget.summary.investorName,
        investments: investments,
        returns: returns,
      );
      await service.share(file, isPdf: true);
      messenger.showSnackBar(
        const SnackBar(content: Text('Investor statement generated.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.paise,
    required this.color,
    this.bold = false,
  });

  final String label;
  final int paise;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            fontSize: bold ? 15 : 13,
          ),
        ),
        Text(
          Money.fromPaise(paise).formatInr(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: bold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

class _InvestmentHistoryTile extends ConsumerWidget {
  const _InvestmentHistoryTile({
    required this.investment,
    required this.project,
    required this.canManage,
  });

  final ProjectInvestment investment;
  final InfraProject project;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        onTap: () => _showInvestmentDetails(
          context,
          investment,
          onGeneratePdf: () =>
              _shareInvestmentPdf(context, ref, project, investment),
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          radius: 18,
          child: Icon(Icons.arrow_downward, color: InfraColors.green, size: 18),
        ),
        title: Text(
          Money.fromPaise(investment.amountPaise).formatInr(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        trailing: canManage
            ? _EntityMenu(
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => InvestmentFormScreen(
                      project: project,
                      investment: investment,
                    ),
                  ),
                ),
                onDelete: () => _confirmDelete(
                  context,
                  ref,
                  title: 'Delete investment?',
                  message:
                      'Remove this investment of ${Money.fromPaise(investment.amountPaise).formatInr()}?',
                  onConfirm: () async {
                    await ref
                        .read(infraRepositoryProvider)
                        .deleteInvestment(investment.id);
                    ref.invalidate(
                        projectInvestmentsProvider(project.id));
                    ref.invalidate(
                        projectInvestorsProvider(project.id));
                    ref.invalidate(
                        projectFinancialSummaryProvider(project.id));
                    ref.invalidate(projectsProvider);
                    ref.invalidate(dashboardSummaryProvider);
                    ref.invalidate(investorsProvider);
                  },
                ),
              )
            : investment.createdAt != null
                ? Text(
                    DateFormat('dd/MM/yy').format(investment.createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: InfraColors.textSecondary,
                    ),
                  )
                : null,
      ),
    );
  }
}

class _ReturnHistoryTile extends ConsumerWidget {
  const _ReturnHistoryTile({
    required this.returnEntry,
    required this.project,
    required this.canManage,
  });

  final InvestmentReturn returnEntry;
  final InfraProject project;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        onTap: () => _showReturnDetails(
          context,
          returnEntry,
          onGeneratePdf: () =>
              _shareReturnPdf(context, ref, project, returnEntry),
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFEBEE),
          radius: 18,
          child:
              Icon(Icons.arrow_upward, color: Colors.redAccent, size: 18),
        ),
        title: Text(
          Money.fromPaise(returnEntry.amountPaise).formatInr(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        trailing: canManage
            ? _EntityMenu(
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _InvestmentReturnFormScreen(
                      project: project,
                      investorId: returnEntry.investorId,
                      investorName: returnEntry.investorName ?? 'Investor',
                      existing: returnEntry,
                    ),
                  ),
                ),
                onDelete: () => _confirmDelete(
                  context,
                  ref,
                  title: 'Delete return?',
                  message:
                      'Remove this return of ${Money.fromPaise(returnEntry.amountPaise).formatInr()}?',
                  onConfirm: () async {
                    await ref
                        .read(infraRepositoryProvider)
                        .deleteInvestmentReturn(returnEntry.id);
                    ref.invalidate(investmentReturnsProvider(project.id));
                    ref.invalidate(
                        projectFinancialSummaryProvider(project.id));
                    ref.invalidate(projectsProvider);
                    ref.invalidate(dashboardSummaryProvider);
                  },
                ),
              )
            : returnEntry.createdAt != null
                ? Text(
                    DateFormat('dd/MM/yy').format(returnEntry.createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: InfraColors.textSecondary,
                    ),
                  )
                : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Investment Return form
// ---------------------------------------------------------------------------
class _InvestmentReturnFormScreen extends ConsumerStatefulWidget {
  const _InvestmentReturnFormScreen({
    required this.project,
    required this.investorId,
    required this.investorName,
    this.existing,
  });

  final InfraProject project;
  final String investorId;
  final String investorName;
  final InvestmentReturn? existing;

  @override
  ConsumerState<_InvestmentReturnFormScreen> createState() =>
      _InvestmentReturnFormScreenState();
}

class _InvestmentReturnFormScreenState
    extends ConsumerState<_InvestmentReturnFormScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  String _paymentMode = 'bank';
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _amount.text = (existing.amountPaise / 100).toStringAsFixed(2);
      _reference.text = existing.referenceNumber ?? '';
      _notes.text = existing.notes ?? '';
      _paymentMode = existing.paymentMode;
      _date = existing.returnDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Return' : 'Record Return'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Investor',
              prefixIcon: Icon(Icons.person_outline),
            ),
            child: Text(
              widget.investorName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          _returnAmountField(_amount),
          const SizedBox(height: 12),
          _returnPaymentModeField(
            _paymentMode,
            (m) => setState(() => _paymentMode = m),
          ),
          const SizedBox(height: 12),
          _returnTextField(_reference, 'Reference number', Icons.tag_outlined),
          const SizedBox(height: 12),
          _returnDateField(
            'Return date',
            _date,
            (d) => setState(() => _date = d),
          ),
          const SizedBox(height: 12),
          _returnTextField(
            _notes,
            'Notes',
            Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isEditing ? 'Update Return' : 'Save Return'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    int amount;
    try {
      amount = InfraRepository.parsePaise(_amount.text);
      if (amount <= 0) throw const FormatException('Amount required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid return amount.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(infraRepositoryProvider);
      final reference =
          _reference.text.trim().isEmpty ? null : _reference.text.trim();
      final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      if (_isEditing) {
        await repo.updateInvestmentReturn(
          returnId: widget.existing!.id,
          amountPaise: amount,
          date: _date,
          paymentMode: _paymentMode,
          referenceNumber: reference,
          notes: notes,
        );
      } else {
        await repo.addInvestmentReturn(
          projectId: widget.project.id,
          investorId: widget.investorId,
          amountPaise: amount,
          date: _date,
          paymentMode: _paymentMode,
          referenceNumber: reference,
          notes: notes,
        );
      }
      ref.invalidate(investmentReturnsProvider(widget.project.id));
      ref.invalidate(projectInvestmentsProvider(widget.project.id));
      ref.invalidate(projectFinancialSummaryProvider(widget.project.id));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Return updated.' : 'Return recorded.'),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save return: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

Widget _returnAmountField(TextEditingController c) => TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Return amount (₹)',
        prefixIcon: Icon(Icons.currency_rupee),
      ),
    );

Widget _returnPaymentModeField(String value, ValueChanged<String> onChanged) {
  const modes = ['cash', 'bank', 'upi', 'cheque', 'card', 'other'];
  return DropdownButtonFormField<String>(
    initialValue: value,
    decoration: const InputDecoration(
      labelText: 'Payment mode',
      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
    ),
    items: modes
        .map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase())))
        .toList(),
    onChanged: (v) => onChanged(v ?? value),
  );
}

Widget _returnTextField(
  TextEditingController c,
  String label,
  IconData icon, {
  int maxLines = 1,
}) =>
    TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );

Widget _returnDateField(
  String label,
  DateTime value,
  ValueChanged<DateTime> onChanged,
) {
  return Builder(
    builder: (context) => InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Government Funds tab
// ---------------------------------------------------------------------------
class _GovtFundsTab extends ConsumerStatefulWidget {
  const _GovtFundsTab({required this.project});

  final InfraProject project;

  @override
  ConsumerState<_GovtFundsTab> createState() => _GovtFundsTabState();
}

class _GovtFundsTabState extends ConsumerState<_GovtFundsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() => _query = value);

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _shareGovernmentFundPdf(GovernmentFund fund) async {
    try {
      final repo = ref.read(infraRepositoryProvider);
      final org = await ref.read(infraWorkspaceProvider.future);
      final receipts = await repo.fetchReceipts(fund.id);
      const service = InfraReportService();
      final file = await service.governmentFundDetailPdf(
        organizationName: org.name,
        project: widget.project,
        fund: fund,
        receipts: receipts,
      );
      await service.share(file, isPdf: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Government fund PDF generated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not generate PDF: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundsAsync = ref.watch(governmentFundsProvider(widget.project.id));
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return Column(
      children: [
        Expanded(
          child: fundsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateView(
              message: 'Could not load funds: $e',
              onRetry: () =>
                  ref.invalidate(governmentFundsProvider(widget.project.id)),
            ),
            data: (funds) {
              final filtered = funds
                  .where(_matchesFund)
                  .toList(growable: false);
              return Column(
                children: [
                  _FinanceSearchBar(
                    controller: _searchController,
                    hintText: 'Search funds, department, scheme',
                    query: _query,
                    onChanged: _setQuery,
                    onClear: _clearSearch,
                    onAdd: permissions.canManageFunds
                        ? () => context.push(
                            AppRoutes.newGovtFund(widget.project.id),
                            extra: widget.project,
                          )
                        : null,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref.refreshProject(widget.project.id),
                      child: funds.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              EmptyState(
                                icon: Icons.account_balance_outlined,
                                title: 'No government funds yet',
                                message:
                                    'Add a sanctioned fund to track receipts.',
                              ),
                            ],
                          )
                        : filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              _NoFinanceMatches(
                                icon: Icons.account_balance_outlined,
                                title: 'No matching funds',
                                query: _query,
                                messageTail:
                                    'Try department, scheme, sanction order, status, or amount.',
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final fund = filtered[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _showGovernmentFundDetails(
                                    context,
                                    widget.project.id,
                                    fund,
                                    onGeneratePdf: () =>
                                        _shareGovernmentFundPdf(fund),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                fund.departmentName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            StatusPill(
                                              label: _fundStatusLabel(
                                                fund.status,
                                              ),
                                              dbStatus: _fundStatusDb(
                                                fund.status,
                                              ),
                                            ),
                                            if (permissions.canManageFunds)
                                              _EntityMenu(
                                                onEdit: () =>
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute<void>(
                                                        builder: (_) =>
                                                            GovtFundFormScreen(
                                                              project: widget
                                                                  .project,
                                                              fund: fund,
                                                            ),
                                                      ),
                                                    ),
                                                onDelete: () => _confirmDelete(
                                                  context,
                                                  ref,
                                                  title:
                                                      'Delete government fund?',
                                                  message:
                                                      'This removes "${fund.departmentName}" and all '
                                                      'its receipts, and reverses the project totals.',
                                                  onConfirm: () async {
                                                    await ref
                                                        .read(
                                                          infraRepositoryProvider,
                                                        )
                                                        .deleteGovernmentFund(
                                                          fund.id,
                                                        );
                                                    ref.invalidate(
                                                      governmentFundsProvider(
                                                        widget.project.id,
                                                      ),
                                                    );
                                                    ref.invalidate(
                                                      projectFinancialSummaryProvider(
                                                        widget.project.id,
                                                      ),
                                                    );
                                                    ref.invalidate(
                                                      projectsProvider,
                                                    );
                                                    ref.invalidate(
                                                      dashboardSummaryProvider,
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                        if ((fund.schemeName ?? '').isNotEmpty)
                                          Text(
                                            fund.schemeName!,
                                            style: const TextStyle(
                                              color: InfraColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        _row(
                                          'Sanctioned',
                                          fund.amountSanctionedPaise,
                                        ),
                                        _row(
                                          'Received',
                                          fund.amountReceivedPaise,
                                          color: InfraColors.green,
                                        ),
                                        _row(
                                          'Pending',
                                          fund.pendingAmountPaise,
                                          color: InfraColors.orange,
                                        ),
                                        const SizedBox(height: 8),
                                        if (permissions.canManageFunds)
                                          OutlinedButton.icon(
                                            onPressed: () => context.push(
                                              AppRoutes.newGovtReceipt(
                                                widget.project.id,
                                              ),
                                              extra: fund,
                                            ),
                                            icon: const Icon(
                                              Icons.add,
                                              size: 18,
                                            ),
                                            label: const Text('Add Receipt'),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  bool _matchesFund(GovernmentFund fund) {
    return _matchesFinanceSearch([
      fund.departmentName,
      fund.schemeName,
      fund.sanctionOrderNumber,
      richTextToPlain(fund.notes),
      _fundStatusLabel(fund.status),
      Money.fromPaise(fund.amountSanctionedPaise).formatInr(),
      Money.fromPaise(fund.amountReceivedPaise).formatInr(),
      Money.fromPaise(fund.pendingAmountPaise).formatInr(),
      (fund.amountSanctionedPaise / 100).toStringAsFixed(2),
      (fund.amountReceivedPaise / 100).toStringAsFixed(2),
      _searchDate(fund.sanctionDate),
      _searchDate(fund.lastReceivedDate),
    ], _query);
  }

  Widget _row(String label, int paise, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: InfraColors.textSecondary)),
          Text(
            Money.fromPaise(paise).formatInr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color ?? InfraColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _fundStatusLabel(GovtFundStatus s) => switch (s) {
    GovtFundStatus.sanctioned => 'Sanctioned',
    GovtFundStatus.partiallyReceived => 'Partial',
    GovtFundStatus.fullyReceived => 'Received',
    GovtFundStatus.delayed => 'Delayed',
    GovtFundStatus.cancelled => 'Cancelled',
  };

  String _fundStatusDb(GovtFundStatus s) => switch (s) {
    GovtFundStatus.sanctioned => 'sanctioned',
    GovtFundStatus.partiallyReceived => 'partially_received',
    GovtFundStatus.fullyReceived => 'fully_received',
    GovtFundStatus.delayed => 'delayed',
    GovtFundStatus.cancelled => 'cancelled',
  };
}

// ---------------------------------------------------------------------------
// Expenses tab
// ---------------------------------------------------------------------------

/// How the flat expense list is ordered.
enum _ExpenseSortKey { serial, date, name }

class _ExpensesTab extends ConsumerStatefulWidget {
  const _ExpensesTab({required this.project});

  final InfraProject project;

  @override
  ConsumerState<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends ConsumerState<_ExpensesTab> {
  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _selectedExpenseIds = {};

  // Sorting: default to newest expense first (most common expectation).
  _ExpenseSortKey _sortKey = _ExpenseSortKey.date;
  bool _sortAscending = false;

  static bool _defaultAscendingFor(_ExpenseSortKey key) {
    switch (key) {
      case _ExpenseSortKey.date:
        return false; // newest first
      case _ExpenseSortKey.name:
        return true; // A → Z
      case _ExpenseSortKey.serial:
        return true; // 1, 2, 3 …
    }
  }

  /// Stable serial numbers from creation order (oldest = #1) so the S.No shown
  /// on each row — and the "S.No" sort — stay consistent regardless of the
  /// current ordering or any active filter.
  Map<String, int> _expenseSerials(List<ProjectExpense> all) {
    final ordered = [...all]..sort((a, b) {
      final da = a.createdAt ?? a.expenseDate ?? DateTime(0);
      final db = b.createdAt ?? b.expenseDate ?? DateTime(0);
      return da.compareTo(db);
    });
    final map = <String, int>{};
    for (var i = 0; i < ordered.length; i++) {
      map[ordered[i].id] = i + 1;
    }
    return map;
  }

  List<ProjectExpense> _sortExpenses(
    List<ProjectExpense> items,
    Map<String, int> serialOf,
  ) {
    int compare(ProjectExpense a, ProjectExpense b) {
      switch (_sortKey) {
        case _ExpenseSortKey.date:
          final da = a.expenseDate ?? DateTime(0);
          final db = b.expenseDate ?? DateTime(0);
          final byDate = da.compareTo(db);
          return byDate != 0
              ? byDate
              : (serialOf[a.id] ?? 0).compareTo(serialOf[b.id] ?? 0);
        case _ExpenseSortKey.name:
          final byName = a.category.toLowerCase().compareTo(
            b.category.toLowerCase(),
          );
          return byName != 0
              ? byName
              : (serialOf[a.id] ?? 0).compareTo(serialOf[b.id] ?? 0);
        case _ExpenseSortKey.serial:
          return (serialOf[a.id] ?? 0).compareTo(serialOf[b.id] ?? 0);
      }
    }

    final list = [...items]
      ..sort((a, b) => _sortAscending ? compare(a, b) : -compare(a, b));
    return list;
  }

  Widget _buildSortControl() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<_ExpenseSortKey>(
              segments: const [
                ButtonSegment(
                  value: _ExpenseSortKey.date,
                  label: Text('Date'),
                ),
                ButtonSegment(
                  value: _ExpenseSortKey.name,
                  label: Text('Name'),
                ),
                ButtonSegment(
                  value: _ExpenseSortKey.serial,
                  label: Text('S.No'),
                ),
              ],
              selected: {_sortKey},
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
              onSelectionChanged: (selection) {
                setState(() {
                  _sortKey = selection.first;
                  _sortAscending = _defaultAscendingFor(_sortKey);
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: _sortAscending ? 'Ascending' : 'Descending',
            child: Material(
              color: InfraColors.navy.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _sortAscending = !_sortAscending),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    _sortAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 20,
                    color: InfraColors.navy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serialBadge(int serial) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: InfraColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$serial',
        style: const TextStyle(
          color: InfraColors.navy,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _expenseTile(
    ProjectExpense e,
    int serial,
    OrgPermissions permissions,
  ) {
    final isSelected = _selectedExpenseIds.contains(e.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        leading: Checkbox(
          activeColor: InfraColors.royalBlue,
          value: isSelected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedExpenseIds.add(e.id);
              } else {
                _selectedExpenseIds.remove(e.id);
              }
            });
          },
        ),
        title: Row(
          children: [
            _serialBadge(serial),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                e.category.trim().isEmpty ? 'General Expense' : e.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            [
              if (e.expenseDate != null)
                DateFormat('dd MMM yyyy').format(e.expenseDate!),
              if (e.paymentMode.isNotEmpty) _humanizeToken(e.paymentMode),
            ].join(' · '),
            style: const TextStyle(
              fontSize: 11,
              color: InfraColors.textSecondary,
            ),
          ),
        ),
        onTap: () => _showExpenseDetails(
          context,
          e,
          onGeneratePdf: () => _shareExpensePdf(e),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountText(
              paise: e.amountPaise,
              color: InfraColors.red,
              size: 13,
              weight: FontWeight.w700,
            ),
            _EntityMenu(
              onEdit: permissions.canEditExpense(e)
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ExpenseFormScreen(
                          project: widget.project,
                          expense: e,
                        ),
                      ),
                    )
                  : null,
              onDelete: permissions.canDeleteExpense
                  ? () => _confirmDelete(
                      context,
                      ref,
                      title: 'Delete expense?',
                      message:
                          'Remove ${e.category} '
                          '(${Money.fromPaise(e.amountPaise).formatInr()})?',
                      onConfirm: () async {
                        await ref
                            .read(infraRepositoryProvider)
                            .deleteExpense(e.id);
                        ref.invalidate(
                          projectExpensesProvider(widget.project.id),
                        );
                        ref.invalidate(
                          projectFinancialSummaryProvider(widget.project.id),
                        );
                        ref.invalidate(projectsProvider);
                        ref.invalidate(dashboardSummaryProvider);
                      },
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() => _query = value);

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _shareExpensePdf(ProjectExpense expense) async {
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      const service = InfraReportService();
      final file = await service.expenseDetailPdf(
        organizationName: org.name,
        project: widget.project,
        expense: expense,
      );
      await service.share(file, isPdf: true);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense PDF generated.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not generate PDF: $error')));
    }
  }

  Future<void> _shareSelectedExpensesPdf(List<ProjectExpense> selected) async {
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      const service = InfraReportService();
      final file = await service.expensesPdf(
        organizationName: org.name,
        project: widget.project,
        expenses: selected,
      );
      await service.share(file, isPdf: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected expenses PDF generated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not generate PDF: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(projectExpensesProvider(widget.project.id));
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return Column(
      children: [
        Expanded(
          child: expensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateView(
              message: 'Could not load expenses: $e',
              onRetry: () =>
                  ref.invalidate(projectExpensesProvider(widget.project.id)),
            ),
            data: (expenses) {
              // Cleanup selected IDs that don't exist anymore
              final expenseIds = expenses.map((e) => e.id).toSet();
              _selectedExpenseIds.retainAll(expenseIds);

              final filtered = expenses
                  .where(_matchesExpense)
                  .toList(growable: false);
              final total = filtered.fold<int>(
                0,
                (sum, e) => sum + e.amountPaise,
              );

              final serialOf = _expenseSerials(expenses);
              final sortedList = _sortExpenses(filtered, serialOf);

              final isSelectionActive = _selectedExpenseIds.isNotEmpty;
              final isAllSelected =
                  filtered.isNotEmpty &&
                  filtered.every((e) => _selectedExpenseIds.contains(e.id));

              return Column(
                children: [
                  _FinanceSearchBar(
                    controller: _searchController,
                    hintText: 'Search expenses, category, notes',
                    query: _query,
                    onChanged: _setQuery,
                    onClear: _clearSearch,
                    onAdd: permissions.canAddExpense
                        ? () => context.push(
                            AppRoutes.newExpense(widget.project.id),
                            extra: widget.project,
                          )
                        : null,
                  ),
                  if (filtered.isNotEmpty) _buildSortControl(),
                  if (isSelectionActive)
                    Card(
                      color: InfraColors.royalBlue.withValues(alpha: 0.08),
                      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: InfraColors.royalBlue,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  activeColor: InfraColors.royalBlue,
                                  value: isAllSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedExpenseIds.addAll(
                                          filtered.map((e) => e.id),
                                        );
                                      } else {
                                        _selectedExpenseIds.removeAll(
                                          filtered.map((e) => e.id),
                                        );
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedExpenseIds.length} Selected',
                                  style: const TextStyle(
                                    color: InfraColors.navy,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedExpenseIds.clear();
                                    });
                                  },
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: InfraColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: InfraColors.royalBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: () {
                                    final selectedExpenses = filtered
                                        .where(
                                          (e) => _selectedExpenseIds.contains(
                                            e.id,
                                          ),
                                        )
                                        .toList();
                                    if (selectedExpenses.isNotEmpty) {
                                      _shareSelectedExpensesPdf(
                                        selectedExpenses,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Generate PDF',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref.refreshProject(widget.project.id),
                      child: expenses.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              EmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: 'No expenses yet',
                                message:
                                    'Record material, labor, and other project costs.',
                              ),
                            ],
                          )
                        : filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              _NoFinanceMatches(
                                icon: Icons.receipt_long_outlined,
                                title: 'No matching expenses',
                                query: _query,
                                messageTail:
                                    'Try category, payment mode, notes, or amount.',
                              ),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                            children: [
                              Card(
                                color: InfraColors.navy,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _query.trim().isEmpty
                                            ? 'Total Expenses'
                                            : 'Filtered Expenses',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        Money.fromPaise(total).formatInr(),
                                        style: const TextStyle(
                                          color: InfraColors.gold,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...sortedList.map(
                                (e) => _expenseTile(
                                  e,
                                  serialOf[e.id] ?? 0,
                                  permissions,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  bool _matchesExpense(ProjectExpense expense) {
    return _matchesFinanceSearch([
      expense.vendorName,
      expense.category,
      expense.paymentMode,
      expense.billNumber,
      richTextToPlain(expense.notes),
      Money.fromPaise(expense.amountPaise).formatInr(),
      (expense.amountPaise / 100).toStringAsFixed(2),
      _searchDate(expense.expenseDate),
    ], _query);
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refreshProject(project.id),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          FilledButton.icon(
            onPressed: () => context.push(
              AppRoutes.projectReports(project.id),
              extra: project,
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Open Project Reports'),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Reports'),
              subtitle: Text(
                'Generate and share project summary, investor, government fund, '
                'and expense reports as PDF.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showInvestmentDetails(
  BuildContext context,
  ProjectInvestment investment, {
  required Future<void> Function() onGeneratePdf,
}) {
  final investorName = _presentText(investment.investorName, 'Investor');
  _showFinanceDetailsSheet(
    context,
    icon: Icons.savings_outlined,
    accentColor: InfraColors.gold,
    title: investorName,
    subtitle: 'Investor contribution',
    amountLabel: 'Investment amount',
    amountPaise: investment.amountPaise,
    onGeneratePdf: onGeneratePdf,
    sections: [
      _FinanceDetailSectionData(
        title: 'Investment Details',
        rows: [
          _FinanceDetailRowData('Investor', investorName),
          _FinanceDetailRowData(
            'Investment date',
            _dateLabel(investment.investmentDate),
          ),
          _FinanceDetailRowData(
            'Payment mode',
            _humanizeToken(investment.paymentMode),
          ),
          _FinanceDetailRowData(
            'Reference number',
            _presentText(investment.referenceNumber),
          ),
        ],
      ),
      _FinanceDetailSectionData(
        title: 'Record',
        rows: [
          _FinanceDetailRowData(
            'Created',
            _dateTimeLabel(investment.createdAt),
          ),
          _FinanceDetailRowData(
            'Updated',
            _dateTimeLabel(investment.updatedAt),
          ),
        ],
      ),
    ],
    notesMarkdown: investment.notes,
  );
}

void _showReturnDetails(
  BuildContext context,
  InvestmentReturn entry, {
  required Future<void> Function() onGeneratePdf,
}) {
  final investorName = _presentText(entry.investorName, 'Investor');
  _showFinanceDetailsSheet(
    context,
    icon: Icons.trending_down,
    accentColor: Colors.redAccent,
    title: investorName,
    subtitle: 'Investor return',
    amountLabel: 'Return amount',
    amountPaise: entry.amountPaise,
    onGeneratePdf: onGeneratePdf,
    sections: [
      _FinanceDetailSectionData(
        title: 'Return Details',
        rows: [
          _FinanceDetailRowData('Investor', investorName),
          _FinanceDetailRowData('Return date', _dateLabel(entry.returnDate)),
          _FinanceDetailRowData(
            'Payment mode',
            _humanizeToken(entry.paymentMode),
          ),
          _FinanceDetailRowData(
            'Reference number',
            _presentText(entry.referenceNumber),
          ),
        ],
      ),
      _FinanceDetailSectionData(
        title: 'Record',
        rows: [
          _FinanceDetailRowData('Created', _dateTimeLabel(entry.createdAt)),
          _FinanceDetailRowData('Updated', _dateTimeLabel(entry.updatedAt)),
        ],
      ),
    ],
    notesMarkdown: entry.notes,
  );
}

Future<void> _shareInvestmentPdf(
  BuildContext context,
  WidgetRef ref,
  InfraProject project,
  ProjectInvestment investment,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final org = await ref.read(infraWorkspaceProvider.future);
    const service = InfraReportService();
    final file = await service.investmentDetailPdf(
      organizationName: org.name,
      project: project,
      investment: investment,
    );
    await service.share(file, isPdf: true);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not generate PDF: $error')),
    );
  }
}

Future<void> _shareReturnPdf(
  BuildContext context,
  WidgetRef ref,
  InfraProject project,
  InvestmentReturn entry,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final org = await ref.read(infraWorkspaceProvider.future);
    const service = InfraReportService();
    final file = await service.investmentReturnDetailPdf(
      organizationName: org.name,
      project: project,
      entry: entry,
    );
    await service.share(file, isPdf: true);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not generate PDF: $error')),
    );
  }
}

void _showGovernmentFundDetails(
  BuildContext context,
  String projectId,
  GovernmentFund fund, {
  required Future<void> Function() onGeneratePdf,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _GovtFundDetailsSheet(
      projectId: projectId,
      initialFund: fund,
      onGeneratePdf: onGeneratePdf,
    ),
  );
}

/// Live, receipt-aware detail sheet for a single government fund. It watches
/// the funds and receipts providers so the summary, receipt list and totals
/// stay in sync after any add/edit/delete (locally and via realtime).
class _GovtFundDetailsSheet extends ConsumerWidget {
  const _GovtFundDetailsSheet({
    required this.projectId,
    required this.initialFund,
    required this.onGeneratePdf,
  });

  final String projectId;
  final GovernmentFund initialFund;
  final Future<void> Function() onGeneratePdf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer the live fund from the provider so edits/receipts reflect
    // instantly; fall back to the fund we opened with if it is briefly absent.
    final funds = ref.watch(governmentFundsProvider(projectId)).value;
    final fund =
        funds?.where((f) => f.id == initialFund.id).firstOrNull ?? initialFund;
    final receiptsAsync = ref.watch(fundReceiptsProvider(fund.id));
    final canManage = ref.watch(currentOrgPermissionsProvider).canManageFunds;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: InfraColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: InfraColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 10, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: InfraColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: InfraColors.green,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fund.departmentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: InfraColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _presentText(fund.schemeName, 'Government fund'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: InfraColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _FinanceAmountPanel(
                    label: 'Sanctioned amount',
                    amountPaise: fund.amountSanctionedPaise,
                    accentColor: InfraColors.green,
                  ),
                  const SizedBox(height: 12),
                  _FinancePdfActionButton(onPressed: onGeneratePdf),
                  const SizedBox(height: 12),
                  _FinanceDetailSection(
                    section: _FinanceDetailSectionData(
                      title: 'Money Movement',
                      rows: [
                        _FinanceDetailRowData.money(
                          'Sanctioned',
                          fund.amountSanctionedPaise,
                        ),
                        _FinanceDetailRowData.money(
                          'Received',
                          fund.amountReceivedPaise,
                          valueColor: InfraColors.green,
                        ),
                        _FinanceDetailRowData.money(
                          'Pending',
                          fund.pendingAmountPaise,
                          valueColor: InfraColors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ReceiptsPanel(
                    fund: fund,
                    receiptsAsync: receiptsAsync,
                    canManage: canManage,
                    onAdd: () => _openReceiptForm(context, fund),
                    onEdit: (receipt) =>
                        _openReceiptForm(context, fund, receipt: receipt),
                    onDelete: (receipt) => _deleteReceipt(context, ref, receipt),
                  ),
                  const SizedBox(height: 12),
                  _FinanceDetailSection(
                    section: _FinanceDetailSectionData(
                      title: 'Fund Details',
                      rows: [
                        _FinanceDetailRowData(
                          'Department',
                          fund.departmentName,
                        ),
                        _FinanceDetailRowData(
                          'Scheme',
                          _presentText(fund.schemeName),
                        ),
                        _FinanceDetailRowData(
                          'Status',
                          _governmentFundStatusLabel(fund.status),
                        ),
                        _FinanceDetailRowData(
                          'Sanction order',
                          _presentText(fund.sanctionOrderNumber),
                        ),
                        _FinanceDetailRowData(
                          'Sanction date',
                          _dateLabel(fund.sanctionDate),
                        ),
                        _FinanceDetailRowData(
                          'Last received',
                          _dateLabel(fund.lastReceivedDate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!richTextIsEmpty(fund.notes))
                    _FinanceNotesCard(notesMarkdown: fund.notes!),
                  _FinanceDetailSection(
                    section: _FinanceDetailSectionData(
                      title: 'Record',
                      rows: [
                        _FinanceDetailRowData(
                          'Created',
                          _dateTimeLabel(fund.createdAt),
                        ),
                        _FinanceDetailRowData(
                          'Updated',
                          _dateTimeLabel(fund.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReceiptForm(
    BuildContext context,
    GovernmentFund fund, {
    GovernmentFundReceipt? receipt,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GovtReceiptFormScreen(fund: fund, receipt: receipt),
      ),
    );
  }

  Future<void> _deleteReceipt(
    BuildContext context,
    WidgetRef ref,
    GovernmentFundReceipt receipt,
  ) {
    return _confirmDelete(
      context,
      ref,
      title: 'Delete receipt?',
      message:
          'This removes the ${Money.fromPaise(receipt.amountPaise).formatInr()} '
          'receipt and reduces the received total for this fund.',
      onConfirm: () async {
        await ref
            .read(infraRepositoryProvider)
            .deleteGovernmentReceipt(receipt.id);
        ref.invalidate(fundReceiptsProvider(receipt.governmentFundId));
        ref.invalidate(governmentFundsProvider(receipt.projectId));
        ref.invalidate(projectFinancialSummaryProvider(receipt.projectId));
        ref.invalidate(projectsProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
    );
  }
}

/// Premium, self-contained receipts list panel used inside the fund sheet.
class _ReceiptsPanel extends StatelessWidget {
  const _ReceiptsPanel({
    required this.fund,
    required this.receiptsAsync,
    required this.canManage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final GovernmentFund fund;
  final AsyncValue<List<GovernmentFundReceipt>> receiptsAsync;
  final bool canManage;
  final VoidCallback onAdd;
  final ValueChanged<GovernmentFundReceipt> onEdit;
  final ValueChanged<GovernmentFundReceipt> onDelete;

  @override
  Widget build(BuildContext context) {
    final receipts = receiptsAsync.value ?? const <GovernmentFundReceipt>[];
    return Container(
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InfraColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Receipts',
                    style: TextStyle(
                      color: InfraColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: InfraColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${receipts.length}',
                    style: const TextStyle(
                      color: InfraColors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Add receipt',
                    onPressed: onAdd,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: InfraColors.royalBlue,
                    ),
                  ),
                ],
              ],
            ),
            if (receiptsAsync.isLoading && receipts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (receiptsAsync.hasError && receipts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Could not load receipts: ${receiptsAsync.error}',
                  style: const TextStyle(
                    color: InfraColors.red,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (receipts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 18,
                      color: InfraColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        canManage
                            ? 'No receipts yet. Tap + to record a received payment.'
                            : 'No receipts recorded yet.',
                        style: const TextStyle(
                          color: InfraColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              for (var i = 0; i < receipts.length; i++) ...[
                if (i > 0) const Divider(height: 18),
                _ReceiptRow(
                  receipt: receipts[i],
                  canManage: canManage,
                  onEdit: () => onEdit(receipts[i]),
                  onDelete: () => onDelete(receipts[i]),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.receipt,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final GovernmentFundReceipt receipt;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      _dateLabel(receipt.receivedDate),
      _humanizeToken(receipt.paymentMode),
      if ((receipt.referenceNumber ?? '').trim().isNotEmpty)
        'Ref ${receipt.referenceNumber!.trim()}',
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: InfraColors.green.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.south_west_rounded,
            color: InfraColors.green,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Money.fromPaise(receipt.amountPaise).formatInr(),
                style: const TextStyle(
                  color: InfraColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitleParts.join('  ·  '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: InfraColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (canManage)
          _EntityMenu(onEdit: onEdit, onDelete: onDelete),
      ],
    );
  }
}

void _showExpenseDetails(
  BuildContext context,
  ProjectExpense expense, {
  required Future<void> Function() onGeneratePdf,
}) {
  _showFinanceDetailsSheet(
    context,
    icon: Icons.receipt_long_outlined,
    accentColor: InfraColors.red,
    title: expense.category,
    subtitle: 'Project expense',
    amountLabel: 'Expense amount',
    amountPaise: expense.amountPaise,
    onGeneratePdf: onGeneratePdf,
    sections: [
      _FinanceDetailSectionData(
        title: 'Expense Details',
        rows: [
          _FinanceDetailRowData('Category', expense.category),
          _FinanceDetailRowData(
            'Expense date',
            _dateLabel(expense.expenseDate),
          ),
          _FinanceDetailRowData(
            'Payment mode',
            _humanizeToken(expense.paymentMode),
          ),
          _FinanceDetailRowData('Created by', _presentText(expense.createdBy)),
        ],
      ),
      _FinanceDetailSectionData(
        title: 'Record',
        rows: [
          _FinanceDetailRowData('Created', _dateTimeLabel(expense.createdAt)),
          _FinanceDetailRowData('Updated', _dateTimeLabel(expense.updatedAt)),
        ],
      ),
    ],
    notesMarkdown: expense.notes,
  );
}

void _showFinanceDetailsSheet(
  BuildContext context, {
  required IconData icon,
  required Color accentColor,
  required String title,
  required String subtitle,
  required String amountLabel,
  required int amountPaise,
  required Future<void> Function() onGeneratePdf,
  required List<_FinanceDetailSectionData> sections,
  String? notesMarkdown,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return FractionallySizedBox(
        heightFactor: 0.82,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: InfraColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: InfraColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 10, 14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: accentColor, size: 25),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: InfraColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: InfraColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _FinanceAmountPanel(
                      label: amountLabel,
                      amountPaise: amountPaise,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 12),
                    _FinancePdfActionButton(onPressed: onGeneratePdf),
                    const SizedBox(height: 12),
                    for (final section in sections) ...[
                      _FinanceDetailSection(section: section),
                      const SizedBox(height: 12),
                    ],
                    if (!richTextIsEmpty(notesMarkdown))
                      _FinanceNotesCard(notesMarkdown: notesMarkdown!),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FinanceDetailSectionData {
  const _FinanceDetailSectionData({required this.title, required this.rows});

  final String title;
  final List<_FinanceDetailRowData> rows;
}

class _FinanceDetailRowData {
  const _FinanceDetailRowData(this.label, this.value, {this.valueColor});

  factory _FinanceDetailRowData.money(
    String label,
    int amountPaise, {
    Color? valueColor,
  }) {
    return _FinanceDetailRowData(
      label,
      Money.fromPaise(amountPaise).formatInr(),
      valueColor: valueColor,
    );
  }

  final String label;
  final String value;
  final Color? valueColor;
}

class _FinanceAmountPanel extends StatelessWidget {
  const _FinanceAmountPanel({
    required this.label,
    required this.amountPaise,
    required this.accentColor,
  });

  final String label;
  final int amountPaise;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InfraColors.navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: InfraColors.navy.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            Money.fromPaise(amountPaise).formatInr(),
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancePdfActionButton extends StatefulWidget {
  const _FinancePdfActionButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  State<_FinancePdfActionButton> createState() =>
      _FinancePdfActionButtonState();
}

class _FinancePdfActionButtonState extends State<_FinancePdfActionButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _busy ? null : _run,
      icon: _busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf_outlined),
      label: Text(_busy ? 'Generating PDF' : 'Generate PDF'),
      style: FilledButton.styleFrom(
        backgroundColor: InfraColors.navy,
        foregroundColor: Colors.white,
        disabledBackgroundColor: InfraColors.navy.withValues(alpha: 0.54),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
      ),
    );
  }
}

/// A dedicated card that renders a rich-text (Markdown subset) notes/description
/// value using the shared [RichTextView], so formatting shows the same way it
/// does in the editor and in generated PDFs.
class _FinanceNotesCard extends StatelessWidget {
  const _FinanceNotesCard({required this.notesMarkdown});

  final String notesMarkdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InfraColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                color: InfraColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            RichTextView(
              notesMarkdown,
              baseStyle: const TextStyle(
                color: InfraColors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceDetailSection extends StatelessWidget {
  const _FinanceDetailSection({required this.section});

  final _FinanceDetailSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InfraColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: const TextStyle(
                color: InfraColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < section.rows.length; i++) ...[
              if (i > 0) const Divider(height: 16),
              _FinanceDetailRow(row: section.rows[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinanceDetailRow extends StatelessWidget {
  const _FinanceDetailRow({required this.row});

  final _FinanceDetailRowData row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 116,
          child: Text(
            row.label,
            style: const TextStyle(
              color: InfraColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            row.value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: row.valueColor ?? InfraColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

String _presentText(String? value, [String fallback = 'Not recorded']) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

String _dateLabel(DateTime? value) {
  if (value == null) return 'Not recorded';
  return DateFormat('dd MMM yyyy').format(value);
}

String _dateTimeLabel(DateTime? value) {
  if (value == null) return 'Not recorded';
  return DateFormat('dd MMM yyyy, hh:mm a').format(value);
}

String _humanizeToken(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return 'Not recorded';
  return text
      .split(RegExp(r'[_\s-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join(' ');
}

String _governmentFundStatusLabel(GovtFundStatus status) => switch (status) {
  GovtFundStatus.sanctioned => 'Sanctioned',
  GovtFundStatus.partiallyReceived => 'Partially Received',
  GovtFundStatus.fullyReceived => 'Fully Received',
  GovtFundStatus.delayed => 'Delayed',
  GovtFundStatus.cancelled => 'Cancelled',
};

/// Compact 3-dot menu with Edit / Delete actions used on finance rows.
class _EntityMenu extends StatelessWidget {
  const _EntityMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, color: InfraColors.red),
              title: Text('Delete'),
            ),
          ),
      ],
    );
  }
}

/// Shared confirm-then-run delete handler with snackbar feedback.
Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String message,
  required Future<void> Function() onConfirm,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
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
    await onConfirm();
    messenger.showSnackBar(const SnackBar(content: Text('Deleted.')));
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text('Could not delete: $error')));
  }
}
