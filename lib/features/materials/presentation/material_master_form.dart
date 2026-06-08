import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../shared/models/material_models.dart';

enum MaterialMasterType {
  tender,
  district,
  warehouse,
  manager,
  school,
  material,
}

extension MaterialMasterTypeUi on MaterialMasterType {
  String get addTitle => switch (this) {
    MaterialMasterType.tender => 'Add Tender',
    MaterialMasterType.district => 'Add District',
    MaterialMasterType.warehouse => 'Add Warehouse',
    MaterialMasterType.manager => 'Add Manager',
    MaterialMasterType.school => 'Add School',
    MaterialMasterType.material => 'Add Material Item',
  };

  String get editTitle => switch (this) {
    MaterialMasterType.tender => 'Update Tender',
    MaterialMasterType.district => 'Update District',
    MaterialMasterType.warehouse => 'Update Warehouse',
    MaterialMasterType.manager => 'Update Manager',
    MaterialMasterType.school => 'Update School',
    MaterialMasterType.material => 'Update Material Item',
  };

  String get manageTitle => switch (this) {
    MaterialMasterType.tender => 'Manage Tenders',
    MaterialMasterType.district => 'Manage Districts',
    MaterialMasterType.warehouse => 'Manage Warehouses',
    MaterialMasterType.manager => 'Manage Managers',
    MaterialMasterType.school => 'Manage Schools',
    MaterialMasterType.material => 'Manage Material Items',
  };

  String get singular => switch (this) {
    MaterialMasterType.tender => 'Tender',
    MaterialMasterType.district => 'District',
    MaterialMasterType.warehouse => 'Warehouse',
    MaterialMasterType.manager => 'Manager',
    MaterialMasterType.school => 'School',
    MaterialMasterType.material => 'Material',
  };

  String get plural => switch (this) {
    MaterialMasterType.tender => 'Tenders',
    MaterialMasterType.district => 'Districts',
    MaterialMasterType.warehouse => 'Warehouses',
    MaterialMasterType.manager => 'Managers',
    MaterialMasterType.school => 'Schools',
    MaterialMasterType.material => 'Materials',
  };

  IconData get icon => switch (this) {
    MaterialMasterType.tender => Icons.description_outlined,
    MaterialMasterType.district => Icons.location_on_outlined,
    MaterialMasterType.warehouse => Icons.warehouse_outlined,
    MaterialMasterType.manager => Icons.person_add_alt_1_outlined,
    MaterialMasterType.school => Icons.school_outlined,
    MaterialMasterType.material => Icons.inventory_2_outlined,
  };

  Color get color => switch (this) {
    MaterialMasterType.tender => const Color(0xFF6D4AFF),
    MaterialMasterType.district => InfraColors.orange,
    MaterialMasterType.warehouse => const Color(0xFFEA7B21),
    MaterialMasterType.manager => const Color(0xFF00899B),
    MaterialMasterType.school => InfraColors.royalBlue,
    MaterialMasterType.material => InfraColors.green,
  };
}

class MaterialMasterForm extends ConsumerStatefulWidget {
  const MaterialMasterForm({super.key, required this.type, this.initial});

  final MaterialMasterType type;
  final Object? initial;

  @override
  ConsumerState<MaterialMasterForm> createState() => _MaterialMasterFormState();
}

class _MaterialMasterFormState extends ConsumerState<MaterialMasterForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _year = TextEditingController(text: '${DateTime.now().year}');
  final _description = TextEditingController();
  final _state = TextEditingController(text: 'Bihar');
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _managerName = TextEditingController();
  final _roleLabel = TextEditingController(text: 'Project Manager');
  final _unit = TextEditingController();
  final _sku = TextEditingController();
  final _category = TextEditingController();
  final _threshold = TextEditingController(text: '0');

  String? _tenderId;
  String? _districtId;
  String? _managerId;
  String _tenderStatus = 'active';
  String _schoolStatus = 'not_started';
  double _progress = 0;
  bool _isCentral = false;
  bool _managerActive = true;
  bool _submitting = false;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _hydrateInitial();
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _year.dispose();
    _description.dispose();
    _state.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _managerName.dispose();
    _roleLabel.dispose();
    _unit.dispose();
    _sku.dispose();
    _category.dispose();
    _threshold.dispose();
    super.dispose();
  }

  void _hydrateInitial() {
    final initial = widget.initial;
    if (initial is Tender) {
      _name.text = initial.name;
      _code.text = initial.code ?? '';
      _year.text = '${initial.year ?? DateTime.now().year}';
      _description.text = initial.description ?? '';
      _tenderStatus = initial.status;
    } else if (initial is District) {
      _name.text = initial.name;
      _state.text = initial.state ?? 'Bihar';
    } else if (initial is Warehouse) {
      _name.text = initial.name;
      _districtId = initial.districtId;
      _address.text = initial.address ?? '';
      _managerName.text = initial.managerName ?? '';
      _phone.text = initial.phone ?? '';
      _isCentral = initial.isCentral;
    } else if (initial is SiteManager) {
      _name.text = initial.fullName;
      _phone.text = initial.phone ?? '';
      _email.text = initial.email ?? '';
      _roleLabel.text = initial.roleLabel;
      _managerActive = initial.active;
    } else if (initial is School) {
      _name.text = initial.name;
      _tenderId = initial.tenderId;
      _districtId = initial.districtId;
      _managerId = initial.assignedManagerId;
      _code.text = initial.code ?? '';
      _address.text = initial.address ?? '';
      _schoolStatus = initial.status;
      _progress = initial.progressPercent.toDouble();
    } else if (initial is MaterialItem) {
      _name.text = initial.name;
      _unit.text = initial.unit;
      _sku.text = initial.sku ?? '';
      _category.text = initial.category ?? '';
      _threshold.text = formatQuantity(initial.lowStockThreshold);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenders = ref.watch(tendersProvider).value ?? const <Tender>[];
    final districts = ref.watch(districtsProvider).value ?? const <District>[];
    final managers =
        ref.watch(siteManagersProvider).value ?? const <SiteManager>[];
    final missingDependencies = _missingDependencies(
      tenders: tenders,
      districts: districts,
    );

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            _FormTitle(type: widget.type, editing: _editing),
            const SizedBox(height: 20),
            if (missingDependencies.isNotEmpty)
              _DependencyWarning(message: missingDependencies),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: '${widget.type.singular} name',
                prefixIcon: Icon(widget.type.icon),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            ..._fieldsForType(
              tenders: tenders,
              districts: districts,
              managers: managers,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _submitting || missingDependencies.isNotEmpty
                  ? null
                  : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(widget.type.icon),
              label: Text(
                _submitting
                    ? 'Saving...'
                    : _editing
                    ? widget.type.editTitle
                    : widget.type.addTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _fieldsForType({
    required List<Tender> tenders,
    required List<District> districts,
    required List<SiteManager> managers,
  }) {
    switch (widget.type) {
      case MaterialMasterType.tender:
        return [
          _field(_code, 'Tender code', Icons.tag_outlined),
          _field(
            _year,
            'Year',
            Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              final year = int.tryParse(value?.trim() ?? '');
              return year == null || year < 2000 || year > 2100
                  ? 'Enter a valid year'
                  : null;
            },
          ),
          if (_editing)
            _statusDropdown(
              label: 'Tender status',
              value: _tenderStatus,
              values: const ['active', 'completed', 'on_hold', 'cancelled'],
              onChanged: (value) => setState(() => _tenderStatus = value),
            ),
          _field(
            _description,
            'Description',
            Icons.notes_outlined,
            maxLines: 3,
          ),
        ];
      case MaterialMasterType.district:
        return [
          _field(_state, 'State', Icons.map_outlined, validator: _required),
        ];
      case MaterialMasterType.manager:
        return [
          _field(_phone, 'Phone', Icons.phone_outlined),
          _field(
            _email,
            'Email',
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _field(_roleLabel, 'Role label', Icons.badge_outlined),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _managerActive,
            title: const Text(
              'Active manager',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            onChanged: (value) => setState(() => _managerActive = value),
          ),
        ];
      case MaterialMasterType.warehouse:
        return [
          _dropdown<District>(
            label: 'District',
            value: _districtId,
            items: districts,
            id: (item) => item.id,
            title: (item) => item.name,
            onChanged: (value) => setState(() => _districtId = value),
          ),
          _field(
            _address,
            'Address',
            Icons.location_city_outlined,
            maxLines: 2,
          ),
          _field(_managerName, 'Warehouse manager name', Icons.person_outline),
          _field(_phone, 'Phone', Icons.phone_outlined),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _isCentral,
            title: const Text(
              'Central Warehouse',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Use this as the primary organization stock'),
            onChanged: (value) => setState(() => _isCentral = value),
          ),
          const SizedBox(height: 8),
        ];
      case MaterialMasterType.school:
        return [
          _dropdown<Tender>(
            label: 'Tender',
            value: _tenderId,
            items: tenders,
            id: (item) => item.id,
            title: (item) =>
                item.year == null ? item.name : '${item.name} - ${item.year}',
            onChanged: (value) => setState(() => _tenderId = value),
          ),
          _dropdown<District>(
            label: 'District',
            value: _districtId,
            items: districts,
            id: (item) => item.id,
            title: (item) => item.name,
            onChanged: (value) => setState(() => _districtId = value),
          ),
          _dropdown<SiteManager>(
            label: 'Manager (optional)',
            value: _managerId,
            items: managers,
            id: (item) => item.id,
            title: (item) => item.fullName,
            required: false,
            onChanged: (value) => setState(() => _managerId = value),
          ),
          _field(_code, 'School code', Icons.tag_outlined),
          _field(
            _address,
            'Address',
            Icons.location_city_outlined,
            maxLines: 2,
          ),
          if (_editing) ...[
            _statusDropdown(
              label: 'School status',
              value: _schoolStatus,
              values: const ['not_started', 'running', 'completed', 'on_hold'],
              onChanged: (value) => setState(() => _schoolStatus = value),
            ),
            Text(
              'Progress ${_progress.round()}%',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _progress,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) => setState(() => _progress = value),
            ),
          ],
        ];
      case MaterialMasterType.material:
        return [
          _field(
            _unit,
            'Unit',
            Icons.straighten_outlined,
            validator: _required,
          ),
          _field(_sku, 'SKU', Icons.qr_code_2_outlined),
          _field(_category, 'Category', Icons.category_outlined),
          _field(
            _threshold,
            'Low stock threshold',
            Icons.warning_amber_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final parsed = double.tryParse(value?.trim() ?? '');
              return parsed == null || parsed < 0 ? 'Enter zero or more' : null;
            },
          ),
        ];
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required String? value,
    required List<T> items,
    required String Function(T) id,
    required String Function(T) title,
    required ValueChanged<String?> onChanged,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: items.any((item) => id(item) == value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          if (!required)
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Not assigned'),
            ),
          ...items.map(
            (item) => DropdownMenuItem(
              value: id(item),
              child: Text(title(item), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
        validator: required
            ? (selected) => selected == null ? 'Select $label' : null
            : null,
      ),
    );
  }

  Widget _statusDropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: values.contains(value) ? value : values.first,
        decoration: InputDecoration(labelText: label),
        items: values
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(_statusLabel(item)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  String _missingDependencies({
    required List<Tender> tenders,
    required List<District> districts,
  }) {
    if (widget.type == MaterialMasterType.warehouse && districts.isEmpty) {
      return 'Create a district before adding a warehouse.';
    }
    if (widget.type == MaterialMasterType.school) {
      if (tenders.isEmpty && districts.isEmpty) {
        return 'Create a tender and district before adding a school.';
      }
      if (tenders.isEmpty) return 'Create a tender before adding a school.';
      if (districts.isEmpty) return 'Create a district before adding a school.';
    }
    return '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _submitting = true);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      final repository = ref.read(materialRepositoryProvider);
      String? savedId = _editing ? _idFor(widget.initial!) : null;
      switch (widget.type) {
        case MaterialMasterType.tender:
          if (_editing) {
            await repository.updateTender(
              organizationId: org.id,
              tenderId: savedId!,
              name: _name.text,
              code: _code.text,
              year: int.tryParse(_year.text),
              status: _tenderStatus,
              description: _description.text,
            );
          } else {
            savedId = await repository.createTender(
              organizationId: org.id,
              name: _name.text,
              code: _code.text,
              year: int.tryParse(_year.text),
              description: _description.text,
            );
          }
          ref.read(selectedTenderProvider.notifier).select(savedId);
        case MaterialMasterType.district:
          if (_editing) {
            await repository.updateDistrict(
              organizationId: org.id,
              districtId: savedId!,
              name: _name.text,
              state: _state.text,
            );
          } else {
            savedId = await repository.createDistrict(
              organizationId: org.id,
              name: _name.text,
              state: _state.text,
            );
          }
          ref.read(selectedDistrictProvider.notifier).select(savedId);
        case MaterialMasterType.manager:
          if (_editing) {
            await repository.updateManager(
              organizationId: org.id,
              managerId: savedId!,
              fullName: _name.text,
              phone: _phone.text,
              email: _email.text,
              roleLabel: _roleLabel.text,
              active: _managerActive,
            );
          } else {
            savedId = await repository.createManager(
              organizationId: org.id,
              fullName: _name.text,
              phone: _phone.text,
              email: _email.text,
              roleLabel: _roleLabel.text,
            );
          }
        case MaterialMasterType.warehouse:
          if (_editing) {
            await repository.updateWarehouse(
              organizationId: org.id,
              warehouseId: savedId!,
              name: _name.text,
              districtId: _districtId,
              address: _address.text,
              managerName: _managerName.text,
              phone: _phone.text,
              isCentral: _isCentral,
            );
          } else {
            savedId = await repository.createWarehouse(
              organizationId: org.id,
              name: _name.text,
              districtId: _districtId,
              address: _address.text,
              managerName: _managerName.text,
              phone: _phone.text,
              isCentral: _isCentral,
            );
          }
          ref.read(selectedWarehouseProvider.notifier).select(savedId);
        case MaterialMasterType.school:
          if (_editing) {
            await repository.updateSchool(
              organizationId: org.id,
              schoolId: savedId!,
              tenderId: _tenderId!,
              districtId: _districtId,
              name: _name.text,
              code: _code.text,
              address: _address.text,
              status: _schoolStatus,
              progressPercent: _progress.round(),
              assignedManagerId: _managerId,
            );
          } else {
            savedId = await repository.createSchool(
              organizationId: org.id,
              tenderId: _tenderId!,
              districtId: _districtId!,
              name: _name.text,
              code: _code.text,
              address: _address.text,
              assignedManagerId: _managerId,
            );
          }
        case MaterialMasterType.material:
          if (_editing) {
            await repository.updateMaterialItem(
              organizationId: org.id,
              materialId: savedId!,
              name: _name.text,
              unit: _unit.text,
              sku: _sku.text,
              category: _category.text,
              lowStockThreshold: double.parse(_threshold.text),
            );
          } else {
            savedId = await repository.addMaterialItem(
              organizationId: org.id,
              name: _name.text,
              unit: _unit.text,
              sku: _sku.text,
              category: _category.text,
              lowStockThreshold: double.parse(_threshold.text),
            );
          }
      }
      invalidateMaterialProviders(ref);
      if (mounted) {
        navigator.pop(savedId);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${widget.type.singular} ${_editing ? 'updated' : 'created'}',
            ),
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not ${_editing ? 'update' : 'create'} ${widget.type.singular}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class MaterialSetupSheet extends ConsumerWidget {
  const MaterialSetupSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(materialSetupStatusProvider);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final canManage = permissions.canManageMaterials;
    final types = MaterialMasterType.values;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            canManage ? 'Material Setup' : 'Material Master Data',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            canManage
                ? 'Create, update, and delete master data from one place.'
                : 'Read-only access. Contact an admin for changes.',
            style: const TextStyle(color: InfraColors.textSecondary),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: status.completedSteps / 6,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: InfraColors.border,
            color: status.isComplete
                ? InfraColors.green
                : InfraColors.royalBlue,
          ),
          const SizedBox(height: 8),
          Text(
            '${status.completedSteps} of 6 setup steps complete',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          for (final type in types)
            _SetupTile(
              type: type,
              count: _countFor(type, status),
              canManage: canManage,
              onTap: () async {
                await showMaterialManageSheet(context, type);
                ref.invalidate(materialSetupStatusProvider);
              },
            ),
        ],
      ),
    );
  }

  int _countFor(MaterialMasterType type, MaterialSetupStatus status) =>
      switch (type) {
        MaterialMasterType.tender => status.tenders,
        MaterialMasterType.district => status.districts,
        MaterialMasterType.warehouse => status.warehouses,
        MaterialMasterType.manager => status.managers,
        MaterialMasterType.school => status.schools,
        MaterialMasterType.material => status.materials,
      };
}

class MaterialManageSheet extends ConsumerWidget {
  const MaterialManageSheet({super.key, required this.type});

  final MaterialMasterType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final canManage = permissions.canManageMaterials;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBadge(type: type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.manageTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        canManage
                            ? 'Admin access: create, update, delete'
                            : 'Read-only access',
                        style: const TextStyle(
                          color: InfraColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (canManage)
              FilledButton.icon(
                onPressed: () async {
                  await showMaterialMasterSheet(context, type);
                  invalidateMaterialProviders(ref);
                },
                icon: const Icon(Icons.add),
                label: Text(type.addTitle),
              ),
            if (canManage) const SizedBox(height: 16),
            Expanded(child: _recordsList(context, ref, canManage)),
          ],
        ),
      ),
    );
  }

  Widget _recordsList(BuildContext context, WidgetRef ref, bool canManage) {
    final value = switch (type) {
      MaterialMasterType.tender =>
        ref.watch(tendersProvider).whenData((rows) => rows.cast<Object>()),
      MaterialMasterType.district =>
        ref.watch(districtsProvider).whenData((rows) => rows.cast<Object>()),
      MaterialMasterType.warehouse =>
        ref
            .watch(allWarehousesProvider)
            .whenData((rows) => rows.cast<Object>()),
      MaterialMasterType.manager =>
        ref.watch(siteManagersProvider).whenData((rows) => rows.cast<Object>()),
      MaterialMasterType.school =>
        ref.watch(allSchoolsProvider).whenData((rows) => rows.cast<Object>()),
      MaterialMasterType.material =>
        ref
            .watch(materialItemsProvider)
            .whenData((rows) => rows.cast<Object>()),
    };

    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load ${type.plural}: $error',
          style: const TextStyle(color: InfraColors.red),
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Text(
              canManage
                  ? 'No ${type.plural.toLowerCase()} yet. Tap Add to create one.'
                  : 'No ${type.plural.toLowerCase()} configured yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: InfraColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          itemCount: records.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _MasterRecordTile(
            type: type,
            record: records[index],
            canManage: canManage,
          ),
        );
      },
    );
  }
}

class _MasterRecordTile extends ConsumerWidget {
  const _MasterRecordTile({
    required this.type,
    required this.record,
    required this.canManage,
  });

  final MaterialMasterType type;
  final Object record;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: _IconBadge(type: type, compact: true),
        title: Text(
          _titleFor(record),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(_subtitleFor(record)),
        trailing: canManage
            ? Wrap(
                spacing: 2,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () async {
                      await showMaterialMasterSheet(
                        context,
                        type,
                        initial: record,
                      );
                      invalidateMaterialProviders(ref);
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: InfraColors.red,
                    ),
                  ),
                ],
              )
            : const Chip(label: Text('Read only')),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${type.singular}?'),
        content: Text(
          'This will remove "${_titleFor(record)}" from active material setup and hide related stock/history from dashboards. Audit logs remain for traceability.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: InfraColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      final repository = ref.read(materialRepositoryProvider);
      switch (type) {
        case MaterialMasterType.tender:
          await repository.deleteTender(
            organizationId: org.id,
            tenderId: _idFor(record),
          );
        case MaterialMasterType.district:
          await repository.deleteDistrict(
            organizationId: org.id,
            districtId: _idFor(record),
          );
        case MaterialMasterType.warehouse:
          await repository.deleteWarehouse(
            organizationId: org.id,
            warehouseId: _idFor(record),
          );
        case MaterialMasterType.manager:
          await repository.deleteManager(
            organizationId: org.id,
            managerId: _idFor(record),
          );
        case MaterialMasterType.school:
          await repository.deleteSchool(
            organizationId: org.id,
            schoolId: _idFor(record),
          );
        case MaterialMasterType.material:
          await repository.deleteMaterialItem(
            organizationId: org.id,
            materialId: _idFor(record),
          );
      }
      invalidateMaterialProviders(ref);
      messenger.showSnackBar(
        SnackBar(content: Text('${type.singular} deleted')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete ${type.singular}: $error')),
      );
    }
  }
}

class _FormTitle extends StatelessWidget {
  const _FormTitle({required this.type, required this.editing});

  final MaterialMasterType type;
  final bool editing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _IconBadge(type: type),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          editing ? type.editTitle : type.addTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.type, this.compact = false});

  final MaterialMasterType type;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    width: compact ? 40 : 48,
    height: compact ? 40 : 48,
    decoration: BoxDecoration(
      color: type.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(compact ? 12 : 14),
    ),
    child: Icon(type.icon, color: type.color, size: compact ? 21 : 24),
  );
}

class _DependencyWarning extends StatelessWidget {
  const _DependencyWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: InfraColors.orange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: InfraColors.orange.withValues(alpha: 0.25)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: InfraColors.orange),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.type,
    required this.count,
    required this.canManage,
    required this.onTap,
  });

  final MaterialMasterType type;
  final int count;
  final bool canManage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      leading: _IconBadge(type: type, compact: true),
      title: Text(
        type.singular,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(count == 0 ? 'Not configured' : '$count created'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            count > 0 ? Icons.check_circle : Icons.add_circle_outline,
            color: count > 0 ? InfraColors.green : InfraColors.royalBlue,
          ),
          const SizedBox(width: 4),
          Icon(canManage ? Icons.chevron_right : Icons.visibility_outlined),
        ],
      ),
    ),
  );
}

Future<String?> showMaterialMasterSheet(
  BuildContext context,
  MaterialMasterType type, {
  Object? initial,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: MaterialMasterForm(type: type, initial: initial),
    ),
  );
}

Future<void> showMaterialManageSheet(
  BuildContext context,
  MaterialMasterType type,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: MaterialManageSheet(type: type),
    ),
  );
}

Future<void> showMaterialSetupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const FractionallySizedBox(
      heightFactor: 0.92,
      child: MaterialSetupSheet(),
    ),
  );
}

String _idFor(Object record) {
  if (record is Tender) return record.id;
  if (record is District) return record.id;
  if (record is Warehouse) return record.id;
  if (record is SiteManager) return record.id;
  if (record is School) return record.id;
  if (record is MaterialItem) return record.id;
  throw ArgumentError('Unsupported material record type: $record');
}

String _titleFor(Object record) {
  if (record is Tender) {
    return record.year == null
        ? record.name
        : '${record.name} - ${record.year}';
  }
  if (record is District) return record.name;
  if (record is Warehouse) return record.name;
  if (record is SiteManager) return record.fullName;
  if (record is School) return record.name;
  if (record is MaterialItem) return record.name;
  return record.toString();
}

String _subtitleFor(Object record) {
  if (record is Tender) return 'Status: ${_statusLabel(record.status)}';
  if (record is District) return record.state ?? 'District';
  if (record is Warehouse) {
    final central = record.isCentral ? 'Central warehouse' : 'Warehouse';
    return record.address?.isNotEmpty == true ? record.address! : central;
  }
  if (record is SiteManager) {
    return '${record.roleLabel}${record.active ? '' : ' • inactive'}';
  }
  if (record is School) {
    return '${_statusLabel(record.status)} • ${record.progressPercent}% progress';
  }
  if (record is MaterialItem) {
    return '${record.unit} • Low stock ${formatQuantity(record.lowStockThreshold)}';
  }
  return '';
}

String _statusLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
