import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../shared/models/infra_models.dart';
import '../../../shared/models/material_models.dart';
import 'material_master_form.dart';

enum MaterialFormOperation { receive, issue, materialReturn, requirement, item }

extension MaterialFormOperationLabel on MaterialFormOperation {
  String get title => switch (this) {
    MaterialFormOperation.receive => 'Receive Material',
    MaterialFormOperation.issue => 'Issue Material',
    MaterialFormOperation.materialReturn => 'Return Material',
    MaterialFormOperation.requirement => 'Add Requirement',
    MaterialFormOperation.item => 'Add Material Item',
  };

  IconData get icon => switch (this) {
    MaterialFormOperation.receive => Icons.move_to_inbox_outlined,
    MaterialFormOperation.issue => Icons.outbox_outlined,
    MaterialFormOperation.materialReturn => Icons.assignment_return_outlined,
    MaterialFormOperation.requirement => Icons.playlist_add_outlined,
    MaterialFormOperation.item => Icons.add_box_outlined,
  };
}

class MaterialOperationForm extends ConsumerStatefulWidget {
  const MaterialOperationForm({super.key, required this.operation});

  final MaterialFormOperation operation;

  @override
  ConsumerState<MaterialOperationForm> createState() =>
      _MaterialOperationFormState();
}

class _MaterialOperationFormState extends ConsumerState<MaterialOperationForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _supplier = TextEditingController();
  final _invoice = TextEditingController();
  final _reason = TextEditingController();
  final _notes = TextEditingController();
  final _itemName = TextEditingController();
  final _itemUnit = TextEditingController();
  final _itemSku = TextEditingController();
  final _itemCategory = TextEditingController();
  final _threshold = TextEditingController(text: '0');

  String? _tenderId;
  String? _warehouseId;
  String? _schoolId;
  String? _managerId;
  String? _materialId;
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _quantity.dispose();
    _supplier.dispose();
    _invoice.dispose();
    _reason.dispose();
    _notes.dispose();
    _itemName.dispose();
    _itemUnit.dispose();
    _itemSku.dispose();
    _itemCategory.dispose();
    _threshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenders = ref.watch(tendersProvider).value ?? const <Tender>[];
    final warehouses =
        ref.watch(warehousesProvider).value ?? const <Warehouse>[];
    final schools = ref.watch(schoolsProvider).value ?? const <School>[];
    final managers =
        ref.watch(siteManagersProvider).value ?? const <SiteManager>[];
    final materials =
        ref.watch(materialItemsProvider).value ?? const <MaterialItem>[];
    final stock =
        ref.watch(warehouseStockSummaryProvider).value ??
        const <WarehouseStockRow>[];
    final effectiveTender =
        _tenderId ??
        ref.watch(effectiveTenderIdProvider) ??
        tenders.firstOrNull?.id;
    final effectiveWarehouse =
        _warehouseId ??
        ref.watch(effectiveWarehouseIdProvider) ??
        warehouses.firstOrNull?.id;
    final selectedStock = stock
        .where((row) => row.materialId == _materialId)
        .firstOrNull;
    final setupStatus = ref.watch(materialSetupStatusProvider);
    final setupReady = _isSetupReady(setupStatus);
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final operationAllowed = _isOperationAllowed(permissions);

    if (!operationAllowed) {
      return SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            _OperationTitle(operation: widget.operation),
            const SizedBox(height: 20),
            const _OperationPermissionWarning(),
          ],
        ),
      );
    }

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            _OperationTitle(operation: widget.operation),
            const SizedBox(height: 20),
            if (!setupReady) ...[
              _OperationSetupWarning(
                message: _setupMessage(setupStatus),
                onPressed: () => showMaterialSetupSheet(context),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.operation == MaterialFormOperation.item)
              ..._itemFields()
            else ...[
              _dropdown<Tender>(
                label: 'Tender',
                value: effectiveTender,
                items: tenders,
                id: (item) => item.id,
                title: (item) => item.year == null
                    ? item.name
                    : '${item.name} - ${item.year}',
                onChanged: (value) => setState(() {
                  _tenderId = value;
                  _schoolId = null;
                  ref.read(selectedTenderProvider.notifier).select(value);
                }),
              ),
              if (widget.operation != MaterialFormOperation.requirement)
                _dropdown<Warehouse>(
                  label: 'Warehouse',
                  value: effectiveWarehouse,
                  items: warehouses,
                  id: (item) => item.id,
                  title: (item) => item.name,
                  onChanged: (value) => setState(() {
                    _warehouseId = value;
                    ref.read(selectedWarehouseProvider.notifier).select(value);
                  }),
                ),
              if (widget.operation == MaterialFormOperation.issue ||
                  widget.operation == MaterialFormOperation.materialReturn ||
                  widget.operation == MaterialFormOperation.requirement)
                _dropdown<School>(
                  label: 'School',
                  value: _schoolId,
                  items: schools,
                  id: (item) => item.id,
                  title: (item) => item.name,
                  onChanged: (value) => setState(() => _schoolId = value),
                ),
              if (widget.operation == MaterialFormOperation.issue ||
                  widget.operation == MaterialFormOperation.materialReturn)
                _dropdown<SiteManager>(
                  label: 'Manager',
                  value: _managerId,
                  items: managers,
                  id: (item) => item.id,
                  title: (item) => item.fullName,
                  onChanged: (value) => setState(() => _managerId = value),
                ),
              _dropdown<MaterialItem>(
                label: 'Material',
                value: _materialId,
                items: materials,
                id: (item) => item.id,
                title: (item) => '${item.name} (${item.unit})',
                onChanged: (value) => setState(() => _materialId = value),
              ),
              if (widget.operation == MaterialFormOperation.issue)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Available stock: ${formatQuantity(selectedStock?.remainingStock ?? 0)} ${selectedStock?.unit ?? ''}',
                    style: TextStyle(
                      color: (selectedStock?.remainingStock ?? 0) > 0
                          ? InfraColors.green
                          : InfraColors.red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText:
                      widget.operation == MaterialFormOperation.requirement
                      ? 'Required quantity'
                      : 'Quantity',
                  prefixIcon: const Icon(Icons.numbers),
                ),
                validator: (value) =>
                    widget.operation == MaterialFormOperation.issue
                    ? validateIssueQuantity(
                        value,
                        selectedStock?.remainingStock ?? 0,
                      )
                    : validatePositiveQuantity(value),
              ),
              const SizedBox(height: 12),
              if (widget.operation == MaterialFormOperation.receive) ...[
                TextFormField(
                  controller: _supplier,
                  decoration: const InputDecoration(
                    labelText: 'Supplier',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _invoice,
                  decoration: const InputDecoration(
                    labelText: 'Invoice number',
                    prefixIcon: Icon(Icons.receipt_outlined),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (widget.operation == MaterialFormOperation.materialReturn) ...[
                TextFormField(
                  controller: _reason,
                  decoration: const InputDecoration(
                    labelText: 'Return reason',
                    prefixIcon: Icon(Icons.help_outline),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (widget.operation != MaterialFormOperation.requirement) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date'),
                  subtitle: Text(_date.toIso8601String().split('T').first),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
            FilledButton.icon(
              onPressed: _submitting || !setupReady
                  ? null
                  : () => _submit(
                      tenderId: effectiveTender,
                      warehouseId: effectiveWarehouse,
                    ),
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(widget.operation.icon),
              label: Text(_submitting ? 'Saving...' : widget.operation.title),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _itemFields() => [
    TextFormField(
      controller: _itemName,
      decoration: const InputDecoration(
        labelText: 'Material name',
        prefixIcon: Icon(Icons.inventory_2_outlined),
      ),
      validator: _required,
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: _itemUnit,
      decoration: const InputDecoration(
        labelText: 'Unit',
        hintText: 'Nos., Meter, Roll',
        prefixIcon: Icon(Icons.straighten_outlined),
      ),
      validator: _required,
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: _itemSku,
      decoration: const InputDecoration(labelText: 'SKU'),
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: _itemCategory,
      decoration: const InputDecoration(labelText: 'Category'),
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: _threshold,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(labelText: 'Low stock threshold'),
      validator: (value) {
        final parsed = double.tryParse(value?.trim() ?? '');
        return parsed == null || parsed < 0 ? 'Enter zero or more' : null;
      },
    ),
    const SizedBox(height: 16),
  ];

  bool _isSetupReady(MaterialSetupStatus status) => switch (widget.operation) {
    MaterialFormOperation.receive => status.isReadyForReceive,
    MaterialFormOperation.issue ||
    MaterialFormOperation.materialReturn => status.isReadyForIssue,
    MaterialFormOperation.requirement =>
      status.tenders > 0 && status.schools > 0 && status.materials > 0,
    MaterialFormOperation.item => true,
  };

  bool _isOperationAllowed(OrgPermissions permissions) =>
      switch (widget.operation) {
        MaterialFormOperation.receive ||
        MaterialFormOperation.issue ||
        MaterialFormOperation.materialReturn => permissions.canOperateMaterials,
        MaterialFormOperation.requirement ||
        MaterialFormOperation.item => permissions.canManageMaterials,
      };

  String _setupMessage(MaterialSetupStatus status) {
    final missing = <String>[
      if (status.tenders == 0) 'tender',
      if (widget.operation != MaterialFormOperation.requirement &&
          status.warehouses == 0)
        'warehouse',
      if ((widget.operation == MaterialFormOperation.issue ||
              widget.operation == MaterialFormOperation.materialReturn ||
              widget.operation == MaterialFormOperation.requirement) &&
          status.schools == 0)
        'school',
      if ((widget.operation == MaterialFormOperation.issue ||
              widget.operation == MaterialFormOperation.materialReturn) &&
          status.managers == 0)
        'manager',
      if (status.materials == 0) 'material',
    ];
    return 'Create ${missing.join(', ')} before you can ${widget.operation.title.toLowerCase()}.';
  }

  Widget _dropdown<T>({
    required String label,
    required String? value,
    required List<T> items,
    required String Function(T item) id,
    required String Function(T item) title,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.any((item) => id(item) == value) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: validValue,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: id(item),
                child: Text(title(item), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (selected) => selected == null ? 'Select $label' : null,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit({
    required String? tenderId,
    required String? warehouseId,
  }) async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _submitting = true);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      final repository = ref.read(materialRepositoryProvider);
      final quantity = double.tryParse(_quantity.text.trim()) ?? 0;
      switch (widget.operation) {
        case MaterialFormOperation.receive:
          await repository.receiveMaterial(
            organizationId: org.id,
            tenderId: tenderId!,
            warehouseId: warehouseId!,
            materialId: _materialId!,
            quantity: quantity,
            supplierName: _supplier.text,
            invoiceNumber: _invoice.text,
            receivedDate: _date,
            notes: _notes.text,
          );
        case MaterialFormOperation.issue:
          await repository.issueMaterialToSchool(
            organizationId: org.id,
            tenderId: tenderId!,
            warehouseId: warehouseId!,
            schoolId: _schoolId!,
            managerId: _managerId!,
            materialId: _materialId!,
            quantity: quantity,
            issueDate: _date,
            notes: _notes.text,
          );
        case MaterialFormOperation.materialReturn:
          await repository.returnMaterialFromSchool(
            organizationId: org.id,
            tenderId: tenderId!,
            warehouseId: warehouseId!,
            schoolId: _schoolId!,
            managerId: _managerId!,
            materialId: _materialId!,
            quantity: quantity,
            returnDate: _date,
            reason: _reason.text,
            notes: _notes.text,
          );
        case MaterialFormOperation.requirement:
          await repository.upsertSchoolRequirement(
            organizationId: org.id,
            tenderId: tenderId!,
            schoolId: _schoolId!,
            materialId: _materialId!,
            requiredQuantity: quantity,
          );
        case MaterialFormOperation.item:
          await repository.addMaterialItem(
            organizationId: org.id,
            name: _itemName.text,
            unit: _itemUnit.text,
            sku: _itemSku.text,
            category: _itemCategory.text,
            lowStockThreshold: double.parse(_threshold.text),
          );
      }
      invalidateMaterialProviders(ref);
      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text('${widget.operation.title} saved')),
        );
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _OperationTitle extends StatelessWidget {
  const _OperationTitle({required this.operation});

  final MaterialFormOperation operation;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: InfraColors.royalBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(operation.icon, color: InfraColors.royalBlue),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          operation.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}

class _OperationPermissionWarning extends StatelessWidget {
  const _OperationPermissionWarning();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF2FF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: InfraColors.royalBlue.withValues(alpha: 0.22)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.visibility_outlined, color: InfraColors.royalBlue),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'You have read-only material access. You can view tenders, schools, warehouse stock, and reports, but only admins can create, update, or delete material records.',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _OperationSetupWarning extends StatelessWidget {
  const _OperationSetupWarning({
    required this.message,
    required this.onPressed,
  });

  final String message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: InfraColors.orange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: InfraColors.orange.withValues(alpha: 0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: InfraColors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Complete material setup'),
        ),
      ],
    ),
  );
}

Future<void> showMaterialOperationSheet(
  BuildContext context,
  MaterialFormOperation operation,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.9,
      child: MaterialOperationForm(operation: operation),
    ),
  );
}
