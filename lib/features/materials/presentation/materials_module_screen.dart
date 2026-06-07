import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../shared/models/material_models.dart';
import 'material_master_form.dart';
import 'material_operation_form.dart';
import 'materials_dashboard_screen.dart';

class MaterialsModuleScreen extends ConsumerStatefulWidget {
  const MaterialsModuleScreen({super.key});

  @override
  ConsumerState<MaterialsModuleScreen> createState() =>
      _MaterialsModuleScreenState();
}

class _MaterialsModuleScreenState extends ConsumerState<MaterialsModuleScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(currentOrgPermissionsProvider);
    return Scaffold(
      backgroundColor: InfraColors.background,
      body: Column(
        children: [
          const _ModuleHeader(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                MaterialsDashboardScreen(),
                _SchoolsTab(),
                SizedBox.shrink(),
                _WarehouseTab(),
                _ReportsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: InfraColors.navy,
        indicatorColor: const Color(0xFF0B3E74),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == 2) {
            if (permissions.canOperateMaterials) {
              showMaterialOperationSheet(context, MaterialFormOperation.issue);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You do not have permission to issue material'),
                ),
              );
            }
            return;
          }
          setState(() => _index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.dashboard, color: InfraColors.gold),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.school, color: InfraColors.gold),
            label: 'Schools',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle, color: InfraColors.gold, size: 34),
            label: 'Issue',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.warehouse, color: InfraColors.gold),
            label: 'Warehouse',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.description, color: InfraColors.gold),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class _ModuleHeader extends ConsumerWidget {
  const _ModuleHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenders = ref.watch(tendersProvider).value ?? const <Tender>[];
    final selectedTender = ref.watch(effectiveTenderIdProvider);
    final lowStock =
        ref.watch(materialDashboardSummaryProvider).value?.lowStockItems ?? 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.paddingOf(context).top + 10,
        12,
        16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [InfraColors.navy, Color(0xFF0B447E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to home',
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: InfraColors.gold,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Warehouse & School Tracking',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Low stock alerts',
                    onPressed: () => context.push(AppRoutes.materialLowStock),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                  ),
                  if (lowStock > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: InfraColors.red,
                        child: Text(
                          '$lowStock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                tooltip: 'Material setup',
                onPressed: () => showMaterialSetupSheet(context),
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: tenders.any((item) => item.id == selectedTender)
                    ? selectedTender
                    : null,
                isExpanded: true,
                hint: const Text('Select or create a tender'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                onChanged: tenders.isEmpty
                    ? null
                    : (value) => ref
                          .read(selectedTenderProvider.notifier)
                          .select(value),
              ),
            ),
          ),
          if (tenders.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    showMaterialMasterSheet(context, MaterialMasterType.tender),
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  'Create your first tender',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SchoolsTab extends ConsumerWidget {
  const _SchoolsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(allSchoolsProvider);
    return _ModuleListPage(
      title: 'Schools',
      subtitle: 'Track work progress and material requirements',
      actionLabel: 'Add School',
      actionIcon: Icons.add_business_outlined,
      onAction: () =>
          showMaterialMasterSheet(context, MaterialMasterType.school),
      child: schools.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            _ErrorCard(message: 'Could not load schools: $error'),
        data: (rows) {
          if (rows.isEmpty) {
            return _EmptyAction(
              icon: Icons.school_outlined,
              title: 'No schools configured',
              message:
                  'Create a tender and district, then add your first school.',
              actionLabel: 'Open material setup',
              onPressed: () => showMaterialSetupSheet(context),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _SchoolCard(school: rows[index]),
          );
        },
      ),
    );
  }
}

class _SchoolCard extends ConsumerWidget {
  const _SchoolCard({required this.school});

  final School school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF2FF),
                  child: Icon(
                    Icons.school_outlined,
                    color: InfraColors.royalBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        school.address ?? school.code ?? 'School site',
                        style: const TextStyle(
                          color: InfraColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${school.progressPercent}%',
                  style: const TextStyle(
                    color: InfraColors.royalBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: school.progressPercent / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: InfraColors.border,
              color: school.progressPercent == 100
                  ? InfraColors.green
                  : InfraColors.royalBlue,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _editSchoolProgress(context, ref, school),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Update progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editSchoolProgress(
  BuildContext context,
  WidgetRef ref,
  School school,
) async {
  var progress = school.progressPercent.toDouble();
  final saved = await showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Update ${school.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${progress.round()}%',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            Slider(
              value: progress,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) => setState(() => progress = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(progress.round()),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  if (saved == null || !context.mounted) return;
  try {
    final org = await ref.read(infraWorkspaceProvider.future);
    await ref
        .read(materialRepositoryProvider)
        .updateSchoolProgress(
          organizationId: org.id,
          schoolId: school.id,
          progressPercent: saved,
        );
    invalidateMaterialProviders(ref);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update progress: $error')),
      );
    }
  }
}

class _WarehouseTab extends ConsumerWidget {
  const _WarehouseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouses = ref.watch(allWarehousesProvider);
    final stock = ref.watch(warehouseStockSummaryProvider);
    return _ModuleListPage(
      title: 'Warehouse',
      subtitle: 'Receive stock and monitor remaining quantities',
      actionLabel: 'Receive',
      actionIcon: Icons.move_to_inbox_outlined,
      onAction: () =>
          showMaterialOperationSheet(context, MaterialFormOperation.receive),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.add_business_outlined, size: 18),
                label: const Text('Add warehouse'),
                onPressed: () => showMaterialMasterSheet(
                  context,
                  MaterialMasterType.warehouse,
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Add material'),
                onPressed: () => showMaterialMasterSheet(
                  context,
                  MaterialMasterType.material,
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.assignment_return_outlined, size: 18),
                label: const Text('Return'),
                onPressed: () => showMaterialOperationSheet(
                  context,
                  MaterialFormOperation.materialReturn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Warehouses',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          warehouses.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                _ErrorCard(message: 'Could not load warehouses: $error'),
            data: (rows) => rows.isEmpty
                ? _EmptyAction(
                    icon: Icons.warehouse_outlined,
                    title: 'No warehouse configured',
                    message: 'Open setup and create a district and warehouse.',
                    actionLabel: 'Open material setup',
                    onPressed: () => showMaterialSetupSheet(context),
                  )
                : Column(
                    children: rows
                        .map(
                          (row) => Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.warehouse_outlined,
                                color: InfraColors.orange,
                              ),
                              title: Text(row.name),
                              subtitle: Text(
                                row.address ??
                                    (row.isCentral
                                        ? 'Central warehouse'
                                        : 'Warehouse'),
                              ),
                              trailing: row.isCentral
                                  ? const Chip(label: Text('Central'))
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            'Stock summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          stock.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                _ErrorCard(message: 'Could not load stock: $error'),
            data: (rows) => rows.isEmpty
                ? const _ErrorCard(message: 'No stock received yet.')
                : Column(
                    children: rows
                        .map(
                          (row) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(row.materialName),
                              subtitle: Text(
                                'Received ${formatQuantity(row.totalReceived)} • Issued ${formatQuantity(row.totalIssued)}',
                              ),
                              trailing: Text(
                                '${formatQuantity(row.remainingStock)} ${row.unit}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = [
      ('Warehouse Stock', Icons.warehouse_outlined, AppRoutes.materialStock),
      ('Material Issues', Icons.outbox_outlined, AppRoutes.materialIssues),
      (
        'Low Stock Alerts',
        Icons.warning_amber_rounded,
        AppRoutes.materialLowStock,
      ),
      ('School Report', Icons.school_outlined, AppRoutes.schoolMaterialReport),
      (
        'Manager Report',
        Icons.groups_outlined,
        AppRoutes.managerMaterialReport,
      ),
    ];
    return _ModuleListPage(
      title: 'Material Reports',
      subtitle: 'Review stock, schools, issues, and managers',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: reports.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            child: ListTile(
              onTap: () => context.push(report.$3),
              leading: CircleAvatar(
                backgroundColor: InfraColors.royalBlue.withValues(alpha: 0.1),
                child: Icon(report.$2, color: InfraColors.royalBlue),
              ),
              title: Text(
                report.$1,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              trailing: const Icon(Icons.arrow_forward),
            ),
          );
        },
      ),
    );
  }
}

class _ModuleListPage extends StatelessWidget {
  const _ModuleListPage({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: InfraColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (onAction != null)
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon),
                label: Text(actionLabel!),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: child),
      ],
    ),
  );
}

class _EmptyAction extends StatelessWidget {
  const _EmptyAction({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: InfraColors.royalBlue),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: InfraColors.textSecondary),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: const TextStyle(color: InfraColors.textSecondary),
      ),
    ),
  );
}
