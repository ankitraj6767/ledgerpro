import 'package:flutter/material.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = const [
      'View parties',
      'Add transaction',
      'Edit transaction',
      'Send reminders',
      'Create invoice',
      'Manage inventory',
      'Export reports',
      'Manage staff',
      'View dashboard totals',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text(
                'Owner',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Full access · Every action logged'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Invite'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Permissions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...permissions.map(
            (permission) => Card(
              child: CheckboxListTile(
                value: true,
                onChanged: (_) {},
                title: Text(permission),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
