import 'package:flutter/material.dart';

import '../../../shared/models/ledger_models.dart';

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key});

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  PartyType _type = PartyType.customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add party')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<PartyType>(
            segments: const [
              ButtonSegment(
                value: PartyType.customer,
                icon: Icon(Icons.person_outline),
                label: Text('Customer'),
              ),
              ButtonSegment(
                value: PartyType.supplier,
                icon: Icon(Icons.local_shipping_outlined),
                label: Text('Supplier'),
              ),
              ButtonSegment(
                value: PartyType.both,
                icon: Icon(Icons.swap_horiz),
                label: Text('Both'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Opening balance',
              prefixIcon: Icon(Icons.currency_rupee),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Credit limit',
              prefixIcon: Icon(Icons.speed_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Tags',
              prefixIcon: Icon(Icons.sell_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save party offline'),
          ),
        ],
      ),
    );
  }
}
