import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';
import '../data/infra_report_service.dart';

class ProjectReportsScreen extends ConsumerStatefulWidget {
  const ProjectReportsScreen({
    super.key,
    required this.projectId,
    this.project,
  });

  final String projectId;
  final InfraProject? project;

  @override
  ConsumerState<ProjectReportsScreen> createState() =>
      _ProjectReportsScreenState();
}

class _ProjectReportsScreenState extends ConsumerState<ProjectReportsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final project =
        ref
            .watch(projectsProvider)
            .value
            ?.where((p) => p.id == widget.projectId)
            .firstOrNull ??
        widget.project;

    return Scaffold(
      appBar: AppBar(title: const Text('Project Reports')),
      body: project == null
          ? const EmptyState(
              icon: Icons.error_outline,
              title: 'Project not found',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  icon: Icons.summarize_outlined,
                  title: 'Project Summary (PDF)',
                  subtitle: 'Investments, funds, and expenses overview',
                  onTap: () => _summaryPdf(project),
                ),
                _card(
                  icon: Icons.savings_outlined,
                  title: 'Investor Report (PDF)',
                  subtitle: 'All investments for this project',
                  onTap: () => _investorsPdf(project),
                ),
                _card(
                  icon: Icons.account_balance_outlined,
                  title: 'Government Funds (PDF)',
                  subtitle: 'Sanctions, receipts, and pending funds',
                  onTap: () => _governmentFundsPdf(project),
                ),
                _card(
                  icon: Icons.receipt_long_outlined,
                  title: 'Expense Report (PDF)',
                  subtitle: 'All expenses for this project',
                  onTap: () => _expensesPdf(project),
                ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.ios_share_outlined),
        onTap: _busy ? null : onTap,
      ),
    );
  }

  Future<void> _summaryPdf(InfraProject project) async {
    await _run(() async {
      final repo = ref.read(infraRepositoryProvider);
      final org = await ref.read(infraWorkspaceProvider.future);
      final summary = await repo.projectFinancialSummary(project.id);
      final investments = await repo.fetchInvestments(project.id);
      final funds = await repo.fetchGovernmentFunds(project.id);
      final expenses = await repo.fetchExpenses(project.id);
      const service = InfraReportService();
      final file = await service.projectSummaryPdf(
        organizationName: org.name,
        project: project,
        summary: summary,
        investments: investments,
        funds: funds,
        expenses: expenses,
      );
      await service.share(file, isPdf: true);
    });
  }

  Future<void> _investorsPdf(InfraProject project) async {
    await _run(() async {
      final repo = ref.read(infraRepositoryProvider);
      final org = await ref.read(infraWorkspaceProvider.future);
      final investments = await repo.fetchInvestments(project.id);
      const service = InfraReportService();
      final file = await service.investorsPdf(
        organizationName: org.name,
        project: project,
        investments: investments,
      );
      await service.share(file, isPdf: true);
    });
  }

  Future<void> _governmentFundsPdf(InfraProject project) async {
    await _run(() async {
      final repo = ref.read(infraRepositoryProvider);
      final org = await ref.read(infraWorkspaceProvider.future);
      final funds = await repo.fetchGovernmentFunds(project.id);
      final receiptEntries = await Future.wait(
        funds.map((fund) async {
          final receipts = await repo.fetchReceipts(fund.id);
          return MapEntry(fund.id, receipts);
        }),
      );
      final receiptsByFundId =
          Map<String, List<GovernmentFundReceipt>>.fromEntries(receiptEntries);
      const service = InfraReportService();
      final file = await service.governmentFundsPdf(
        organizationName: org.name,
        project: project,
        funds: funds,
        receiptsByFundId: receiptsByFundId,
      );
      await service.share(file, isPdf: true);
    });
  }

  Future<void> _expensesPdf(InfraProject project) async {
    await _run(() async {
      final repo = ref.read(infraRepositoryProvider);
      final org = await ref.read(infraWorkspaceProvider.future);
      final expenses = await repo.fetchExpenses(project.id);
      const service = InfraReportService();
      final file = await service.expensesPdf(
        organizationName: org.name,
        project: project,
        expenses: expenses,
      );
      await service.share(file, isPdf: true);
    });
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await task();
      messenger.showSnackBar(
        const SnackBar(content: Text('Report generated and ready to share.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate report: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
