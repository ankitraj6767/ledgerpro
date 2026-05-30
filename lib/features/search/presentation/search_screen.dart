import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/money.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.toLowerCase();
    final partiesAsync = ref.watch(partiesProvider);
    final allParties = partiesAsync.value ?? const <Party>[];
    final parties = allParties.where((party) {
      final haystack =
          '${party.name} ${party.phone} ${party.tags.join(' ')} ${party.notes ?? ''}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search parties, notes, tags, phone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: partiesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load parties: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (_) {
                if (parties.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching parties.'),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: parties.length,
                  itemBuilder: (context, index) {
                    final party = parties[index];
                    return Card(
                      child: ListTile(
                        onTap: () => context.push('/parties/${party.id}'),
                        title: Text(
                          party.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(party.phone),
                        trailing: Text(
                          Money.fromPaise(
                            party.balancePaise.abs(),
                          ).formatInr(),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
