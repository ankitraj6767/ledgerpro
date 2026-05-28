import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/demo_ledger_provider.dart';

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

class BulkReminderScreen extends ConsumerWidget {
  const BulkReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(demoPartiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk reminder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...parties.map(
            (party) => Card(
              child: CheckboxListTile(
                value: party.balancePaise > 0,
                onChanged: (_) {},
                title: Text(
                  party.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(party.phone),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined),
            label: const Text('Open WhatsApp reminders'),
          ),
        ],
      ),
    );
  }
}
