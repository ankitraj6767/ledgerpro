import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/infra_repository.dart';
import '../../../shared/models/infra_models.dart';
import '../../../shared/widgets/access_denied_screen.dart';

// ---------------------------------------------------------------------------
// Add / edit project
// ---------------------------------------------------------------------------
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.project});

  final InfraProject? project;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _category;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _address;
  late final TextEditingController _estimatedCost;
  late final TextEditingController _description;
  DateTime? _startDate;
  DateTime? _endDate;
  InfraProjectStatus _status = InfraProjectStatus.planning;
  bool _saving = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _name = TextEditingController(text: p?.name ?? '');
    _code = TextEditingController(text: p?.code ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _city = TextEditingController(text: p?.locationCity ?? '');
    _state = TextEditingController(text: p?.locationState ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _estimatedCost = TextEditingController(
      text: (p == null || p.totalEstimatedCostPaise == 0)
          ? ''
          : (p.totalEstimatedCostPaise / 100).toStringAsFixed(2),
    );
    _description = TextEditingController(text: p?.description ?? '');
    _startDate = p?.startDate;
    _endDate = p?.expectedEndDate;
    _status = p?.status ?? InfraProjectStatus.planning;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _code,
      _category,
      _city,
      _state,
      _address,
      _estimatedCost,
      _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canManageProjects) {
      return const AccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Project' : 'Add Project')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _text(_name, 'Project name', Icons.business_outlined),
          const SizedBox(height: 12),
          _text(_code, 'Project code (optional)', Icons.tag_outlined),
          const SizedBox(height: 12),
          _text(_category, 'Category', Icons.category_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _text(_city, 'City', Icons.location_city_outlined),
              ),
              const SizedBox(width: 8),
              Expanded(child: _text(_state, 'State', Icons.map_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          _text(_address, 'Address', Icons.place_outlined, maxLines: 2),
          const SizedBox(height: 12),
          _text(
            _estimatedCost,
            'Estimated cost (₹)',
            Icons.currency_rupee,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _dateField(
            'Start date',
            _startDate,
            (d) => setState(() => _startDate = d),
          ),
          const SizedBox(height: 12),
          _dateField(
            'Expected end date',
            _endDate,
            (d) => setState(() => _endDate = d),
          ),
          const SizedBox(height: 12),
          if (_isEditing) ...[
            DropdownButtonFormField<InfraProjectStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: InfraProjectStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_statusLabel(s)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
          ],
          _text(_description, 'Description', Icons.notes_outlined, maxLines: 3),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isEditing ? 'Update Project' : 'Create Project'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Project name is required.')),
      );
      return;
    }
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Expected end date cannot be before start date.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(infraRepositoryProvider);
      final cost = _estimatedCost.text.trim().isEmpty
          ? 0
          : InfraRepository.parsePaise(_estimatedCost.text);
      if (_isEditing) {
        await repo.updateProject(
          projectId: widget.project!.id,
          name: _name.text.trim(),
          code: _code.text.trim(),
          category: _category.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          address: _address.text.trim(),
          status: _status,
          startDate: _startDate,
          expectedEndDate: _endDate,
          estimatedCostPaise: cost,
          description: _description.text.trim(),
        );
      } else {
        final org = await ref.read(infraWorkspaceProvider.future);
        await repo.createProject(
          organizationId: org.id,
          name: _name.text.trim(),
          code: _code.text.trim().isEmpty ? null : _code.text.trim(),
          category: _category.text.trim().isEmpty
              ? null
              : _category.text.trim(),
          city: _city.text.trim().isEmpty ? null : _city.text.trim(),
          state: _state.text.trim().isEmpty ? null : _state.text.trim(),
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
          startDate: _startDate,
          expectedEndDate: _endDate,
          estimatedCostPaise: cost,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
        );
      }
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Project updated.' : 'Project created.'),
        ),
      );
      if (mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save project: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _statusLabel(InfraProjectStatus s) => switch (s) {
    InfraProjectStatus.planning => 'Planning',
    InfraProjectStatus.active => 'Active',
    InfraProjectStatus.onHold => 'On Hold',
    InfraProjectStatus.completed => 'Completed',
    InfraProjectStatus.cancelled => 'Cancelled',
  };
}

// ---------------------------------------------------------------------------
// Add expense
// ---------------------------------------------------------------------------
class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, required this.project, this.expense});

  final InfraProject project;
  final ProjectExpense? expense;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _amount = TextEditingController();
  final _vendor = TextEditingController();
  final _billNumber = TextEditingController();
  final _notes = TextEditingController();
  String _category = ExpenseCategories.values.first;
  String _paymentMode = 'cash';
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    if (e != null) {
      _amount.text = (e.amountPaise / 100).toStringAsFixed(2);
      _vendor.text = e.vendorName ?? '';
      _billNumber.text = e.billNumber ?? '';
      _notes.text = e.notes ?? '';
      if (ExpenseCategories.values.contains(e.category)) {
        _category = e.category;
      }
      _paymentMode = e.paymentMode;
      _date = e.expenseDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _vendor.dispose();
    _billNumber.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final allowed = _isEditing
        ? permissions.canEditExpense(widget.expense!)
        : permissions.canAddExpense;
    if (!allowed) {
      return const AccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Add Expense')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: ExpenseCategories.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          _amountField(_amount, 'Amount (₹)'),
          const SizedBox(height: 12),
          _plainField(_vendor, 'Vendor name', Icons.store_outlined),
          const SizedBox(height: 12),
          _paymentModeField(
            _paymentMode,
            (m) => setState(() => _paymentMode = m),
          ),
          const SizedBox(height: 12),
          _plainField(_billNumber, 'Bill number', Icons.numbers_outlined),
          const SizedBox(height: 12),
          _dateRow('Expense date', _date, (d) => setState(() => _date = d)),
          const SizedBox(height: 12),
          _plainField(_notes, 'Notes', Icons.notes_outlined, maxLines: 3),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isEditing ? 'Update Expense' : 'Save Expense'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    int amount;
    try {
      amount = InfraRepository.parsePaise(_amount.text);
      if (amount <= 0) throw const FormatException('Amount required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid amount greater than 0.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(infraRepositoryProvider);
      final vendor = _vendor.text.trim().isEmpty ? null : _vendor.text.trim();
      final bill = _billNumber.text.trim().isEmpty
          ? null
          : _billNumber.text.trim();
      final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      if (_isEditing) {
        await repo.updateExpense(
          expenseId: widget.expense!.id,
          category: _category,
          amountPaise: amount,
          vendorName: vendor,
          date: _date,
          paymentMode: _paymentMode,
          billNumber: bill,
          notes: notes,
        );
      } else {
        await repo.addExpense(
          projectId: widget.project.id,
          category: _category,
          amountPaise: amount,
          vendorName: vendor,
          date: _date,
          paymentMode: _paymentMode,
          billNumber: bill,
          notes: notes,
        );
      }
      ref.invalidate(projectExpensesProvider(widget.project.id));
      ref.invalidate(projectFinancialSummaryProvider(widget.project.id));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Expense updated.' : 'Expense saved.'),
        ),
      );
      if (mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save expense: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Add government fund
// ---------------------------------------------------------------------------
class GovtFundFormScreen extends ConsumerStatefulWidget {
  const GovtFundFormScreen({super.key, required this.project, this.fund});

  final InfraProject project;
  final GovernmentFund? fund;

  @override
  ConsumerState<GovtFundFormScreen> createState() => _GovtFundFormScreenState();
}

class _GovtFundFormScreenState extends ConsumerState<GovtFundFormScreen> {
  final _department = TextEditingController();
  final _scheme = TextEditingController();
  final _orderNumber = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.fund != null;

  @override
  void initState() {
    super.initState();
    final f = widget.fund;
    if (f != null) {
      _department.text = f.departmentName;
      _scheme.text = f.schemeName ?? '';
      _orderNumber.text = f.sanctionOrderNumber ?? '';
      _amount.text = (f.amountSanctionedPaise / 100).toStringAsFixed(2);
      _notes.text = f.notes ?? '';
      _date = f.sanctionDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _department.dispose();
    _scheme.dispose();
    _orderNumber.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canManageFunds) {
      return const AccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Sanctioned Fund' : 'Add Sanctioned Fund',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _plainField(
            _department,
            'Department name',
            Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          _plainField(_scheme, 'Scheme name', Icons.assignment_outlined),
          const SizedBox(height: 12),
          _plainField(
            _orderNumber,
            'Sanction order number',
            Icons.tag_outlined,
          ),
          const SizedBox(height: 12),
          _amountField(_amount, 'Sanction amount (₹)'),
          const SizedBox(height: 12),
          _dateRow('Sanction date', _date, (d) => setState(() => _date = d)),
          const SizedBox(height: 12),
          _plainField(_notes, 'Notes', Icons.notes_outlined, maxLines: 3),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isEditing ? 'Update Fund' : 'Save Fund'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_department.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Department name is required.')),
      );
      return;
    }
    int amount;
    try {
      amount = InfraRepository.parsePaise(_amount.text);
      if (amount <= 0) throw const FormatException('Amount required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid sanction amount.')),
      );
      return;
    }
    if (_isEditing && amount < widget.fund!.amountReceivedPaise) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Sanctioned amount cannot be less than the amount already received.',
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(infraRepositoryProvider);
      final scheme = _scheme.text.trim().isEmpty ? null : _scheme.text.trim();
      final order = _orderNumber.text.trim().isEmpty
          ? null
          : _orderNumber.text.trim();
      final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      if (_isEditing) {
        await repo.updateGovernmentFund(
          fundId: widget.fund!.id,
          departmentName: _department.text.trim(),
          schemeName: scheme,
          sanctionOrderNumber: order,
          amountSanctionedPaise: amount,
          sanctionDate: _date,
          notes: notes,
        );
      } else {
        await repo.addGovernmentFund(
          projectId: widget.project.id,
          departmentName: _department.text.trim(),
          schemeName: scheme,
          sanctionOrderNumber: order,
          amountSanctionedPaise: amount,
          sanctionDate: _date,
          notes: notes,
        );
      }
      ref.invalidate(governmentFundsProvider(widget.project.id));
      ref.invalidate(projectFinancialSummaryProvider(widget.project.id));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Fund updated.' : 'Fund saved.')),
      );
      if (mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save fund: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Add government receipt (receives a GovernmentFund as extra)
// ---------------------------------------------------------------------------
class GovtReceiptFormScreen extends ConsumerStatefulWidget {
  const GovtReceiptFormScreen({super.key, required this.fund});

  final GovernmentFund fund;

  @override
  ConsumerState<GovtReceiptFormScreen> createState() =>
      _GovtReceiptFormScreenState();
}

class _GovtReceiptFormScreenState extends ConsumerState<GovtReceiptFormScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  String _paymentMode = 'bank';
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canManageFunds) {
      return const AccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Fund Receipt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(widget.fund.departmentName),
              subtitle: Text(
                'Pending: ₹${(widget.fund.pendingAmountPaise / 100).toStringAsFixed(2)}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _amountField(_amount, 'Amount received (₹)'),
          const SizedBox(height: 12),
          _paymentModeField(
            _paymentMode,
            (m) => setState(() => _paymentMode = m),
          ),
          const SizedBox(height: 12),
          _plainField(_reference, 'Reference number', Icons.tag_outlined),
          const SizedBox(height: 12),
          _dateRow('Received date', _date, (d) => setState(() => _date = d)),
          const SizedBox(height: 12),
          _plainField(_notes, 'Notes', Icons.notes_outlined, maxLines: 3),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Save Receipt'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    int amount;
    try {
      amount = InfraRepository.parsePaise(_amount.text);
      if (amount <= 0) throw const FormatException('Amount required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    if (amount > widget.fund.pendingAmountPaise) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Receipt cannot exceed the pending sanctioned amount.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(infraRepositoryProvider)
          .addGovernmentReceipt(
            governmentFundId: widget.fund.id,
            amountPaise: amount,
            receivedDate: _date,
            paymentMode: _paymentMode,
            referenceNumber: _reference.text.trim().isEmpty
                ? null
                : _reference.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      ref.invalidate(governmentFundsProvider(widget.fund.projectId));
      ref.invalidate(projectFinancialSummaryProvider(widget.fund.projectId));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Receipt saved.')));
      if (mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save receipt: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Add investment (project-scoped; picks/creates investor)
// ---------------------------------------------------------------------------
class InvestmentFormScreen extends ConsumerStatefulWidget {
  const InvestmentFormScreen({
    super.key,
    required this.project,
    this.investment,
  });

  final InfraProject project;
  final ProjectInvestment? investment;

  @override
  ConsumerState<InvestmentFormScreen> createState() =>
      _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends ConsumerState<InvestmentFormScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  String? _investorId;
  String _paymentMode = 'bank';
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.investment != null;

  @override
  void initState() {
    super.initState();
    final inv = widget.investment;
    if (inv != null) {
      _amount.text = (inv.amountPaise / 100).toStringAsFixed(2);
      _reference.text = inv.referenceNumber ?? '';
      _notes.text = inv.notes ?? '';
      _investorId = inv.investorId;
      _paymentMode = inv.paymentMode;
      _date = inv.investmentDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    if (roleAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(currentOrgPermissionsProvider).canManageInvestments) {
      return const AccessDeniedScreen();
    }

    final investorsAsync = ref.watch(investorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Investment' : 'Add Investment'),
      ),
      body: investorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load investors: $e')),
        data: (investors) {
          if (investors.isNotEmpty) {
            _investorId ??= investors.first.id;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _investorId,
                      decoration: const InputDecoration(
                        labelText: 'Investor',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: investors
                          .map(
                            (i) => DropdownMenuItem(
                              value: i.id,
                              child: Text(i.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _investorId = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _addInvestor,
                    icon: const Icon(Icons.person_add_alt_1),
                    tooltip: 'New investor',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _amountField(_amount, 'Investment amount (₹)'),
              const SizedBox(height: 12),
              _paymentModeField(
                _paymentMode,
                (m) => setState(() => _paymentMode = m),
              ),
              const SizedBox(height: 12),
              _plainField(_reference, 'Reference number', Icons.tag_outlined),
              const SizedBox(height: 12),
              _dateRow(
                'Investment date',
                _date,
                (d) => setState(() => _date = d),
              ),
              const SizedBox(height: 12),
              _plainField(_notes, 'Notes', Icons.notes_outlined, maxLines: 3),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving || investors.isEmpty ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isEditing ? 'Update Investment' : 'Save Investment',
                ),
              ),
              if (investors.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Add an investor first using the + button above.',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addInvestor() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddInvestorSheet(),
    );
    if (created == true) ref.invalidate(investorsProvider);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final investorId = _investorId;
    if (investorId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select an investor.')),
      );
      return;
    }
    int amount;
    try {
      amount = InfraRepository.parsePaise(_amount.text);
      if (amount <= 0) throw const FormatException('Amount required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid investment amount.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(infraRepositoryProvider);
      final reference = _reference.text.trim().isEmpty
          ? null
          : _reference.text.trim();
      final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      if (_isEditing) {
        await repo.updateInvestment(
          investmentId: widget.investment!.id,
          investorId: investorId,
          amountPaise: amount,
          date: _date,
          paymentMode: _paymentMode,
          referenceNumber: reference,
          notes: notes,
        );
      } else {
        await repo.addInvestment(
          projectId: widget.project.id,
          investorId: investorId,
          amountPaise: amount,
          date: _date,
          paymentMode: _paymentMode,
          referenceNumber: reference,
          notes: notes,
        );
      }
      ref.invalidate(projectInvestmentsProvider(widget.project.id));
      ref.invalidate(projectFinancialSummaryProvider(widget.project.id));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Investment updated.' : 'Investment saved.',
          ),
        ),
      );
      if (mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save investment: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _AddInvestorSheet extends ConsumerStatefulWidget {
  const _AddInvestorSheet();

  @override
  ConsumerState<_AddInvestorSheet> createState() => _AddInvestorSheetState();
}

class _AddInvestorSheetState extends ConsumerState<_AddInvestorSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pan = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'New Investor',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _plainField(_name, 'Name', Icons.person_outline),
          const SizedBox(height: 8),
          _plainField(
            _phone,
            'Phone',
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          _plainField(_email, 'Email', Icons.email_outlined),
          const SizedBox(height: 8),
          _plainField(_pan, 'PAN', Icons.badge_outlined),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Investor'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Investor name is required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      await ref
          .read(infraRepositoryProvider)
          .createInvestor(
            organizationId: org.id,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            pan: _pan.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save investor: $error')),
      );
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Shared field helpers
// ---------------------------------------------------------------------------
Widget _text(
  TextEditingController c,
  String label,
  IconData icon, {
  TextInputType? keyboard,
  int maxLines = 1,
}) {
  return TextField(
    controller: c,
    keyboardType: keyboard,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}

Widget _plainField(
  TextEditingController c,
  String label,
  IconData icon, {
  TextInputType? keyboard,
  int maxLines = 1,
}) => _text(c, label, icon, keyboard: keyboard, maxLines: maxLines);

Widget _amountField(TextEditingController c, String label) => TextField(
  controller: c,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: const Icon(Icons.currency_rupee),
  ),
);

Widget _paymentModeField(String value, ValueChanged<String> onChanged) {
  const modes = ['cash', 'bank', 'upi', 'cheque', 'card', 'other'];
  return DropdownButtonFormField<String>(
    initialValue: value,
    decoration: const InputDecoration(
      labelText: 'Payment mode',
      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
    ),
    items: modes
        .map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase())))
        .toList(),
    onChanged: (v) => onChanged(v ?? value),
  );
}

Widget _dateField(
  String label,
  DateTime? value,
  ValueChanged<DateTime> onChanged,
) {
  return Builder(
    builder: (context) => InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
        ),
      ),
    ),
  );
}

Widget _dateRow(
  String label,
  DateTime value,
  ValueChanged<DateTime> onChanged,
) => _dateField(label, value, onChanged);
