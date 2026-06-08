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
import 'school_evidence_capture.dart';

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
      backgroundColor: Colors.white,
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
      bottomNavigationBar: _MaterialBottomBar(
        selectedIndex: _index,
        onSelected: (index) {
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
    final permissions = ref.watch(currentOrgPermissionsProvider);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.paddingOf(context).top + 8,
        12,
        10,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to home',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.menu_rounded, color: InfraColors.navy),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: tenders.any((item) => item.id == selectedTender)
                    ? selectedTender
                    : null,
                isExpanded: true,
                hint: Text(
                  permissions.canManageMaterials
                      ? 'Create Tender'
                      : 'No tender assigned',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: InfraColors.navy,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: InfraColors.navy,
                ),
                selectedItemBuilder: (context) => tenders
                    .map(
                      (item) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.year == null
                              ? item.name
                              : '${item.name} - ${item.year}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: InfraColors.navy,
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Low stock alerts',
                onPressed: () => context.push(AppRoutes.materialLowStock),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: InfraColors.navy,
                ),
              ),
              Positioned(
                right: 7,
                top: 7,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: InfraColors.red,
                  child: Text(
                    '${lowStock == 0 ? 0 : lowStock}',
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
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => showMaterialSetupSheet(context),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFEAF2FF),
              child: Icon(Icons.person, color: InfraColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialBottomBar extends StatelessWidget {
  const _MaterialBottomBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomItem(
              index: 0,
              selectedIndex: selectedIndex,
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: 'Dashboard',
              onTap: onSelected,
            ),
            _BottomItem(
              index: 1,
              selectedIndex: selectedIndex,
              icon: Icons.school_outlined,
              selectedIcon: Icons.school,
              label: 'Schools',
              onTap: onSelected,
            ),
            _BottomItem(
              index: 2,
              selectedIndex: selectedIndex,
              icon: Icons.add,
              selectedIcon: Icons.add,
              label: 'Issue',
              center: true,
              onTap: onSelected,
            ),
            _BottomItem(
              index: 3,
              selectedIndex: selectedIndex,
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              label: 'Warehouse',
              onTap: onSelected,
            ),
            _BottomItem(
              index: 4,
              selectedIndex: selectedIndex,
              icon: Icons.description_outlined,
              selectedIcon: Icons.description,
              label: 'Reports',
              onTap: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
    this.center = false,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    final color = selected ? InfraColors.royalBlue : InfraColors.navy;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onTap(index),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: center ? 52 : 36,
              height: center ? 52 : 36,
              decoration: center
                  ? const BoxDecoration(
                      color: InfraColors.royalBlue,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                selected ? selectedIcon : icon,
                color: center ? Colors.white : color,
                size: center ? 30 : 25,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolsTab extends ConsumerWidget {
  const _SchoolsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(allSchoolsProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    return _ModuleListPage(
      title: 'Schools',
      subtitle: 'Track work progress and material requirements',
      actionLabel: permissions.canManageMaterials ? 'Add School' : null,
      actionIcon: permissions.canManageMaterials
          ? Icons.add_business_outlined
          : null,
      onAction: permissions.canManageMaterials
          ? () => showMaterialMasterSheet(context, MaterialMasterType.school)
          : null,
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SchoolInfoChip(
                  icon: Icons.meeting_room_outlined,
                  label: '${school.roomQuantity} rooms',
                ),
                _SchoolInfoChip(
                  icon: Icons.add_a_photo_outlined,
                  label:
                      '${school.gpsPhotoPaths.length} GPS photo${school.gpsPhotoPaths.length == 1 ? '' : 's'}',
                ),
                if (school.gpsLatitude != null && school.gpsLongitude != null)
                  _SchoolInfoChip(
                    icon: Icons.my_location_outlined,
                    label:
                        '${school.gpsLatitude!.toStringAsFixed(4)}, ${school.gpsLongitude!.toStringAsFixed(4)}',
                  ),
              ],
            ),
            Consumer(
              builder: (context, ref, _) {
                final permissions = ref.watch(currentOrgPermissionsProvider);
                if (!permissions.canUpdateProgress) {
                  return const SizedBox(height: 8);
                }
                return Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _editSchoolProgress(context, ref, school),
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Update progress'),
                  ),
                );
              },
            ),
            if (ref.watch(currentOrgPermissionsProvider).canManageMaterials)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => showMaterialManageSheet(
                    context,
                    MaterialMasterType.school,
                  ),
                  icon: const Icon(Icons.tune_outlined, size: 17),
                  label: const Text('Manage schools'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SchoolInfoChip extends StatelessWidget {
  const _SchoolInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 16, color: InfraColors.royalBlue),
    label: Text(label),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

Future<void> _editSchoolProgress(
  BuildContext context,
  WidgetRef ref,
  School school,
) async {
  var progress = school.progressPercent.toDouble();
  final rooms = TextEditingController(text: '${school.roomQuantity}');
  final photos = <CapturedSchoolEvidence>[];
  final saved = await showDialog<_SchoolProgressEvidenceUpdate>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Update ${school.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${progress.round()}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Slider(
                value: progress,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => setState(() => progress = value),
              ),
              TextFormField(
                controller: rooms,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rooms quantity',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${school.gpsPhotoPaths.length + photos.length} GPS photo${school.gpsPhotoPaths.length + photos.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final captured = await captureSchoolEvidencePhoto();
                    if (captured == null) return;
                    setState(() => photos.add(captured));
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not capture GPS photo: $error'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Capture GPS photo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final roomQuantity = int.tryParse(rooms.text.trim());
              if (roomQuantity == null || roomQuantity < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter zero or more rooms.')),
                );
                return;
              }
              context.pop(
                _SchoolProgressEvidenceUpdate(
                  progressPercent: progress.round(),
                  roomQuantity: roomQuantity,
                  photos: List.unmodifiable(photos),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  rooms.dispose();
  if (saved == null || !context.mounted) return;
  try {
    final org = await ref.read(infraWorkspaceProvider.future);
    final repository = ref.read(materialRepositoryProvider);
    await repository.updateSchoolProgress(
      organizationId: org.id,
      schoolId: school.id,
      progressPercent: saved.progressPercent,
    );
    final uploaded = await uploadSchoolEvidencePhotos(
      repository: repository,
      organizationId: org.id,
      schoolId: school.id,
      photos: saved.photos,
    );
    await repository.addSchoolEvidence(
      organizationId: org.id,
      schoolId: school.id,
      roomQuantity: saved.roomQuantity,
      photoPaths: uploaded?.photoPaths ?? const [],
      gpsLatitude: uploaded?.latitude,
      gpsLongitude: uploaded?.longitude,
      gpsAccuracyMeters: uploaded?.accuracyMeters,
      gpsCapturedAt: uploaded?.capturedAt,
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

class _SchoolProgressEvidenceUpdate {
  const _SchoolProgressEvidenceUpdate({
    required this.progressPercent,
    required this.roomQuantity,
    required this.photos,
  });

  final int progressPercent;
  final int roomQuantity;
  final List<CapturedSchoolEvidence> photos;
}

class _WarehouseTab extends ConsumerWidget {
  const _WarehouseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouses = ref.watch(allWarehousesProvider);
    final stock = ref.watch(warehouseStockSummaryProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    return _ModuleListPage(
      title: 'Warehouse',
      subtitle: 'Receive stock and monitor remaining quantities',
      actionLabel: permissions.canOperateMaterials ? 'Receive' : null,
      actionIcon: permissions.canOperateMaterials
          ? Icons.move_to_inbox_outlined
          : null,
      onAction: permissions.canOperateMaterials
          ? () => showMaterialOperationSheet(
              context,
              MaterialFormOperation.receive,
            )
          : null,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (permissions.canManageMaterials || permissions.canOperateMaterials)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (permissions.canManageMaterials)
                  ActionChip(
                    avatar: const Icon(Icons.add_business_outlined, size: 18),
                    label: const Text('Manage warehouses'),
                    onPressed: () => showMaterialManageSheet(
                      context,
                      MaterialMasterType.warehouse,
                    ),
                  ),
                if (permissions.canManageMaterials)
                  ActionChip(
                    avatar: const Icon(Icons.add_box_outlined, size: 18),
                    label: const Text('Manage materials'),
                    onPressed: () => showMaterialManageSheet(
                      context,
                      MaterialMasterType.material,
                    ),
                  ),
                if (permissions.canOperateMaterials)
                  ActionChip(
                    avatar: const Icon(
                      Icons.assignment_return_outlined,
                      size: 18,
                    ),
                    label: const Text('Return'),
                    onPressed: () => showMaterialOperationSheet(
                      context,
                      MaterialFormOperation.materialReturn,
                    ),
                  ),
              ],
            ),
          if (permissions.canManageMaterials || permissions.canOperateMaterials)
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
