import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../shared/models/infra_models.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/material_models.dart';
import 'material_master_form.dart';
import 'material_operation_form.dart';

class MaterialsDashboardScreen extends ConsumerWidget {
  const MaterialsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(materialDashboardSummaryProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final setup = ref.watch(materialSetupStatusProvider);
    if (MediaQuery.sizeOf(context).width < 720) {
      return _MobileMaterialDashboard(
        summary: summary,
        permissions: permissions,
        setup: setup,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => invalidateMaterialProviders(ref),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1220),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!setup.isComplete) ...[
                        _SetupBanner(status: setup),
                        const SizedBox(height: 14),
                      ],
                      const _FilterSection(),
                      const SizedBox(height: 16),
                      _KpiGrid(summary: summary),
                      if (permissions.canOperateMaterials) ...[
                        const SizedBox(height: 18),
                        _QuickActions(
                          canManage: permissions.canManageMaterials,
                        ),
                      ],
                      const SizedBox(height: 18),
                      const _ResponsiveDashboardSections(),
                      const SizedBox(height: 18),
                      _MaterialFlow(summary: summary.value),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMaterialDashboard extends ConsumerWidget {
  const _MobileMaterialDashboard({
    required this.summary,
    required this.permissions,
    required this.setup,
  });

  final AsyncValue<MaterialDashboardSummary> summary;
  final OrgPermissions permissions;
  final MaterialSetupStatus setup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = summary.value ?? const MaterialDashboardSummary();
    return RefreshIndicator(
      onRefresh: () async => invalidateMaterialProviders(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (!setup.isComplete && permissions.canManageMaterials) ...[
            _SetupBanner(status: setup),
            const SizedBox(height: 14),
          ] else if (permissions.isCustomer) ...[
            const _ReadOnlyBanner(),
            const SizedBox(height: 14),
          ],
          _MobileKpiScroller(summary: value, loading: summary.isLoading),
          const SizedBox(height: 18),
          const _MobileStockSummary(),
          const SizedBox(height: 18),
          _MobileQuickActions(permissions: permissions),
          const SizedBox(height: 18),
          const _MobileSchoolsSection(),
          const SizedBox(height: 18),
          const _MobileRecentIssuesSection(),
        ],
      ),
    );
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  const _ReadOnlyBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF2FF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: InfraColors.royalBlue.withValues(alpha: 0.18)),
    ),
    child: const Row(
      children: [
        Icon(Icons.visibility_outlined, color: InfraColors.royalBlue),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Customer read-only access: you can view material progress, stock, and reports.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _MobileKpiScroller extends StatelessWidget {
  const _MobileKpiScroller({required this.summary, required this.loading});

  final MaterialDashboardSummary summary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const _ShimmerBox(height: 104);
    final cards = [
      _KpiData(
        'Total Schools',
        summary.totalSchools,
        Icons.school_outlined,
        const Color(0xFF6D36F4),
      ),
      _KpiData(
        'Running',
        summary.runningSchools,
        Icons.play_circle_outline,
        InfraColors.green,
      ),
      _KpiData(
        'Completed',
        summary.completedSchools,
        Icons.check_circle_outline,
        InfraColors.royalBlue,
      ),
      _KpiData(
        'Pending',
        summary.pendingSchools,
        Icons.access_time,
        InfraColors.orange,
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final card in cards) ...[
            _MobileKpiCard(data: card),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _MobileKpiCard extends StatelessWidget {
  const _MobileKpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    height: 104,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: InfraColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(data.icon, color: data.color, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: InfraColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data.value}',
                style: const TextStyle(
                  color: InfraColors.navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MobileStockSummary extends ConsumerWidget {
  const _MobileStockSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MobileSectionCard(
      title: 'Warehouse Stock Summary',
      actionLabel: 'View All',
      onAction: () => context.push(AppRoutes.materialStock),
      child: ref
          .watch(warehouseStockSummaryProvider)
          .when(
            loading: () => const _ShimmerBox(height: 112),
            error: (error, _) => Text(
              'Could not load stock: $error',
              style: const TextStyle(color: InfraColors.red),
            ),
            data: (rows) {
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No stock received yet',
                    style: TextStyle(color: InfraColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final row in rows.take(6)) ...[
                          _MobileStockCard(row: row),
                          const SizedBox(width: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(active: true),
                      _Dot(active: false),
                      _Dot(active: false),
                      _Dot(active: false),
                    ],
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _MobileStockCard extends StatelessWidget {
  const _MobileStockCard({required this.row});

  final WarehouseStockRow row;

  @override
  Widget build(BuildContext context) => Container(
    width: 138,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: InfraColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 58,
          decoration: BoxDecoration(
            color: InfraColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: InfraColors.navy,
            size: 30,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.materialName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: InfraColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                formatQuantity(row.remainingStock),
                style: const TextStyle(
                  color: InfraColors.navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              Text(
                row.unit,
                style: const TextStyle(color: InfraColors.navy, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: active ? 10 : 8,
    height: active ? 10 : 8,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? InfraColors.navy : InfraColors.border,
    ),
  );
}

class _MobileQuickActions extends StatelessWidget {
  const _MobileQuickActions({required this.permissions});

  final OrgPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final actions = <_MobileAction>[
      if (permissions.canManageMaterials)
        _MobileAction(
          'Add School',
          Icons.school_outlined,
          InfraColors.royalBlue,
          () => showMaterialMasterSheet(context, MaterialMasterType.school),
        ),
      if (permissions.canOperateMaterials)
        _MobileAction(
          'Material\nIssue',
          Icons.inventory_2_outlined,
          InfraColors.green,
          () =>
              showMaterialOperationSheet(context, MaterialFormOperation.issue),
        ),
      if (permissions.canOperateMaterials)
        _MobileAction(
          'Material\nReceive',
          Icons.assignment_outlined,
          const Color(0xFF7C3AED),
          () => showMaterialOperationSheet(
            context,
            MaterialFormOperation.receive,
          ),
        ),
      _MobileAction(
        'Warehouse\nStock',
        Icons.warehouse_outlined,
        InfraColors.orange,
        () => context.push(AppRoutes.materialStock),
      ),
      _MobileAction(
        'Reports',
        Icons.bar_chart_outlined,
        const Color(0xFF00899B),
        () => context.push(AppRoutes.managerMaterialReport),
      ),
    ];
    return _MobileSectionCard(
      title: 'Quick Actions',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions
            .map((action) => _MobileActionButton(action: action))
            .toList(),
      ),
    );
  }
}

class _MobileAction {
  const _MobileAction(this.label, this.icon, this.color, this.onTap);

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _MobileActionButton extends StatelessWidget {
  const _MobileActionButton({required this.action});

  final _MobileAction action;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: action.onTap,
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: 62,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 27),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: InfraColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MobileSchoolsSection extends ConsumerWidget {
  const _MobileSchoolsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(allSchoolsProvider);
    final progressRows =
        ref.watch(schoolRequirementIssueProvider).value ??
        const <SchoolRequirementIssueRow>[];
    return _MobileSectionCard(
      title: 'My Schools',
      actionLabel: 'View All',
      onAction: () => context.push(AppRoutes.schoolMaterialReport),
      child: schools.when(
        loading: () => const _ShimmerBox(height: 150),
        error: (error, _) => Text(
          'Could not load schools: $error',
          style: const TextStyle(color: InfraColors.red),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No schools configured yet',
                style: TextStyle(color: InfraColors.textSecondary),
              ),
            );
          }
          final school = rows.first;
          final progress = progressRows
              .where((row) => row.schoolId == school.id)
              .firstOrNull;
          return _MobileSchoolCard(school: school, progress: progress);
        },
      ),
    );
  }
}

class _MobileSchoolCard extends StatelessWidget {
  const _MobileSchoolCard({required this.school, this.progress});

  final School school;
  final SchoolRequirementIssueRow? progress;

  @override
  Widget build(BuildContext context) {
    final issued = progress?.issuedPercent ?? school.progressPercent.toDouble();
    final pending = progress?.pendingPercent ?? (100 - issued).clamp(0, 100);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: InfraColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: InfraColors.royalBlue,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: InfraColors.navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        school.address ?? school.code ?? 'School site',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: InfraColors.navy,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: InfraColors.textSecondary,
                          ),
                          SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Material site',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MaterialStatusChip(status: school.status),
                    const SizedBox(height: 10),
                    const Text(
                      'Progress',
                      style: TextStyle(color: InfraColors.navy, fontSize: 12),
                    ),
                    Text(
                      '${school.progressPercent}%',
                      style: const TextStyle(
                        color: InfraColors.royalBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: InfraColors.border),
          Row(
            children: [
              _SchoolMetric(label: 'Rooms', value: school.code ?? '-'),
              _SchoolMetric(
                label: 'Required',
                value: '${formatQuantity(progress?.requiredPercent ?? 0)}%',
              ),
              _SchoolMetric(
                label: 'Issued',
                value: '${formatQuantity(issued)}%',
              ),
              _SchoolMetric(
                label: 'Pending',
                value: '${formatQuantity(pending.toDouble())}%',
                danger: pending > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchoolMetric extends StatelessWidget {
  const _SchoolMetric({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: InfraColors.border)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: InfraColors.navy, fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: danger ? InfraColors.red : InfraColors.navy,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MobileRecentIssuesSection extends ConsumerWidget {
  const _MobileRecentIssuesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MobileSectionCard(
      title: 'Recent Issues',
      actionLabel: 'View All',
      onAction: () => context.push(AppRoutes.materialIssues),
      child: ref
          .watch(recentMaterialIssuesProvider)
          .when(
            loading: () => const _LoadingRows(),
            error: (error, _) => Text(
              'Could not load issues: $error',
              style: const TextStyle(color: InfraColors.red),
            ),
            data: (rows) {
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No material issues yet',
                    style: TextStyle(color: InfraColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: rows
                    .take(3)
                    .map((row) => _MobileRecentIssueTile(row: row))
                    .toList(),
              );
            },
          ),
    );
  }
}

class _MobileRecentIssueTile extends StatelessWidget {
  const _MobileRecentIssueTile({required this.row});

  final RecentMaterialIssue row;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: InfraColors.royalBlue.withValues(alpha: 0.1),
          child: Text(
            _initials(row.managerName),
            style: const TextStyle(
              color: InfraColors.royalBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.managerName,
                style: const TextStyle(
                  color: InfraColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                row.schoolName,
                style: const TextStyle(color: InfraColors.navy, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                'Received: ${row.summaryText}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: InfraColors.navy, fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('dd MMM yyyy').format(row.issueDate),
              style: const TextStyle(
                color: InfraColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 18),
            _MaterialStatusChip(
              status: row.materialCount <= 1 ? 'complete' : 'partial',
            ),
          ],
        ),
      ],
    ),
  );
}

class _MobileSectionCard extends StatelessWidget {
  const _MobileSectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: InfraColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: InfraColors.navy,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton.icon(
                onPressed: onAction,
                label: Text(actionLabel!),
                icon: const Icon(Icons.arrow_forward),
                iconAlignment: IconAlignment.end,
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({required this.status});

  final MaterialSetupStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF2FF), Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InfraColors.royalBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: InfraColors.royalBlue,
            child: Icon(Icons.auto_awesome_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Finish material setup',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${status.completedSteps} of 6 steps complete. Create the missing records to unlock every action.',
                  style: const TextStyle(
                    color: InfraColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => showMaterialSetupSheet(context),
            child: const Text('Set up'),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends ConsumerWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenders = ref.watch(tendersProvider).value ?? const <Tender>[];
    final districts = ref.watch(districtsProvider).value ?? const <District>[];
    final warehouses =
        ref.watch(warehousesProvider).value ?? const <Warehouse>[];
    return SectionCard(
      title: 'Dashboard Filters',
      icon: Icons.tune,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 760
              ? (constraints.maxWidth - 24) / 3
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: width,
                child: _FilterDropdown(
                  label: 'Tender',
                  icon: Icons.description_outlined,
                  value: ref.watch(effectiveTenderIdProvider),
                  items: tenders
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.year == null
                                ? item.name
                                : '${item.name} - ${item.year}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (id) =>
                      ref.read(selectedTenderProvider.notifier).select(id),
                ),
              ),
              SizedBox(
                width: width,
                child: _FilterDropdown(
                  label: 'District',
                  icon: Icons.location_on_outlined,
                  value: ref.watch(selectedDistrictProvider),
                  allowAll: true,
                  items: districts
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    ref.read(selectedDistrictProvider.notifier).select(id);
                    ref.read(selectedWarehouseProvider.notifier).select(null);
                  },
                ),
              ),
              SizedBox(
                width: width,
                child: _FilterDropdown(
                  label: 'Warehouse',
                  icon: Icons.warehouse_outlined,
                  value: ref.watch(effectiveWarehouseIdProvider),
                  items: warehouses
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (id) =>
                      ref.read(selectedWarehouseProvider.notifier).select(id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.allowAll = false,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final bool allowAll;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: items.any((item) => item.value == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        if (allowAll)
          const DropdownMenuItem<String>(
            value: null,
            child: Text('All districts'),
          ),
        ...items,
      ],
      onChanged: onChanged,
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});

  final AsyncValue<MaterialDashboardSummary> summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isLoading) return const _LoadingGrid();
    final value = summary.value ?? const MaterialDashboardSummary();
    final cards = [
      _KpiData(
        'Total Schools',
        value.totalSchools,
        Icons.school_outlined,
        InfraColors.green,
      ),
      _KpiData(
        'Running Schools',
        value.runningSchools,
        Icons.construction_outlined,
        InfraColors.royalBlue,
      ),
      _KpiData(
        'Completed Schools',
        value.completedSchools,
        Icons.check_circle_outline,
        InfraColors.green,
      ),
      _KpiData(
        'Pending Schools',
        value.pendingSchools,
        Icons.pending_actions_outlined,
        InfraColors.orange,
      ),
      _KpiData(
        'Warehouse Items',
        value.totalItemsInWarehouse,
        Icons.inventory_2_outlined,
        InfraColors.royalBlue,
      ),
      _KpiData(
        'Low Stock Items',
        value.lowStockItems,
        Icons.warning_amber_rounded,
        InfraColors.red,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 6
            : constraints.maxWidth >= 650
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 2 ? 1.2 : 1.35,
          children: cards
              .map(
                (data) => KpiCard(
                  label: data.label,
                  value: '${data.value}',
                  icon: data.icon,
                  color: data.color,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.outbox_outlined,
        'Material Issue',
        InfraColors.royalBlue,
        () => showMaterialOperationSheet(context, MaterialFormOperation.issue),
      ),
      (
        Icons.move_to_inbox_outlined,
        'Material Receive',
        InfraColors.green,
        () =>
            showMaterialOperationSheet(context, MaterialFormOperation.receive),
      ),
      (
        Icons.assignment_return_outlined,
        'Material Return',
        InfraColors.orange,
        () => showMaterialOperationSheet(
          context,
          MaterialFormOperation.materialReturn,
        ),
      ),
      if (canManage)
        (
          Icons.school_outlined,
          'Add School',
          InfraColors.royalBlue,
          () => showMaterialMasterSheet(context, MaterialMasterType.school),
        ),
      if (canManage)
        (
          Icons.add_box_outlined,
          'Add Material',
          InfraColors.navy,
          () => showMaterialMasterSheet(context, MaterialMasterType.material),
        ),
      if (canManage)
        (
          Icons.settings_outlined,
          'Material Setup',
          InfraColors.gold,
          () => showMaterialSetupSheet(context),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final action in actions) ...[
                QuickActionCard(
                  icon: action.$1,
                  label: action.$2,
                  color: action.$3,
                  onTap: action.$4,
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponsiveDashboardSections extends StatelessWidget {
  const _ResponsiveDashboardSections();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return const Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _WarehouseStockSection()),
                  SizedBox(width: 14),
                  Expanded(flex: 2, child: _RecentIssuesSection()),
                ],
              ),
              SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _SchoolRequirementsSection()),
                  SizedBox(width: 14),
                  Expanded(flex: 2, child: _LowStockSection()),
                ],
              ),
              SizedBox(height: 14),
              _ManagerSummarySection(),
            ],
          );
        }
        return const Column(
          children: [
            _WarehouseStockSection(),
            SizedBox(height: 14),
            _SchoolRequirementsSection(),
            SizedBox(height: 14),
            _RecentIssuesSection(),
            SizedBox(height: 14),
            _LowStockSection(),
            SizedBox(height: 14),
            _ManagerSummarySection(),
          ],
        );
      },
    );
  }
}

class _WarehouseStockSection extends ConsumerWidget {
  const _WarehouseStockSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Warehouse Stock Summary',
      icon: Icons.warehouse_outlined,
      trailing: _ViewAll(route: AppRoutes.materialStock),
      child: _AsyncSection<List<WarehouseStockRow>>(
        value: ref.watch(warehouseStockSummaryProvider),
        emptyLabel: 'No stock received yet',
        builder: (rows) => Column(
          children: rows
              .take(6)
              .map(
                (row) => _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  title: row.materialName,
                  subtitle:
                      'Received ${formatQuantity(row.totalReceived)}  •  Issued ${formatQuantity(row.totalIssued)}',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatQuantity(row.remainingStock)} ${row.unit}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      _MaterialStatusChip(status: row.stockStatus),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SchoolRequirementsSection extends ConsumerWidget {
  const _SchoolRequirementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'School Requirement vs Issue',
      icon: Icons.school_outlined,
      trailing: _ViewAll(route: AppRoutes.schoolMaterialReport),
      child: _AsyncSection<List<SchoolRequirementIssueRow>>(
        value: ref.watch(schoolRequirementIssueProvider),
        emptyLabel: 'No school requirements yet',
        builder: (rows) => Column(
          children: rows.take(6).map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.schoolName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _MaterialStatusChip(status: row.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (row.issuedPercent / 100).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: InfraColors.border,
                      color: row.status == 'complete'
                          ? InfraColors.green
                          : InfraColors.royalBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Issued ${formatQuantity(row.issuedPercent)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: InfraColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Pending ${formatQuantity(row.pendingPercent)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: InfraColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecentIssuesSection extends ConsumerWidget {
  const _RecentIssuesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Recent Material Issues',
      icon: Icons.outbox_outlined,
      trailing: _ViewAll(route: AppRoutes.materialIssues),
      child: _AsyncSection<List<RecentMaterialIssue>>(
        value: ref.watch(recentMaterialIssuesProvider),
        emptyLabel: 'No material issues yet',
        builder: (rows) => Column(
          children: rows
              .take(5)
              .map(
                (row) => _InfoRow(
                  icon: null,
                  leading: CircleAvatar(
                    backgroundColor: InfraColors.royalBlue.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      _initials(row.managerName),
                      style: const TextStyle(
                        color: InfraColors.royalBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: row.managerName,
                  subtitle:
                      '${row.schoolName}\n${row.summaryText}\n${DateFormat('dd MMM yyyy').format(row.issueDate)}',
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LowStockSection extends ConsumerWidget {
  const _LowStockSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Low Stock Alert',
      icon: Icons.warning_amber_rounded,
      trailing: _ViewAll(route: AppRoutes.materialLowStock),
      child: _AsyncSection<List<LowStockAlert>>(
        value: ref.watch(lowStockAlertsProvider),
        emptyLabel: 'Stock levels look healthy',
        builder: (rows) => Column(
          children: rows
              .take(6)
              .map(
                (row) => _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  title: row.materialName,
                  subtitle:
                      '${formatQuantity(row.remainingStock)} ${row.unit} remaining',
                  trailing: _MaterialStatusChip(status: row.alertLevel),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ManagerSummarySection extends ConsumerWidget {
  const _ManagerSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Manager Wise Material Issue Summary',
      icon: Icons.groups_outlined,
      trailing: _ViewAll(route: AppRoutes.managerMaterialReport),
      child: _AsyncSection<List<ManagerMaterialIssueRow>>(
        value: ref.watch(managerMaterialIssueSummaryProvider),
        emptyLabel: 'No manager issues yet',
        builder: (rows) {
          final groups = <String, List<ManagerMaterialIssueRow>>{};
          for (final row in rows) {
            groups
                .putIfAbsent('${row.managerId}:${row.schoolName}', () => [])
                .add(row);
          }
          return Column(
            children: groups.values.take(6).map((items) {
              final first = items.first;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF2FF),
                    child: Icon(
                      Icons.person_outline,
                      color: InfraColors.royalBlue,
                    ),
                  ),
                  title: Text(
                    first.managerName,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${first.schoolName} • ${formatQuantity(first.totalItems)} total',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items
                            .map(
                              (item) => Chip(
                                label: Text(
                                  '${item.materialName}: ${formatQuantity(item.issuedQuantity)} ${item.unit}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _MaterialFlow extends StatelessWidget {
  const _MaterialFlow({required this.summary});

  final MaterialDashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.warehouse_outlined,
        'Warehouse',
        '${formatQuantity(summary?.totalReceivedQuantity ?? 0)} received',
        InfraColors.green,
      ),
      (
        Icons.groups_outlined,
        'Managers',
        '${formatQuantity(summary?.totalIssuedQuantity ?? 0)} issued',
        InfraColors.royalBlue,
      ),
      (
        Icons.school_outlined,
        'Schools',
        '${summary?.totalSchools ?? 0} schools',
        InfraColors.orange,
      ),
      (
        Icons.fact_check_outlined,
        'Work Progress',
        '${summary?.completedSchools ?? 0} completed',
        InfraColors.green,
      ),
    ];
    return SectionCard(
      title: 'Material Flow Summary',
      icon: Icons.account_tree_outlined,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: steps[index].$4.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: steps[index].$4.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(steps[index].$1, color: steps[index].$4, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      steps[index].$2,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      steps[index].$3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: InfraColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Icon(
                    Icons.arrow_forward,
                    color: InfraColors.royalBlue,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.value,
    required this.builder,
    required this.emptyLabel,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const _LoadingRows(),
      error: (error, _) => Text(
        'Could not load: $error',
        style: const TextStyle(color: InfraColors.red),
      ),
      data: (data) {
        if (data is Iterable && data.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                emptyLabel,
                style: const TextStyle(color: InfraColors.textSecondary),
              ),
            ),
          );
        }
        return builder(data);
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
  });

  final IconData? icon;
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading ??
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: InfraColors.royalBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: InfraColors.royalBlue),
              ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: InfraColors.textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _MaterialStatusChip extends StatelessWidget {
  const _MaterialStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.replaceAll('_', ' ');
    final color = switch (status) {
      'complete' || 'in_stock' => InfraColors.green,
      'partial' || 'medium' => InfraColors.orange,
      'pending' => InfraColors.orange,
      _ => InfraColors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${normalized[0].toUpperCase()}${normalized.substring(1)}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ViewAll extends StatelessWidget {
  const _ViewAll({required this.route});
  final String route;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => context.push(route),
    child: const Text('View all'),
  );
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) => const _ShimmerBox(height: 260);
}

class _LoadingRows extends StatelessWidget {
  const _LoadingRows();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      _ShimmerBox(height: 48),
      SizedBox(height: 10),
      _ShimmerBox(height: 48),
      SizedBox(height: 10),
      _ShimmerBox(height: 48),
    ],
  );
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: InfraColors.border,
    highlightColor: Colors.white,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

class _KpiData {
  const _KpiData(this.label, this.value, this.icon, this.color);
  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return '?';
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}
