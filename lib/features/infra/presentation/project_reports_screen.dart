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
    final project = ref.watch(projectsProvider).value
            ?.where((p) => p.id == widget.projectId)
            .firstOrNull ??
        widget.project;

    return Scaffold(
      appBar: AppBar(title: const Text('Project Reports')),
      body: project == null
          ? const EmptyState(icon: Icons.error_outline, title: 'Project not found')
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
                  title: 'Investor Report (CSV)',
                  subtitle: 'All investments for this project',
                  onTap: () => _investorsCsv(project),
                ),
                _card(
                  icon: Icons.receipt_long_outlined,
                  title: 'Expense Report (CSV)',
                  subtitle: 'All expenses for this project',
                  onTap: () => _expensesCsv(project),
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
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
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

  Future<void> _investorsCsv(InfraProject project) async {
    await _run(() async {
      final repo = ref.read(infraRepositoryProvider);
      final investments = await repo.fetchInvestments(project.id);
      const service = InfraReportService();
      final file =
          await service.investorsCsv(project: project, investments: investments);
      await service.share(file, isPdf: false);
    });
  }

  Future<void> _expensesCsv(InfraProject project) async {
    await _run(() async {
      final repo = ref.read(infraRepositoryProvider);
      final expenses = await repo.fetchExpenses(project.id);
      const service = InfraReportService();
      final file =
          await service.expensesCsv(project: project, expenses: expenses);
      await service.share(file, isPdf: false);
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
