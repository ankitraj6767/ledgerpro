import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../data/repositories/demo_ledger_provider.dart';
import '../../../shared/components/sync_badge.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref
        .watch(demoTransactionsProvider)
        .firstWhere(
          (item) => item.id == transactionId,
          orElse: () => ref.watch(demoTransactionsProvider).first,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.type.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      SyncBadge(status: entry.syncStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    Money.fromPaise(entry.amountPaise).formatInr(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Mode: ${entry.paymentMode.name.toUpperCase()}'),
                  Text('Date: ${entry.occurredAt}'),
                  if (entry.note != null) Text('Note: ${entry.note}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text('Financial safety'),
              subtitle: const Text(
                'Edits create audit entries. Deletes are soft archive or reversal entries only.',
              ),
              trailing: OutlinedButton(
                onPressed: () {},
                child: const Text('Reverse'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
