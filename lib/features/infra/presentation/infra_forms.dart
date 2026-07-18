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
  final _category = TextEditingController();
  final _categoryFocus = FocusNode();
  final _amount = TextEditingController();
  final _vendor = TextEditingController();
  final _billNumber = TextEditingController();
  final _notes = TextEditingController();
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
      _category.text = e.category;
      _paymentMode = e.paymentMode;
      _date = e.expenseDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _category.dispose();
    _categoryFocus.dispose();
    _amount.dispose();
    _vendor.dispose();
    _billNumber.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentOrgRoleProvider);
    final existingExpenses = ref.watch(
      projectExpensesProvider(widget.project.id),
    );
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

    final categorySuggestions = ExpenseCategories.suggestions(
      existingExpenses.value?.map((expense) => expense.category) ??
          const <String>[],
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Add Expense')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _categoryAutocomplete(categorySuggestions),
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

  Widget _categoryAutocomplete(List<String> suggestions) {
    return RawAutocomplete<String>(
      textEditingController: _category,
      focusNode: _categoryFocus,
      optionsBuilder: (value) =>
          ExpenseCategories.matching(suggestions, value.text),
      onSelected: (category) {
        _category.value = TextEditingValue(
          text: category,
          selection: TextSelection.collapsed(offset: category.length),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (_) => onSubmitted(),
            decoration: const InputDecoration(
              labelText: 'Category / use case',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
      optionsViewBuilder: (context, onSelected, options) {
        final availableWidth = MediaQuery.sizeOf(context).width - 32;
        final width = availableWidth < 600 ? availableWidth : 600.0;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: width,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final category = options.elementAt(index);
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(category),
                      onTap: () => onSelected(category),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
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
    final category = _category.text.trim();
    if (category.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a category or use case.')),
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
          category: category,
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
          category: category,
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
  const GovtReceiptFormScreen({super.key, required this.fund, this.receipt});

  final GovernmentFund fund;

  /// When non-null the form edits this existing receipt instead of adding a
  /// new one.
  final GovernmentFundReceipt? receipt;

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

  bool get _isEditing => widget.receipt != null;

  /// Highest receipt amount the fund can still absorb. When editing, the
  /// receipt's own current amount is already counted in the fund's received
  /// total, so it becomes available again for this edit.
  int get _availablePaise {
    final base = widget.fund.pendingAmountPaise;
    return _isEditing ? base + widget.receipt!.amountPaise : base;
  }

  @override
  void initState() {
    super.initState();
    final receipt = widget.receipt;
    if (receipt != null) {
      _amount.text = (receipt.amountPaise / 100).toStringAsFixed(2);
      _reference.text = receipt.referenceNumber ?? '';
      _notes.text = receipt.notes ?? '';
      _paymentMode = receipt.paymentMode;
      _date = receipt.receivedDate ?? DateTime.now();
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
    if (!ref.watch(currentOrgPermissionsProvider).canManageFunds) {
      return const AccessDeniedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Fund Receipt' : 'Add Fund Receipt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(widget.fund.departmentName),
              subtitle: Text(
                'Available: ₹${(_availablePaise / 100).toStringAsFixed(2)}',
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
            label: Text(_isEditing ? 'Update Receipt' : 'Save Receipt'),
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
    if (amount > _availablePaise) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Receipt cannot exceed the pending sanctioned amount.'),
        ),
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
        await repo.updateGovernmentReceipt(
          receiptId: widget.receipt!.id,
          amountPaise: amount,
          receivedDate: _date,
          paymentMode: _paymentMode,
          referenceNumber: reference,
          notes: notes,
        );
      } else {
        await repo.addGovernmentReceipt(
          governmentFundId: widget.fund.id,
          amountPaise: amount,
          receivedDate: _date,
          paymentMode: _paymentMode,
          referenceNumber: reference,
          notes: notes,
        );
      }
      ref.invalidate(fundReceiptsProvider(widget.fund.id));
      ref.invalidate(governmentFundsProvider(widget.fund.projectId));
      ref.invalidate(projectFinancialSummaryProvider(widget.fund.projectId));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Receipt updated.' : 'Receipt saved.'),
        ),
      );
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
  Investor? _newInvestor;
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

    final projectInvestorsAsync = ref.watch(
      projectInvestorsProvider(widget.project.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Investment' : 'Add Investment'),
      ),
      body: projectInvestorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Could not load project investors: $e')),
        data: (projectInvestors) {
          final visibleInvestors =
              [
                ...projectInvestors,
                if (_newInvestor != null &&
                    !projectInvestors.any((i) => i.id == _newInvestor!.id))
                  _newInvestor!,
              ]..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
          _investorId = visibleInvestors.any((i) => i.id == _investorId)
              ? _investorId
              : (visibleInvestors.isEmpty ? null : visibleInvestors.first.id);
          final selectedInvestor = visibleInvestors
              .where((i) => i.id == _investorId)
              .firstOrNull;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InvestorPickerField(
                      selectedInvestor: selectedInvestor,
                      enabled: visibleInvestors.isNotEmpty,
                      onTap: () => _openInvestorPicker(visibleInvestors),
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
                onPressed: _saving || visibleInvestors.isEmpty ? null : _save,
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
              if (visibleInvestors.isEmpty)
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
    final created = await showModalBottomSheet<Investor>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddInvestorSheet(),
    );
    if (created == null) return;
    if (!mounted) return;
    setState(() {
      _newInvestor = created;
      _investorId = created.id;
    });
    ref.invalidate(investorsProvider);
    ref.invalidate(projectInvestorsProvider(widget.project.id));
  }

  Future<void> _openInvestorPicker(List<Investor> investors) async {
    final action = await showModalBottomSheet<_InvestorPickerAction>(
      context: context,
      showDragHandle: true,
      builder: (_) => _InvestorPickerSheet(
        investors: investors,
        selectedInvestorId: _investorId,
      ),
    );
    if (!mounted || action == null) return;
    switch (action.type) {
      case _InvestorPickerActionType.select:
        setState(() => _investorId = action.investor.id);
      case _InvestorPickerActionType.edit:
        await _editInvestor(action.investor);
      case _InvestorPickerActionType.delete:
        await _deleteInvestor(action.investor);
    }
  }

  Future<void> _editInvestor(Investor investor) async {
    final updated = await showModalBottomSheet<Investor>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddInvestorSheet(investor: investor),
    );
    if (updated == null) return;
    if (!mounted) return;
    if (_newInvestor?.id == updated.id) {
      setState(() => _newInvestor = updated);
    }
    ref.invalidate(investorsProvider);
    ref.invalidate(projectInvestorsProvider(widget.project.id));
    ref.invalidate(projectInvestmentsProvider(widget.project.id));
  }

  Future<void> _deleteInvestor(Investor investor) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete investor?'),
        content: Text(
          'Remove ${investor.name} from this project and update investment totals?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final deletesCurrentInvestment =
          _isEditing && widget.investment!.investorId == investor.id;
      await ref
          .read(infraRepositoryProvider)
          .deleteProjectInvestor(
            projectId: widget.project.id,
            investorId: investor.id,
          );
      if (!mounted) return;
      setState(() {
        if (_newInvestor?.id == investor.id) _newInvestor = null;
        if (_investorId == investor.id) _investorId = null;
      });
      ref.invalidate(projectInvestmentsProvider(widget.project.id));
      ref.invalidate(projectInvestorsProvider(widget.project.id));
      ref.invalidate(projectFinancialSummaryProvider(widget.project.id));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(investorsProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${investor.name} deleted.')),
      );
      if (deletesCurrentInvestment && mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete investor: $error')),
      );
    }
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
      ref.invalidate(projectInvestorsProvider(widget.project.id));
      ref.invalidate(projectFinancialSummaryProvider(widget.project.id));
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(investorsProvider);
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

enum _InvestorPickerActionType { select, edit, delete }

class _InvestorPickerAction {
  const _InvestorPickerAction(this.type, this.investor);

  final _InvestorPickerActionType type;
  final Investor investor;
}

class _InvestorPickerField extends StatelessWidget {
  const _InvestorPickerField({
    required this.selectedInvestor,
    required this.enabled,
    required this.onTap,
  });

  final Investor? selectedInvestor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Investor',
          prefixIcon: Icon(Icons.person_outline),
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Text(
          selectedInvestor?.name ?? 'Select investor',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: enabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).disabledColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InvestorPickerSheet extends StatelessWidget {
  const _InvestorPickerSheet({
    required this.investors,
    required this.selectedInvestorId,
  });

  final List<Investor> investors;
  final String? selectedInvestorId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.72;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Investor',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: investors.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final investor = investors[index];
                    final selected = investor.id == selectedInvestorId;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => Navigator.pop(
                        context,
                        _InvestorPickerAction(
                          _InvestorPickerActionType.select,
                          investor,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: selected
                            ? theme.colorScheme.primary.withValues(alpha: .12)
                            : theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          selected ? Icons.check : Icons.person_outline,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        investor.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(
                              context,
                              _InvestorPickerAction(
                                _InvestorPickerActionType.edit,
                                investor,
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(
                              context,
                              _InvestorPickerAction(
                                _InvestorPickerActionType.delete,
                                investor,
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline),
                            color: theme.colorScheme.error,
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddInvestorSheet extends ConsumerStatefulWidget {
  const _AddInvestorSheet({this.investor});

  final Investor? investor;

  @override
  ConsumerState<_AddInvestorSheet> createState() => _AddInvestorSheetState();
}

class _AddInvestorSheetState extends ConsumerState<_AddInvestorSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pan = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.investor != null;

  @override
  void initState() {
    super.initState();
    final investor = widget.investor;
    if (investor == null) return;
    _name.text = investor.name;
    _phone.text = investor.phone ?? '';
    _email.text = investor.email ?? '';
    _pan.text = investor.pan ?? '';
  }

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
          Text(
            _isEditing ? 'Edit Investor' : 'New Investor',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
                : Text(_isEditing ? 'Update Investor' : 'Save Investor'),
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
      final repo = ref.read(infraRepositoryProvider);
      final investor = _isEditing
          ? await repo.updateInvestor(
              investorId: widget.investor!.id,
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              email: _email.text.trim(),
              pan: _pan.text.trim(),
              address: widget.investor!.address,
              notes: widget.investor!.notes,
            )
          : Investor(
              id: await repo.createInvestor(
                organizationId: org.id,
                name: _name.text.trim(),
                phone: _phone.text.trim(),
                email: _email.text.trim(),
                pan: _pan.text.trim(),
              ),
              organizationId: org.id,
              name: _name.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              pan: _pan.text.trim().isEmpty ? null : _pan.text.trim(),
            );
      if (mounted) Navigator.pop(context, investor);
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
