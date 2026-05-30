import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/communication_service.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/components/sync_badge.dart';
import '../../../shared/models/ledger_models.dart';

class PartyDetailScreen extends ConsumerWidget {
  const PartyDetailScreen({super.key, required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partiesProvider);

    return partiesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Party')),
        body: _PartyError(
          message: 'Could not load party: $error',
          onRetry: () => ref.invalidate(partiesProvider),
        ),
      ),
      data: (parties) {
        final party = parties.where((p) => p.id == partyId).firstOrNull;
        if (party == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Party')),
            body: const _PartyError(
              message: 'This party is no longer available.',
            ),
          );
        }
        return _PartyDetailView(party: party);
      },
    );
  }
}

class _PartyDetailView extends ConsumerWidget {
  const _PartyDetailView({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(partyTransactionsProvider(party.id));
    final profileAsync = ref.watch(businessProfileProvider);
    final businessName = profileAsync.value?.name ?? 'LedgerPro Business';
    final communication = const CommunicationService();
    final receivable = party.balancePaise >= 0;
    final hasPhone = party.phone.trim().isNotEmpty;
    // Prefer the party's own UPI id, else fall back to the business UPI id.
    final upiId = (party.upiId?.trim().isNotEmpty ?? false)
        ? party.upiId!.trim()
        : profileAsync.value?.upiId?.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name),
        actions: [
          IconButton(
            tooltip: 'Edit party',
            onPressed: () => context.push(AppRoutes.addParty, extra: party),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete party',
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
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
                  onPressed: hasPhone
                      ? () => communication.call(party.phone)
                      : null,
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasPhone
                      ? () => communication.openWhatsappReminder(
                          phone: party.phone,
                          name: party.name,
                          businessName: businessName,
                          amountPaise: party.balancePaise.abs(),
                        )
                      : null,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          if (!hasPhone)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Add a phone number to enable Call and WhatsApp.',
                style: TextStyle(fontSize: 12),
              ),
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
          _PaymentQrCard(
            upiId: upiId,
            businessName: businessName,
            party: party,
            communication: communication,
          ),
          const SizedBox(height: 16),
          Text(
            'Ledger timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No transactions yet for this party.'),
              ),
            )
          else
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete party?'),
        content: Text(
          'This will remove ${party.name} from your active list. '
          'The record is archived for audit and can be restored by support.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.crimson),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(ledgerRepositoryProvider).softDeleteParty(party.id);
      ref.invalidate(partiesProvider);
      ref.invalidate(businessSummaryProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${party.name} deleted.')),
      );
      router.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete party: $error')),
      );
    }
  }
}

class _PaymentQrCard extends StatelessWidget {
  const _PaymentQrCard({
    required this.upiId,
    required this.businessName,
    required this.party,
    required this.communication,
  });

  final String? upiId;
  final String businessName;
  final Party party;
  final CommunicationService communication;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment QR',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (upiId == null || upiId!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No UPI id set. Add a UPI id to this party (or your business '
                  'profile) to show a payment QR.',
                ),
              )
            else ...[
              Center(
                child: QrImageView(
                  data: communication
                      .upiDeepLink(
                        upiId: upiId!,
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
              Text(
                upiId!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Payment success is never assumed. Mark paid manually after confirmation.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartyError extends StatelessWidget {
  const _PartyError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

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
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
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
