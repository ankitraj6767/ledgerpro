import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../core/money/money.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/components/navdream_logo.dart';
import '../../../shared/models/infra_models.dart';

class InfraHomeScreen extends ConsumerWidget {
  const InfraHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Persist fresh dashboard data so the next cold start can render instantly.
    ref.watch(dashboardCacheWriterProvider);

    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final workspaceAsync = ref.watch(infraWorkspaceProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final cached = ref.watch(cachedDashboardProvider);

    // Prefer live data, then the last-known cached snapshot. A null value means
    // this is the very first load with nothing cached yet: the widgets below
    // render a loading skeleton for that part instead of placeholder defaults.
    // On error we fall back to a sensible value so it never shimmers forever.
    final orgName =
        workspaceAsync.value?.name ??
        cached?.orgName ??
        (workspaceAsync.hasError ? AppConstants.appName : null);
    final summary =
        summaryAsync.value ??
        cached?.summary ??
        (summaryAsync.hasError ? const InfraDashboardSummary() : null);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1000) {
          return _DesktopDashboard(
            orgName: orgName,
            summary: summary,
            projectsAsync: projectsAsync,
            cachedProjects: cached?.projects,
            canCreateProjects: permissions.canManageProjects,
            onRefresh: () async {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(projectsProvider);
            },
          );
        }
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
                _HeroHeader(orgName: orgName),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KpiRow(summary: summary),
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
                          if (permissions.canManageProjects)
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: InfraColors.navy,
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                              ),
                              onPressed: () =>
                                  context.push(AppRoutes.newProject),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Project'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ProjectsList(
                        projectsAsync: projectsAsync,
                        cachedProjects: cached?.projects,
                        canCreateProjects: permissions.canManageProjects,
                      ),
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
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.orgName,
    required this.summary,
    required this.projectsAsync,
    required this.cachedProjects,
    required this.canCreateProjects,
    required this.onRefresh,
  });

  final String? orgName;
  final InfraDashboardSummary? summary;
  final AsyncValue<List<InfraProject>> projectsAsync;
  final List<InfraProject>? cachedProjects;
  final bool canCreateProjects;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final name = orgName;
    final summaryData = summary;
    final projectsData = projectsAsync.value ?? cachedProjects;
    final projectsLoading = projectsData == null && !projectsAsync.hasError;
    final projects = projectsData ?? const <InfraProject>[];

    return Scaffold(
      backgroundColor: InfraColors.background,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name == null)
                        const SkeletonBox(width: 240, height: 28, radius: 6)
                      else
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                      const SizedBox(height: 4),
                      const Text(
                        'Finance and infrastructure operations',
                        style: TextStyle(color: InfraColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (canCreateProjects)
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.newProject),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('New project'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: summaryData == null
                  ? const [
                      KpiCardSkeleton(radius: 8),
                      KpiCardSkeleton(radius: 8),
                      KpiCardSkeleton(radius: 8),
                      KpiCardSkeleton(radius: 8),
                      KpiCardSkeleton(radius: 8),
                    ]
                  : [
                      _DesktopKpi(
                        label: 'Total Projects',
                        value: '${summaryData.totalProjects}',
                        icon: Icons.business_outlined,
                        color: InfraColors.royalBlue,
                      ),
                      _DesktopKpi(
                        label: 'Active',
                        value: '${summaryData.activeProjects}',
                        icon: Icons.construction_outlined,
                        color: InfraColors.green,
                      ),
                      _MoneyKpi(
                        label: 'Net Investments',
                        paise: summaryData.totalInvestmentPaise,
                        icon: Icons.savings_outlined,
                        color: InfraColors.gold,
                      ),
                      _MoneyKpi(
                        label: 'Expenses',
                        paise: summaryData.totalExpensePaise,
                        icon: Icons.receipt_long_outlined,
                        color: InfraColors.red,
                      ),
                      _MoneyKpi(
                        label: 'Govt Pending',
                        paise: summaryData.pendingGovtFundsPaise,
                        icon: Icons.pending_actions_outlined,
                        color: InfraColors.orange,
                      ),
                    ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _DashboardPanel(
                    title: 'My Projects',
                    icon: Icons.apartment_outlined,
                    child: projectsLoading
                        ? const _ProjectsSkeleton(count: 4, height: 40)
                        : projects.isEmpty
                        ? const EmptyState(
                            icon: Icons.business_outlined,
                            title: 'No projects yet',
                          )
                        : Column(
                            children: [
                              for (final project in projects)
                                _ProjectSummaryRow(project: project),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: _DashboardPanel(
                    title: 'Government Funds',
                    icon: Icons.account_balance_outlined,
                    child: summaryData == null
                        ? const _MoneyLinesSkeleton()
                        : Column(
                            children: [
                              _MoneyLine(
                                label: 'Sanctioned',
                                paise: summaryData.totalGovtSanctionedPaise,
                                color: InfraColors.royalBlue,
                              ),
                              _MoneyLine(
                                label: 'Received',
                                paise: summaryData.totalGovtReceivedPaise,
                                color: InfraColors.green,
                              ),
                              const Divider(),
                              _MoneyLine(
                                label: 'Pending',
                                paise: summaryData.pendingGovtFundsPaise,
                                color: InfraColors.orange,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: InfraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: InfraColors.navy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ProjectSummaryRow extends StatelessWidget {
  const _ProjectSummaryRow({required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.push(AppRoutes.projectDetail(project.id), extra: project),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Estimated ${Money.fromPaise(project.totalEstimatedCostPaise).formatCompactInr()} · Expenses ${Money.fromPaise(project.totalExpensePaise).formatCompactInr()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: InfraColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ProjectProgressBar(
                percent: project.financialProgressPercent,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 116,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Net Invested',
                    style: TextStyle(
                      color: InfraColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  AmountText(
                    paise: project.netInvestmentPaise,
                    compact: true,
                    color: InfraColors.gold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.label,
    required this.paise,
    required this.color,
  });

  final String label;
  final int paise;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: InfraColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AmountText(paise: paise, compact: true, color: color, size: 15),
        ],
      ),
    );
  }
}

class _DesktopKpi extends StatelessWidget {
  const _DesktopKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: InfraColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: InfraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: InfraColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyKpi extends StatelessWidget {
  const _MoneyKpi({
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
    return _DesktopKpi(
      label: label,
      value: Money.fromPaise(paise).formatCompactInr(),
      icon: icon,
      color: color,
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.orgName});

  final String? orgName;

  @override
  Widget build(BuildContext context) {
    final name = orgName;
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
              const NavdreamLogo(
                size: 42,
                borderRadius: BorderRadius.all(Radius.circular(13)),
                showBorder: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: name == null
                    ? const SkeletonBox(width: 150, height: 20, radius: 6)
                    : FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          name,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 0.5,
                          ),
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
          if (name == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: SkeletonBox(width: 210, height: 26, radius: 6),
            )
          else
            Text(
              name,
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
  const _KpiRow({required this.summary});

  final InfraDashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: s == null
          ? const [
              KpiCardSkeleton(),
              KpiCardSkeleton(),
              KpiCardSkeleton(),
              KpiCardSkeleton(),
            ]
          : [
              KpiCard(
                label: 'Total Projects',
                value: '${s.totalProjects}',
                icon: Icons.business_outlined,
                color: InfraColors.royalBlue,
              ),
              KpiCard(
                label: 'Active Projects',
                value: '${s.activeProjects}',
                icon: Icons.construction_outlined,
                color: InfraColors.green,
              ),
              KpiCard(
                label: 'Total Net Investment',
                value: _compact(s.totalInvestmentPaise),
                icon: Icons.savings_outlined,
                color: InfraColors.gold,
              ),
              KpiCard(
                label: 'Total Received',
                value: _compact(s.totalGovtReceivedPaise),
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
  const _ProjectsList({
    required this.projectsAsync,
    required this.cachedProjects,
    required this.canCreateProjects,
  });

  final AsyncValue<List<InfraProject>> projectsAsync;
  final List<InfraProject>? cachedProjects;
  final bool canCreateProjects;

  @override
  Widget build(BuildContext context) {
    // Prefer live data, fall back to cached projects while loading so the list
    // is never blank on a cold start. Only show the spinner/error when there is
    // nothing to display yet.
    final projects = projectsAsync.value ?? cachedProjects;
    if (projects == null) {
      return projectsAsync.hasError
          ? ErrorStateView(
              message: 'Could not load projects: ${projectsAsync.error}',
            )
          : const _ProjectsSkeleton();
    }
    if (projects.isEmpty) {
      return EmptyState(
        icon: Icons.business_outlined,
        title: 'No projects yet',
        message: canCreateProjects
            ? 'Tap "Add Project" to create your first infrastructure project.'
            : 'No infrastructure projects are available yet.',
      );
    }
    return Column(
      children: projects
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProjectCard(project: p),
            ),
          )
          .toList(),
    );
  }
}

class _ProjectsSkeleton extends StatelessWidget {
  const _ProjectsSkeleton({this.count = 3, this.height = 88});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonBox(height: height, radius: 14),
          ),
      ],
    );
  }
}

class _MoneyLinesSkeleton extends StatelessWidget {
  const _MoneyLinesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: SkeletonBox(height: 12)),
                SizedBox(width: 16),
                SkeletonBox(width: 70, height: 12),
              ],
            ),
          ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final InfraProject project;

  @override
  Widget build(BuildContext context) {
    final location = [
      project.locationCity,
      project.locationState,
    ].where((e) => (e ?? '').isNotEmpty).join(', ');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            context.push(AppRoutes.projectDetail(project.id), extra: project),
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
                        fontSize: 15,
                      ),
                    ),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: InfraColors.textSecondary,
                          ),
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
                    ProjectProgressBar(
                      percent: project.financialProgressPercent,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Estimated Cost',
                    style: TextStyle(
                      fontSize: 10,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                  AmountText(
                    paise: project.totalEstimatedCostPaise,
                    compact: true,
                    size: 13,
                    color: InfraColors.navy,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Net Invested',
                    style: TextStyle(
                      fontSize: 10,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                  AmountText(
                    paise: project.netInvestmentPaise,
                    compact: true,
                    size: 13,
                    color: InfraColors.gold,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Received',
                    style: TextStyle(
                      fontSize: 10,
                      color: InfraColors.textSecondary,
                    ),
                  ),
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
