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
  String get title => switch (this) {
    MaterialMasterType.tender => 'Add Tender',
    MaterialMasterType.district => 'Add District',
    MaterialMasterType.warehouse => 'Add Warehouse',
    MaterialMasterType.manager => 'Add Manager',
    MaterialMasterType.school => 'Add School',
    MaterialMasterType.material => 'Add Material Item',
  };

  String get singular => switch (this) {
    MaterialMasterType.tender => 'Tender',
    MaterialMasterType.district => 'District',
    MaterialMasterType.warehouse => 'Warehouse',
    MaterialMasterType.manager => 'Manager',
    MaterialMasterType.school => 'School',
    MaterialMasterType.material => 'Material',
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
  const MaterialMasterForm({super.key, required this.type});

  final MaterialMasterType type;

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
  final _unit = TextEditingController();
  final _sku = TextEditingController();
  final _category = TextEditingController();
  final _threshold = TextEditingController(text: '0');

  String? _tenderId;
  String? _districtId;
  String? _managerId;
  bool _isCentral = false;
  bool _submitting = false;

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
    _unit.dispose();
    _sku.dispose();
    _category.dispose();
    _threshold.dispose();
    super.dispose();
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
            _FormTitle(type: widget.type),
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
              label: Text(_submitting ? 'Saving...' : widget.type.title),
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
      String? createdId;
      switch (widget.type) {
        case MaterialMasterType.tender:
          createdId = await repository.createTender(
            organizationId: org.id,
            name: _name.text,
            code: _code.text,
            year: int.tryParse(_year.text),
            description: _description.text,
          );
          ref.read(selectedTenderProvider.notifier).select(createdId);
        case MaterialMasterType.district:
          createdId = await repository.createDistrict(
            organizationId: org.id,
            name: _name.text,
            state: _state.text,
          );
          ref.read(selectedDistrictProvider.notifier).select(createdId);
        case MaterialMasterType.manager:
          createdId = await repository.createManager(
            organizationId: org.id,
            fullName: _name.text,
            phone: _phone.text,
            email: _email.text,
          );
        case MaterialMasterType.warehouse:
          createdId = await repository.createWarehouse(
            organizationId: org.id,
            name: _name.text,
            districtId: _districtId,
            address: _address.text,
            managerName: _managerName.text,
            phone: _phone.text,
            isCentral: _isCentral,
          );
          ref.read(selectedWarehouseProvider.notifier).select(createdId);
        case MaterialMasterType.school:
          createdId = await repository.createSchool(
            organizationId: org.id,
            tenderId: _tenderId!,
            districtId: _districtId!,
            name: _name.text,
            code: _code.text,
            address: _address.text,
            assignedManagerId: _managerId,
          );
        case MaterialMasterType.material:
          await repository.addMaterialItem(
            organizationId: org.id,
            name: _name.text,
            unit: _unit.text,
            sku: _sku.text,
            category: _category.text,
            lowStockThreshold: double.parse(_threshold.text),
          );
      }
      invalidateMaterialProviders(ref);
      if (mounted) {
        navigator.pop(createdId);
        messenger.showSnackBar(
          SnackBar(content: Text('${widget.type.singular} created')),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not create ${widget.type.singular}: $error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _FormTitle extends StatelessWidget {
  const _FormTitle({required this.type});

  final MaterialMasterType type;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(type.icon, color: type.color),
      ),
      const SizedBox(width: 12),
      Text(
        type.title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
    ],
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

Future<String?> showMaterialMasterSheet(
  BuildContext context,
  MaterialMasterType type,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: MaterialMasterForm(type: type),
    ),
  );
}

class MaterialSetupSheet extends ConsumerWidget {
  const MaterialSetupSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(materialSetupStatusProvider);
    final types = MaterialMasterType.values;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Material Setup',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create the master data once, then receive and issue stock normally.',
            style: TextStyle(color: InfraColors.textSecondary),
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
              onTap: () async {
                await showMaterialMasterSheet(context, type);
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

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.type,
    required this.count,
    required this.onTap,
  });

  final MaterialMasterType type;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(type.icon, color: type.color),
      ),
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
          const Icon(Icons.chevron_right),
        ],
      ),
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
