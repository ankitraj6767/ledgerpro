import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../data/repositories/demo_ledger_provider.dart';
import '../../../shared/models/ledger_models.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  TransactionType _type = TransactionType.youGave;
  PaymentMode _mode = PaymentMode.cash;

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(demoPartiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add transaction')),
      body: ListView(
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
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: parties.first.id,
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
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
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
          const TextField(
            decoration: InputDecoration(
              labelText: 'Due date',
              prefixIcon: Icon(Icons.event_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Note',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Save offline if network is unavailable'),
              subtitle: const Text(
                'A pending sync mutation will be queued locally.',
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction queued offline')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save transaction'),
          ),
        ],
      ),
    );
  }
}
