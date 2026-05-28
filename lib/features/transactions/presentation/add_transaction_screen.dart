import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.youGave;
  PaymentMode _mode = PaymentMode.cash;
  String? _partyId;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _dueDateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add transaction')),
      body: partiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _TransactionLoadError(
          message: 'Could not load parties: $error',
          onRetry: () => ref.invalidate(partiesProvider),
        ),
        data: (parties) {
          if (parties.isEmpty) {
            return const _NoPartiesForTransaction();
          }
          _partyId ??= parties.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.youGave,
                    icon: Icon(Icons.north_east),
                    label: Text('You gave'),
                  ),
                  ButtonSegment(
                    value: TransactionType.youGot,
                    icon: Icon(Icons.south_west),
                    label: Text('You got'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) =>
                    setState(() => _type = value.first),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _partyId,
                decoration: const InputDecoration(
                  labelText: 'Party',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                items: parties
                    .map(
                      (party) => DropdownMenuItem(
                        value: party.id,
                        child: Text(party.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _partyId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMode>(
                initialValue: _mode,
                decoration: const InputDecoration(
                  labelText: 'Payment mode',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                items: PaymentMode.values
                    .map(
                      (mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (mode) => setState(() => _mode = mode ?? _mode),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dueDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Due date',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: const Text('Save to LedgerPro cloud'),
                  subtitle: const Text(
                    'The party balance updates after the database confirms this entry.',
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _type == TransactionType.youGot
                      ? AppTheme.emerald
                      : null,
                ),
                onPressed: _saving ? null : _saveTransaction,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save transaction'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final messenger = ScaffoldMessenger.of(context);
    final partyId = _partyId;
    if (partyId == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Select a party.')));
      return;
    }

    late final int amountPaise;
    try {
      amountPaise = LedgerRepository.parsePaise(_amountController.text);
      if (amountPaise <= 0) throw const FormatException('Amount is required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final dueDateText = _dueDateController.text.trim();
    final dueDate = dueDateText.isEmpty ? null : DateTime.tryParse(dueDateText);
    if (dueDateText.isNotEmpty && dueDate == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Use due date format YYYY-MM-DD.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(ledgerRepositoryProvider)
          .createTransaction(
            partyId: partyId,
            type: _type,
            amountPaise: amountPaise,
            paymentMode: _mode,
            note: _noteController.text,
            dueDate: dueDate,
          );
      ref.invalidate(partiesProvider);
      ref.invalidate(ledgerTransactionsProvider);
      ref.invalidate(businessSummaryProvider);
      _amountController.clear();
      _dueDateController.clear();
      _noteController.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaction saved and synced.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _TransactionLoadError extends StatelessWidget {
  const _TransactionLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPartiesForTransaction extends StatelessWidget {
  const _NoPartiesForTransaction();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Add a customer or supplier before saving a transaction.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
