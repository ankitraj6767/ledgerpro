import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/money.dart';
import '../../../data/repositories/demo_ledger_provider.dart';

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
    final parties = ref.watch(demoPartiesProvider).where((party) {
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
            child: ListView.builder(
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
                      Money.fromPaise(party.balancePaise.abs()).formatInr(),
                      style: const TextStyle(fontWeight: FontWeight.w900),
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
}
