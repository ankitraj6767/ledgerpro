import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/utils/communication_service.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';
import '../data/reminder_templates_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(reminderTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              value: false,
              onChanged: (_) {},
              title: const Text('SMS provider'),
              subtitle: const Text('SMS provider not connected'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Templates',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...templates.map(
            (template) => Card(
              child: ListTile(
                leading: Icon(
                  template.firmTone
                      ? Icons.priority_high_outlined
                      : Icons.chat_bubble_outline,
                ),
                title: Text(
                  template.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(template.body),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulkReminderScreen extends ConsumerStatefulWidget {
  const BulkReminderScreen({super.key});

  @override
  ConsumerState<BulkReminderScreen> createState() => _BulkReminderScreenState();
}

class _BulkReminderScreenState extends ConsumerState<BulkReminderScreen> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesProvider);
    final businessName =
        ref.watch(businessNameProvider).value ?? 'LedgerPro Business';

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk reminder')),
      body: partiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load parties: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (parties) {
          // Only parties that owe money (positive balance) and have a phone.
          final receivableParties = parties
              .where((p) => p.balancePaise > 0 && p.phone.trim().isNotEmpty)
              .toList();

          if (receivableParties.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No parties with a pending balance and phone number to remind.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...receivableParties.map(
                (party) => Card(
                  child: CheckboxListTile(
                    value: _selected.contains(party.id),
                    onChanged: (checked) => setState(() {
                      if (checked ?? false) {
                        _selected.add(party.id);
                      } else {
                        _selected.remove(party.id);
                      }
                    }),
                    title: Text(
                      party.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${party.phone} · ${Money.fromPaise(party.balancePaise).formatInr()}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _selected.isEmpty
                    ? null
                    : () => _sendReminders(receivableParties, businessName),
                icon: const Icon(Icons.send_outlined),
                label: Text(
                  'Open WhatsApp reminders (${_selected.length})',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendReminders(
    List<Party> parties,
    String businessName,
  ) async {
    const communication = CommunicationService();
    final targets = parties.where((p) => _selected.contains(p.id)).toList();
    for (final party in targets) {
      await communication.openWhatsappReminder(
        phone: party.phone,
        name: party.name,
        businessName: businessName,
        amountPaise: party.balancePaise.abs(),
      );
    }
  }
}
