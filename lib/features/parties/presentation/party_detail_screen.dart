import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/communication_service.dart';
import '../../../data/repositories/demo_ledger_provider.dart';
import '../../../shared/components/sync_badge.dart';
import '../../../shared/models/ledger_models.dart';

class PartyDetailScreen extends ConsumerWidget {
  const PartyDetailScreen({super.key, required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref
        .watch(demoPartiesProvider)
        .firstWhere(
          (item) => item.id == partyId,
          orElse: () => ref.watch(demoPartiesProvider).first,
        );
    final transactions = ref
        .watch(demoTransactionsProvider)
        .where((entry) => entry.partyId == party.id)
        .toList();
    final businessName = ref.watch(businessNameProvider);
    final upiId = ref.watch(ownerUpiIdProvider);
    final communication = const CommunicationService();
    final receivable = party.balancePaise >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        actions: [
          IconButton(
            tooltip: 'Edit party',
            onPressed: () => context.push(AppRoutes.addParty),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
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
                          receivable ? 'You will get' : 'You have to give',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      SyncBadge(status: party.syncStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Money.fromPaise(party.balancePaise.abs()).formatInr(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: receivable ? AppTheme.emerald : AppTheme.crimson,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.go(AppRoutes.add),
                          icon: const Icon(Icons.north_east),
                          label: const Text('You gave'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.emerald,
                          ),
                          onPressed: () => context.go(AppRoutes.add),
                          icon: const Icon(Icons.south_west),
                          label: const Text('You got'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => communication.call(party.phone),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => communication.openWhatsappReminder(
                    phone: party.phone,
                    name: party.name,
                    businessName: businessName,
                    amountPaise: party.balancePaise.abs(),
                  ),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final file = await communication.createStatementPdf(
                party: party,
                transactions: transactions,
                businessName: businessName,
              );
              await communication.shareStatementPdf(file);
              messenger.showSnackBar(
                const SnackBar(content: Text('Statement PDF generated')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Statement PDF'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment QR',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: QrImageView(
                      data: communication
                          .upiDeepLink(
                            upiId: upiId,
                            payeeName: businessName,
                            amountPaise: party.balancePaise > 0
                                ? party.balancePaise
                                : null,
                            note: 'Ledger payment ${party.name}',
                          )
                          .toString(),
                      size: 180,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Payment success is never assumed. Mark paid manually after confirmation.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ledger timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...transactions.map(
            (entry) => Card(
              child: ListTile(
                onTap: () => context.push('/transactions/${entry.id}'),
                leading: Icon(
                  entry.type == TransactionType.youGot
                      ? Icons.south_west
                      : Icons.north_east,
                  color: entry.type == TransactionType.youGot
                      ? AppTheme.emerald
                      : AppTheme.brass,
                ),
                title: Text(
                  entry.type.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(entry.note ?? 'No note'),
                trailing: Text(
                  Money.fromPaise(entry.amountPaise).formatInr(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _AuditNotice(),
        ],
      ),
    );
  }
}

class _AuditNotice extends StatelessWidget {
  const _AuditNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history_outlined),
        title: const Text('Audit history'),
        subtitle: const Text(
          'Edits and reversals remain visible to the owner.',
        ),
        trailing: IconButton(
          tooltip: 'Audit logs',
          onPressed: () => context.push(AppRoutes.auditLogs),
          icon: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
