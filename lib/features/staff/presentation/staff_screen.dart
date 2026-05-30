import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                Text('Could not load staff: $error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(staffProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (members) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(staffProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...members.map(
                (member) => Card(
                  child: ListTile(
                    leading: Icon(
                      member.role == MemberRole.owner
                          ? Icons.verified_user_outlined
                          : Icons.person_outline,
                    ),
                    title: Text(
                      member.fullName ?? _roleLabel(member.role),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${_roleLabel(member.role)} · ${member.permissions.length} permissions',
                    ),
                  ),
                ),
              ),
              if (members.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No team members yet.'),
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Inviting staff'),
                  subtitle: const Text(
                    'Staff invitations and role management are owner-only and '
                    'require server-side setup. Your owner account already has '
                    'full access.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(MemberRole role) => switch (role) {
        MemberRole.owner => 'Owner',
        MemberRole.manager => 'Manager',
        MemberRole.accountant => 'Accountant',
        MemberRole.staff => 'Staff',
      };
}
