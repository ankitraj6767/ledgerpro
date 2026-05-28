import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = const [
      ('Customer statement', Icons.person_search_outlined),
      ('Supplier statement', Icons.local_shipping_outlined),
      ('All transactions', Icons.receipt_long_outlined),
      ('Daily report', Icons.today_outlined),
      ('Monthly report', Icons.calendar_month_outlined),
      ('Cashbook', Icons.payments_outlined),
      ('Daybook', Icons.menu_book_outlined),
      ('Receivables', Icons.trending_up_outlined),
      ('Payables', Icons.trending_down_outlined),
      ('GST sales summary', Icons.percent_outlined),
      ('Inventory report', Icons.inventory_2_outlined),
      ('Audit log report', Icons.manage_search_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Exports',
            onPressed: () => context.push(AppRoutes.exportCenter),
            icon: const Icon(Icons.ios_share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _DateChip(label: 'Today', selected: true),
                _DateChip(label: 'Yesterday'),
                _DateChip(label: 'This week'),
                _DateChip(label: 'This month'),
                _DateChip(label: 'Custom'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...reports.map(
            (report) => Card(
              child: ListTile(
                onTap: () => context.push(AppRoutes.reportDetail),
                leading: Icon(report.$2),
                title: Text(
                  report.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('PDF · CSV · WhatsApp · Email'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile report preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reports are generated from transaction history so balances remain reproducible.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('PDF'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.table_view_outlined),
                          label: const Text('CSV'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
