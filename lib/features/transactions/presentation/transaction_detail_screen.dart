import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/components/sync_badge.dart';
import '../../../shared/models/ledger_models.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(ledgerTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction detail')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load transaction: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (transactions) {
          final entry = transactions
              .where((item) => item.id == transactionId)
              .firstOrNull;
          if (entry == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('This transaction is no longer available.'),
              ),
            );
          }
          return _TransactionDetailBody(entry: entry);
        },
      ),
    );
  }
}

class _TransactionDetailBody extends StatelessWidget {
  const _TransactionDetailBody({required this.entry});

  final LedgerTransaction entry;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        const Card(
          child: ListTile(
            leading: Icon(Icons.warning_amber_outlined),
            title: Text('Financial safety'),
            subtitle: Text(
              'Edits create audit entries. Deletes are soft archive or reversal entries only.',
            ),
          ),
        ),
      ],
    );
  }
}
