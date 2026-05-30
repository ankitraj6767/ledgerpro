import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/infra_models.dart';

class InfraHomeScreen extends ConsumerWidget {
  const InfraHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final org = ref.watch(infraWorkspaceProvider).value;

    return Scaffold(
      backgroundColor: InfraColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(projectsProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroHeader(orgName: org?.name ?? AppConstants.appName),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KpiRow(summaryAsync: summaryAsync),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Projects',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: InfraColors.navy,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: () => context.push(AppRoutes.newProject),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Project'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ProjectsList(projectsAsync: projectsAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.orgName});

  final String orgName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [InfraColors.navy, Color(0xFF0A2A52)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apartment, color: InfraColors.gold, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.notifications_outlined, color: Colors.white),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Welcome to',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            orgName,
            style: const TextStyle(
              color: InfraColors.gold,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppConstants.appTagline,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.summaryAsync});

  final AsyncValue<InfraDashboardSummary> summaryAsync;

  @override
  Widget build(BuildContext context) {
    final summary = summaryAsync.value ?? const InfraDashboardSummary();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        KpiCard(
          label: 'Total Projects',
          value: '${summary.totalProjects}',
          icon: Icons.business_outlined,
          color: InfraColors.royalBlue,
        ),
        KpiCard(
          label: 'Active Projects',
          value: '${summary.activeProjects}',
          icon: Icons.construction_outlined,
          color: InfraColors.green,
        ),
        KpiCard(
          label: 'Total Investment',
          value: _compact(summary.totalInvestmentPaise),
          icon: Icons.savings_outlined,
          color: InfraColors.gold,
        ),
        KpiCard(
          label: 'Total Received',
          value: _compact(summary.totalGovtReceivedPaise),
          icon: Icons.account_balance_outlined,
          color: InfraColors.orange,
        ),
      ],
    );
  }

  String _compact(int paise) {
    // Reuse Money compact formatting through AmountText would need a widget;
    // here we format inline for the KPI value string.
    final rupees = paise / 100.0;
    if (rupees >= 10000000) {
      return '₹${(rupees / 10000000).toStringAsFixed(2)} Cr';
    }
    if (rupees >= 100000) {
      return '₹${(rupees / 100000).toStringAsFixed(2)} Lakh';
    }
    return '₹${rupees.toStringAsFixed(0)}';
  }
}

class _ProjectsList extends StatelessWidget {
  const _ProjectsList({required this.projectsAsync});

  final AsyncValue<List<InfraProject>> projectsAsync;

  @override
  Widget build(BuildContext context) {
    return projectsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ErrorStateView(message: 'Could not load projects: $error'),
      data: (projects) {
        if (projects.isEmpty) {
          return const EmptyState(
            icon: Icons.business_outlined,
            title: 'No projects yet',
            message: 'Tap "Add Project" to create your first infrastructure project.',
          );
        }
        return Column(
          children: projects
              .map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(project: p),
                  ))
              .toList(),
        );
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    final location = [project.locationCity, project.locationState]
        .where((e) => (e ?? '').isNotEmpty)
        .join(', ');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          AppRoutes.projectDetail(project.id),
          extra: project,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: InfraColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: InfraColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    ProjectProgressBar(percent: project.progressPercent),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Invested',
                      style: TextStyle(
                          fontSize: 10, color: InfraColors.textSecondary)),
                  AmountText(
                    paise: project.totalInvestmentPaise,
                    compact: true,
                    size: 13,
                    color: InfraColors.gold,
                  ),
                  const SizedBox(height: 4),
                  const Text('Received',
                      style: TextStyle(
                          fontSize: 10, color: InfraColors.textSecondary)),
                  AmountText(
                    paise: project.totalGovtReceivedPaise,
                    compact: true,
                    size: 13,
                    color: InfraColors.green,
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: InfraColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
