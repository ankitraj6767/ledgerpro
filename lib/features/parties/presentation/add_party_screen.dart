import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/money.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class AddPartyScreen extends ConsumerStatefulWidget {
  const AddPartyScreen({super.key, this.party});

  /// When provided, the screen edits an existing party instead of creating one.
  final Party? party;

  @override
  ConsumerState<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends ConsumerState<AddPartyScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _upiController;
  late final TextEditingController _openingBalanceController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _tagsController;
  late final TextEditingController _notesController;
  late PartyType _type;
  bool _saving = false;

  bool get _isEditing => widget.party != null;

  @override
  void initState() {
    super.initState();
    final party = widget.party;
    _nameController = TextEditingController(text: party?.name ?? '');
    _phoneController = TextEditingController(text: party?.phone ?? '');
    _upiController = TextEditingController(text: party?.upiId ?? '');
    _openingBalanceController = TextEditingController(
      text: party == null
          ? ''
          : Money.fromPaise(party.balancePaise).formatPlain(),
    );
    _creditLimitController = TextEditingController(
      text: party == null || party.creditLimitPaise == 0
          ? ''
          : Money.fromPaise(party.creditLimitPaise).formatPlain(),
    );
    _tagsController = TextEditingController(text: party?.tags.join(', ') ?? '');
    _notesController = TextEditingController(text: party?.notes ?? '');
    _type = party?.type ?? PartyType.customer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit party' : 'Add party')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<PartyType>(
            segments: const [
              ButtonSegment(
                value: PartyType.customer,
                icon: Icon(Icons.person_outline),
                label: Text('Customer'),
              ),
              ButtonSegment(
                value: PartyType.supplier,
                icon: Icon(Icons.local_shipping_outlined),
                label: Text('Supplier'),
              ),
              ButtonSegment(
                value: PartyType.both,
                icon: Icon(Icons.swap_horiz),
                label: Text('Both'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _upiController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'UPI ID (for payment QR)',
              hintText: 'name@bank',
              prefixIcon: Icon(Icons.qr_code_2_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _openingBalanceController,
            enabled: !_isEditing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Opening balance',
              prefixIcon: const Icon(Icons.currency_rupee),
              helperText: _isEditing
                  ? 'Opening balance can only be set when creating a party.'
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _creditLimitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Credit limit',
              prefixIcon: Icon(Icons.speed_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags',
              prefixIcon: Icon(Icons.sell_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving ? null : _saveParty,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isEditing ? 'Update party' : 'Save party'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveParty() async {
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Party name is required.')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    setState(() => _saving = true);
    try {
      final repository = ref.read(ledgerRepositoryProvider);
      if (_isEditing) {
        await repository.updateParty(
          partyId: widget.party!.id,
          type: _type,
          name: name,
          phone: _phoneController.text.trim(),
          creditLimitPaise: _parseOptionalMoney(_creditLimitController.text),
          tags: tags,
          notes: _notesController.text,
          upiId: _upiController.text,
        );
      } else {
        await repository.createParty(
          type: _type,
          name: name,
          phone: _phoneController.text.trim(),
          openingBalancePaise: _parseOptionalMoney(
            _openingBalanceController.text,
          ),
          creditLimitPaise: _parseOptionalMoney(_creditLimitController.text),
          tags: tags,
          notes: _notesController.text,
          upiId: _upiController.text,
        );
      }
      ref.invalidate(partiesProvider);
      ref.invalidate(businessSummaryProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Party updated.' : 'Party saved.')),
      );
      if (mounted) context.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save party: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _parseOptionalMoney(String input) {
    final value = input.trim();
    if (value.isEmpty) return 0;
    return LedgerRepository.parsePaise(value);
  }
}
