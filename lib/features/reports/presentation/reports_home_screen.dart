import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/ledger_repository.dart';
import '../data/report_service.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = <(ReportType, IconData)>[
      (ReportType.customerStatement, Icons.person_search_outlined),
      (ReportType.supplierStatement, Icons.local_shipping_outlined),
      (ReportType.allTransactions, Icons.receipt_long_outlined),
      (ReportType.dailyReport, Icons.today_outlined),
      (ReportType.monthlyReport, Icons.calendar_month_outlined),
      (ReportType.cashbook, Icons.payments_outlined),
      (ReportType.daybook, Icons.menu_book_outlined),
      (ReportType.receivables, Icons.trending_up_outlined),
      (ReportType.payables, Icons.trending_down_outlined),
      (ReportType.gstSalesSummary, Icons.percent_outlined),
      (ReportType.inventoryReport, Icons.inventory_2_outlined),
      (ReportType.auditLogReport, Icons.manage_search_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...reports.map(
            (report) => Card(
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReportDetailScreen(type: report.$1),
                  ),
                ),
                leading: Icon(report.$2),
                title: Text(
                  report.$1.title,
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

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, this.type = ReportType.allTransactions});

  final ReportType type;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  bool _busy = false;

  Future<ReportData?> _buildReport() async {
    final parties = await ref.read(partiesProvider.future);
    final transactions = await ref.read(ledgerTransactionsProvider.future);
    final businessName = await ref.read(businessNameProvider.future);
    return const ReportService().build(
      type: widget.type,
      businessName: businessName,
      parties: parties,
      transactions: transactions,
    );
  }

  Future<void> _export({required bool asPdf}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = await _buildReport();
      if (data == null) return;
      const service = ReportService();
      final file = asPdf
          ? await service.generatePdf(data)
          : await service.generateCsv(data);
      await service.share(file, isPdf: asPdf);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${asPdf ? 'PDF' : 'CSV'} generated and ready to share.'),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate report: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareViaWhatsapp() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = await _buildReport();
      if (data == null) return;
      final file = await const ReportService().generatePdf(data);
      // share_plus opens the system sheet which includes WhatsApp/Email.
      await const ReportService().share(file, isPdf: true);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not share report: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesProvider);
    final transactionsAsync = ref.watch(ledgerTransactionsProvider);
    final businessName =
        ref.watch(businessNameProvider).value ?? 'LedgerPro Business';

    final isLoading = partiesAsync.isLoading || transactionsAsync.isLoading;
    final error = partiesAsync.hasError
        ? partiesAsync.error
        : transactionsAsync.error;

    ReportData? preview;
    if (!isLoading && error == null) {
      preview = const ReportService().build(
        type: widget.type,
        businessName: businessName,
        parties: partiesAsync.value ?? const [],
        transactions: transactionsAsync.value ?? const [],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.type.title)),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load report data: $error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(partiesProvider);
                        ref.invalidate(ledgerTransactionsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = preview!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(data.subtitle),
                      const SizedBox(height: 12),
                      ...data.summaryLines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            line,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _export(asPdf: true),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: const Text('PDF'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _export(asPdf: false),
                              icon: const Icon(Icons.table_view_outlined),
                              label: const Text('CSV'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _shareViaWhatsapp,
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share (WhatsApp / Email)'),
                      ),
                      if (_busy) ...[
                        const SizedBox(height: 12),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Preview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (data.rows.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No records for this report yet.'),
                  ),
                )
              else
                _ReportPreviewTable(data: data),
            ],
          );
        },
      ),
    );
  }
}

class _ReportPreviewTable extends StatelessWidget {
  const _ReportPreviewTable({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    // Show up to 50 rows in the preview to keep the UI responsive.
    final rows = data.rows.take(50).toList();
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: data.headers
              .map(
                (h) => DataColumn(
                  label: Text(
                    h,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              )
              .toList(),
          rows: rows
              .map(
                (row) => DataRow(
                  cells: row.map((cell) => DataCell(Text(cell))).toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Kept for backwards compatibility with existing routes that reference a
/// generic report detail (e.g. dashboard "View all"). Defaults to all
/// transactions.
class LegacyReportDetailScreen extends StatelessWidget {
  const LegacyReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportDetailScreen(type: ReportType.allTransactions);
  }
}
