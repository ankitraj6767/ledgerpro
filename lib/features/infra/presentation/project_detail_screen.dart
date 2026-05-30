import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../core/money/money.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/donut_expense_chart.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import 'infra_forms.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  final String projectId;
  final InfraProject? initialProject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final project = projectsAsync.value
            ?.where((p) => p.id == projectId)
            .firstOrNull ??
        initialProject;

    if (project == null) {
      if (projectsAsync.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
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
      child: Scaffold(
        backgroundColor: InfraColors.background,
        appBar: AppBar(
          title: const Text('Project Details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push(AppRoutes.editProject(project.id),
                      extra: project);
                } else if (value == 'progress') {
                  _showProgressDialog(context, ref, project);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit project')),
                PopupMenuItem(
                    value: 'progress', child: Text('Update progress')),
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
        body: Column(
          children: [
            _ProjectHeaderCard(project: project),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(project: project),
                  _InvestorsTab(project: project),
                  _GovtFundsTab(project: project),
                  _ExpensesTab(project: project),
                  _ReportsTab(project: project),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProgressDialog(
    BuildContext context,
    WidgetRef ref,
    InfraProject project,
  ) async {
    final controller =
        TextEditingController(text: project.progressPercent.toString());
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update progress'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Progress %',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    if (result < 0 || result > 100) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Progress must be between 0 and 100.')),
      );
      return;
    }
    try {
      await ref.read(infraRepositoryProvider).updateProgress(project.id, result);
      ref.invalidate(projectsProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Progress updated.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update progress: $error')),
      );
    }
  }
}

class _ProjectHeaderCard extends StatelessWidget {
  const _ProjectHeaderCard({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final location = [project.locationCity, project.locationState]
        .where((e) => (e ?? '').isNotEmpty)
        .join(', ');
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InfraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: InfraColors.royalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment, color: InfraColors.royalBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: InfraColors.textSecondary),
                          Text(location,
                              style: const TextStyle(
                                  color: InfraColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusPill(
                label: _statusLabel(project.status),
                dbStatus: _statusDb(project.status),
              ),
              const Spacer(),
              if (project.startDate != null)
                _dateChip('Start', dateFmt.format(project.startDate!)),
              const SizedBox(width: 8),
              if (project.expectedEndDate != null)
                _dateChip('End', dateFmt.format(project.expectedEndDate!)),
            ],
          ),
          const SizedBox(height: 12),
          ProjectProgressBar(percent: project.progressPercent),
        ],
      ),
    );
  }

  Widget _dateChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: InfraColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800)),
      ],
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
    final summaryAsync =
        ref.watch(projectFinancialSummaryProvider(project.id));
    final expensesAsync = ref.watch(projectExpensesProvider(project.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
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
                _kv('Received Till Date', s.totalGovtReceivedPaise,
                    color: InfraColors.green),
                _kv('Pending Amount', s.pendingGovtPaise,
                    color: InfraColors.orange),
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
            data: (s) => Column(
              children: [
                _kv('Total Investment', s.totalInvestmentPaise,
                    color: InfraColors.gold),
                _kv('Total Expenses', s.totalExpensePaise,
                    color: InfraColors.red),
                const Divider(),
                _kv('Available Balance', s.availableBalancePaise,
                    color: InfraColors.royalBlue, bold: true),
              ],
            ),
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
                slices.add(DonutSlice(
                  label: entries[i].key,
                  amountPaise: entries[i].value,
                  color: DonutExpenseChart
                      .palette[i % DonutExpenseChart.palette.length],
                ));
              }
              return DonutExpenseChart(slices: slices);
            },
          ),
        ),
        const SizedBox(height: 12),
        _QuickActions(project: project),
      ],
    );
  }

  Widget _kv(String label, int paise, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: InfraColors.textSecondary,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w500)),
          Text(
            Money.fromPaise(paise).formatInr(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color ?? InfraColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickActionCard(
                    icon: Icons.add_card_outlined,
                    label: 'Add Expense',
                    color: InfraColors.royalBlue,
                    onTap: () =>
                        context.push(AppRoutes.newExpense(project.id),
                            extra: project),
                  ),
                  const SizedBox(width: 10),
                  QuickActionCard(
                    icon: Icons.account_balance_outlined,
                    label: 'Add Fund',
                    color: InfraColors.green,
                    onTap: () =>
                        context.push(AppRoutes.newGovtFund(project.id),
                            extra: project),
                  ),
                  const SizedBox(width: 10),
                  QuickActionCard(
                    icon: Icons.savings_outlined,
                    label: 'Add Investment',
                    color: InfraColors.gold,
                    onTap: () =>
                        context.push(AppRoutes.newInvestment(project.id),
                            extra: project),
                  ),
                  const SizedBox(width: 10),
                  QuickActionCard(
                    icon: Icons.note_add_outlined,
                    label: 'Add Note',
                    color: InfraColors.orange,
                    onTap: () => _addNote(context, project),
                  ),
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
class _InvestorsTab extends ConsumerWidget {
  const _InvestorsTab({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(projectInvestmentsProvider(project.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.newInvestment(project.id),
                    extra: project),
            icon: const Icon(Icons.add),
            label: const Text('Add Investment'),
          ),
        ),
        Expanded(
          child: investmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateView(
              message: 'Could not load investments: $e',
              onRetry: () =>
                  ref.invalidate(projectInvestmentsProvider(project.id)),
            ),
            data: (investments) {
              if (investments.isEmpty) {
                return const EmptyState(
                  icon: Icons.savings_outlined,
                  title: 'No investments yet',
                  message: 'Add an investor contribution to this project.',
                );
              }
              final total = investments.fold<int>(
                  0, (sum, i) => sum + i.amountPaise);
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                children: [
                  ...investments.map((inv) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFF4D6),
                            child: Icon(Icons.person,
                                color: InfraColors.gold),
                          ),
                          title: Text(inv.investorName ?? 'Investor',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text(inv.investmentDate == null
                              ? inv.paymentMode
                              : DateFormat('dd MMM yyyy')
                                  .format(inv.investmentDate!)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AmountText(
                                paise: inv.amountPaise,
                                color: InfraColors.gold,
                              ),
                              _EntityMenu(
                                onEdit: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => InvestmentFormScreen(
                                      project: project,
                                      investment: inv,
                                    ),
                                  ),
                                ),
                                onDelete: () => _confirmDelete(
                                  context,
                                  ref,
                                  title: 'Delete investment?',
                                  message:
                                      'Remove ${inv.investorName ?? 'this investment'} '
                                      '(${Money.fromPaise(inv.amountPaise).formatInr()})?',
                                  onConfirm: () async {
                                    await ref
                                        .read(infraRepositoryProvider)
                                        .deleteInvestment(inv.id);
                                    ref.invalidate(projectInvestmentsProvider(
                                        project.id));
                                    ref.invalidate(
                                        projectFinancialSummaryProvider(
                                            project.id));
                                    ref.invalidate(projectsProvider);
                                    ref.invalidate(dashboardSummaryProvider);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  Card(
                    color: InfraColors.navy,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Investment',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                          Text(
                            Money.fromPaise(total).formatInr(),
                            style: const TextStyle(
                                color: InfraColors.gold,
                                fontWeight: FontWeight.w900,
                                fontSize: 16),
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
}

// ---------------------------------------------------------------------------
// Government Funds tab
// ---------------------------------------------------------------------------
class _GovtFundsTab extends ConsumerWidget {
  const _GovtFundsTab({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundsAsync = ref.watch(governmentFundsProvider(project.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.newGovtFund(project.id), extra: project),
            icon: const Icon(Icons.add),
            label: const Text('Add Sanctioned Fund'),
          ),
        ),
        Expanded(
          child: fundsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateView(
              message: 'Could not load funds: $e',
              onRetry: () => ref.invalidate(governmentFundsProvider(project.id)),
            ),
            data: (funds) {
              if (funds.isEmpty) {
                return const EmptyState(
                  icon: Icons.account_balance_outlined,
                  title: 'No government funds yet',
                  message: 'Add a sanctioned fund to track receipts.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                itemCount: funds.length,
                itemBuilder: (context, index) {
                  final fund = funds[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(fund.departmentName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                              StatusPill(
                                label: _fundStatusLabel(fund.status),
                                dbStatus: _fundStatusDb(fund.status),
                              ),
                              _EntityMenu(
                                onEdit: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => GovtFundFormScreen(
                                      project: project,
                                      fund: fund,
                                    ),
                                  ),
                                ),
                                onDelete: () => _confirmDelete(
                                  context,
                                  ref,
                                  title: 'Delete government fund?',
                                  message:
                                      'This removes "${fund.departmentName}" and all '
                                      'its receipts, and reverses the project totals.',
                                  onConfirm: () async {
                                    await ref
                                        .read(infraRepositoryProvider)
                                        .deleteGovernmentFund(fund.id);
                                    ref.invalidate(
                                        governmentFundsProvider(project.id));
                                    ref.invalidate(
                                        projectFinancialSummaryProvider(
                                            project.id));
                                    ref.invalidate(projectsProvider);
                                    ref.invalidate(dashboardSummaryProvider);
                                  },
                                ),
                              ),
                            ],
                          ),
                          if ((fund.schemeName ?? '').isNotEmpty)
                            Text(fund.schemeName!,
                                style: const TextStyle(
                                    color: InfraColors.textSecondary,
                                    fontSize: 12)),
                          const SizedBox(height: 8),
                          _row('Sanctioned', fund.amountSanctionedPaise),
                          _row('Received', fund.amountReceivedPaise,
                              color: InfraColors.green),
                          _row('Pending', fund.pendingAmountPaise,
                              color: InfraColors.orange),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => context.push(
                              AppRoutes.newGovtReceipt(project.id),
                              extra: fund,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Receipt'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _row(String label, int paise, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: InfraColors.textSecondary)),
          Text(Money.fromPaise(paise).formatInr(),
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color ?? InfraColors.textPrimary)),
        ],
      ),
    );
  }

  static String _fundStatusLabel(GovtFundStatus s) => switch (s) {
        GovtFundStatus.sanctioned => 'Sanctioned',
        GovtFundStatus.partiallyReceived => 'Partial',
        GovtFundStatus.fullyReceived => 'Received',
        GovtFundStatus.delayed => 'Delayed',
        GovtFundStatus.cancelled => 'Cancelled',
      };

  static String _fundStatusDb(GovtFundStatus s) => switch (s) {
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
class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(projectExpensesProvider(project.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.newExpense(project.id), extra: project),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ),
        Expanded(
          child: expensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorStateView(
              message: 'Could not load expenses: $e',
              onRetry: () => ref.invalidate(projectExpensesProvider(project.id)),
            ),
            data: (expenses) {
              if (expenses.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No expenses yet',
                  message: 'Record material, labor, and other project costs.',
                );
              }
              final total =
                  expenses.fold<int>(0, (sum, e) => sum + e.amountPaise);
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                children: [
                  Card(
                    color: InfraColors.navy,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Expenses',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900)),
                          Text(Money.fromPaise(total).formatInr(),
                              style: const TextStyle(
                                  color: InfraColors.gold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...expenses.map((e) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                InfraColors.royalBlue.withValues(alpha: 0.1),
                            child: const Icon(Icons.receipt_long_outlined,
                                color: InfraColors.royalBlue),
                          ),
                          title: Text(e.category,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text([
                            if ((e.vendorName ?? '').isNotEmpty) e.vendorName,
                            if (e.expenseDate != null)
                              DateFormat('dd MMM yyyy').format(e.expenseDate!),
                          ].whereType<String>().join(' · ')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AmountText(
                                paise: e.amountPaise,
                                color: InfraColors.red,
                              ),
                              _EntityMenu(
                                onEdit: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ExpenseFormScreen(
                                      project: project,
                                      expense: e,
                                    ),
                                  ),
                                ),
                                onDelete: () => _confirmDelete(
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
                                        projectExpensesProvider(project.id));
                                    ref.invalidate(
                                        projectFinancialSummaryProvider(
                                            project.id));
                                    ref.invalidate(projectsProvider);
                                    ref.invalidate(dashboardSummaryProvider);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reports tab
// ---------------------------------------------------------------------------
class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.projectReports(project.id),
              extra: project),
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
              'and expense reports as PDF or CSV.',
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact 3-dot menu with Edit / Delete actions used on finance rows.
class _EntityMenu extends StatelessWidget {
  const _EntityMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem(
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
    messenger.showSnackBar(
      SnackBar(content: Text('Could not delete: $error')),
    );
  }
}
