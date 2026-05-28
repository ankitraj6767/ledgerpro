import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/money/money.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => context.push(AppRoutes.addProduct),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text(
                'Premium rice bag',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('SKU RICE-25KG · Stock 12 · Low stock at 8'),
              trailing: Text(
                Money.fromPaise(145000).formatInr(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text(
                'Low-stock report',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('4 items need restock attention'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Product name',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'SKU',
              prefixIcon: Icon(Icons.tag_outlined),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MobileScanner(
                onDetect: (_) {},
                errorBuilder: (context, error) => const Center(
                  child: Text(
                    'Camera unavailable. Barcode can be entered manually.',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Sale price'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'GST %'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Opening stock',
              prefixIcon: Icon(Icons.add_box_outlined),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save product'),
          ),
        ],
      ),
    );
  }
}
