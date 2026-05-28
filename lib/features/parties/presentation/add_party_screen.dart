import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class AddPartyScreen extends ConsumerStatefulWidget {
  const AddPartyScreen({super.key});

  @override
  ConsumerState<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends ConsumerState<AddPartyScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  PartyType _type = PartyType.customer;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add party')),
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
            controller: _openingBalanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Opening balance',
              prefixIcon: Icon(Icons.currency_rupee),
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
            label: const Text('Save party'),
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

    setState(() => _saving = true);
    try {
      await ref
          .read(ledgerRepositoryProvider)
          .createParty(
            type: _type,
            name: name,
            phone: _phoneController.text.trim(),
            openingBalancePaise: _parseOptionalMoney(
              _openingBalanceController.text,
            ),
            creditLimitPaise: _parseOptionalMoney(_creditLimitController.text),
            tags: _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
            notes: _notesController.text,
          );
      ref.invalidate(partiesProvider);
      ref.invalidate(businessSummaryProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Party saved.')));
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
