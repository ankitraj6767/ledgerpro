import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/money/money.dart';
import '../../../data/repositories/demo_ledger_provider.dart';
import '../../../shared/components/sync_badge.dart';
import '../../../shared/models/ledger_models.dart';

class PartiesListScreen extends ConsumerStatefulWidget {
  const PartiesListScreen({super.key});

  @override
  ConsumerState<PartiesListScreen> createState() => _PartiesListScreenState();
}

class _PartiesListScreenState extends ConsumerState<PartiesListScreen> {
  final _queryController = TextEditingController();
  PartyType? _typeFilter;
  bool? _receivableFilter;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parties = _filtered(ref.watch(demoPartiesProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties'),
        actions: [
          IconButton(
            tooltip: 'Add party',
            onPressed: () => context.push(AppRoutes.addParty),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              controller: _queryController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search name, phone, amount, tag, note',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  selected: _typeFilter == null,
                  label: const Text('All'),
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: _typeFilter == PartyType.customer,
                  label: const Text('Customers'),
                  onSelected: (_) =>
                      setState(() => _typeFilter = PartyType.customer),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: _typeFilter == PartyType.supplier,
                  label: const Text('Suppliers'),
                  onSelected: (_) =>
                      setState(() => _typeFilter = PartyType.supplier),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: _receivableFilter == true,
                  label: const Text('Receivable'),
                  onSelected: (_) => setState(() => _receivableFilter = true),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: _receivableFilter == false,
                  label: const Text('Payable'),
                  onSelected: (_) => setState(() => _receivableFilter = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: parties.isEmpty
                ? const _EmptyParties()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: parties.length,
                    itemBuilder: (context, index) {
                      final party = parties[index];
                      final receivable = party.balancePaise >= 0;
                      return Card(
                        child: ListTile(
                          onTap: () => context.push('/parties/${party.id}'),
                          leading: CircleAvatar(
                            backgroundColor:
                                (receivable
                                        ? AppTheme.emerald
                                        : AppTheme.crimson)
                                    .withValues(alpha: 0.12),
                            child: Text(
                              party.name.characters.first.toUpperCase(),
                              style: TextStyle(
                                color: receivable
                                    ? AppTheme.emerald
                                    : AppTheme.crimson,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          title: Text(
                            party.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            '${party.phone} · ${party.tags.join(', ')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Money.fromPaise(
                                  party.balancePaise.abs(),
                                ).formatInr(),
                                style: TextStyle(
                                  color: receivable
                                      ? AppTheme.emerald
                                      : AppTheme.crimson,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SyncBadge(status: party.syncStatus),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Party> _filtered(List<Party> parties) {
    final query = _queryController.text.trim().toLowerCase();
    final filtered = parties.where((party) {
      final typeMatches =
          _typeFilter == null ||
          party.type == _typeFilter ||
          party.type == PartyType.both;
      final balanceMatches =
          _receivableFilter == null ||
          (_receivableFilter!
              ? party.balancePaise >= 0
              : party.balancePaise < 0);
      final haystack = [
        party.name,
        party.phone,
        party.alternatePhone ?? '',
        party.notes ?? '',
        party.balancePaise.abs().toString(),
        ...party.tags,
      ].join(' ').toLowerCase();
      return typeMatches && balanceMatches && haystack.contains(query);
    }).toList();
    filtered.sort(
      (a, b) => b.balancePaise.abs().compareTo(a.balancePaise.abs()),
    );
    return filtered;
  }
}

class _EmptyParties extends StatelessWidget {
  const _EmptyParties();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_outlined, size: 54),
            const SizedBox(height: 12),
            Text(
              'No parties found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a customer or supplier to start your digital ledger.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
