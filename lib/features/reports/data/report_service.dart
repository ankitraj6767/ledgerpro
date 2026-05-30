import 'dart:io';

import 'package:csv/csv.dart' as csv_lib;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/money/money.dart';
import '../../../shared/models/ledger_models.dart';

/// The set of report types available on the Reports screen.
enum ReportType {
  customerStatement,
  supplierStatement,
  allTransactions,
  dailyReport,
  monthlyReport,
  cashbook,
  daybook,
  receivables,
  payables,
  gstSalesSummary,
  inventoryReport,
  auditLogReport,
}

extension ReportTypeMeta on ReportType {
  String get title => switch (this) {
    ReportType.customerStatement => 'Customer statement',
    ReportType.supplierStatement => 'Supplier statement',
    ReportType.allTransactions => 'All transactions',
    ReportType.dailyReport => 'Daily report',
    ReportType.monthlyReport => 'Monthly report',
    ReportType.cashbook => 'Cashbook',
    ReportType.daybook => 'Daybook',
    ReportType.receivables => 'Receivables',
    ReportType.payables => 'Payables',
    ReportType.gstSalesSummary => 'GST sales summary',
    ReportType.inventoryReport => 'Inventory report',
    ReportType.auditLogReport => 'Audit log report',
  };

  /// Whether this report is party-centric (customer/supplier statements)
  /// versus transaction/summary based.
  bool get isPartyBased =>
      this == ReportType.customerStatement ||
      this == ReportType.supplierStatement;
}

/// A computed, render-ready report: a set of named columns plus rows of cells.
class ReportData {
  ReportData({
    required this.title,
    required this.subtitle,
    required this.headers,
    required this.rows,
    this.summaryLines = const [],
  });

  final String title;
  final String subtitle;
  final List<String> headers;
  final List<List<String>> rows;
  final List<String> summaryLines;
}

/// Builds report content from real ledger data and exports it as PDF or CSV.
class ReportService {
  const ReportService();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  /// Computes the report rows for [type] from the provided parties and
  /// transactions.
  ReportData build({
    required ReportType type,
    required String businessName,
    required List<Party> parties,
    required List<LedgerTransaction> transactions,
  }) {
    final partyById = {for (final p in parties) p.id: p};
    String nameFor(String partyId) => partyById[partyId]?.name ?? 'Party';

    switch (type) {
      case ReportType.customerStatement:
        return _partyStatement(
          businessName: businessName,
          parties: parties
              .where(
                (p) =>
                    p.type == PartyType.customer || p.type == PartyType.both,
              )
              .toList(),
          label: 'Customer statement',
        );
      case ReportType.supplierStatement:
        return _partyStatement(
          businessName: businessName,
          parties: parties
              .where(
                (p) =>
                    p.type == PartyType.supplier || p.type == PartyType.both,
              )
              .toList(),
          label: 'Supplier statement',
        );
      case ReportType.allTransactions:
      case ReportType.daybook:
        return _transactionLedger(
          businessName: businessName,
          title: type.title,
          transactions: transactions,
          nameFor: nameFor,
        );
      case ReportType.dailyReport:
        final today = DateTime.now();
        final start = DateTime(today.year, today.month, today.day);
        return _transactionLedger(
          businessName: businessName,
          title: 'Daily report (${_dateFormat.format(today)})',
          transactions: transactions
              .where((t) => !t.occurredAt.isBefore(start))
              .toList(),
          nameFor: nameFor,
        );
      case ReportType.monthlyReport:
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, 1);
        return _transactionLedger(
          businessName: businessName,
          title: 'Monthly report (${DateFormat('MMM yyyy').format(now)})',
          transactions: transactions
              .where((t) => !t.occurredAt.isBefore(start))
              .toList(),
          nameFor: nameFor,
        );
      case ReportType.cashbook:
        return _transactionLedger(
          businessName: businessName,
          title: 'Cashbook (cash entries)',
          transactions: transactions
              .where((t) => t.paymentMode == PaymentMode.cash)
              .toList(),
          nameFor: nameFor,
        );
      case ReportType.receivables:
        return _balanceReport(
          businessName: businessName,
          title: 'Receivables',
          parties: parties.where((p) => p.balancePaise > 0).toList(),
        );
      case ReportType.payables:
        return _balanceReport(
          businessName: businessName,
          title: 'Payables',
          parties: parties.where((p) => p.balancePaise < 0).toList(),
        );
      case ReportType.gstSalesSummary:
        return _transactionLedger(
          businessName: businessName,
          title: 'GST sales summary',
          transactions: transactions
              .where(
                (t) =>
                    t.type == TransactionType.sale ||
                    t.type == TransactionType.youGot,
              )
              .toList(),
          nameFor: nameFor,
        );
      case ReportType.inventoryReport:
        return ReportData(
          title: 'Inventory report',
          subtitle: businessName,
          headers: const ['Item', 'Stock', 'Status'],
          rows: const [],
          summaryLines: const [
            'No inventory items have been added yet.',
          ],
        );
      case ReportType.auditLogReport:
        return _transactionLedger(
          businessName: businessName,
          title: 'Audit log report',
          transactions: transactions,
          nameFor: nameFor,
          includeAudit: true,
        );
    }
  }

  ReportData _partyStatement({
    required String businessName,
    required List<Party> parties,
    required String label,
  }) {
    final rows = parties
        .map(
          (p) => [
            p.name,
            p.phone,
            Money.fromPaise(p.balancePaise).formatInr(signed: true),
            p.balancePaise >= 0 ? 'You will get' : 'You have to give',
          ],
        )
        .toList();

    final net = parties.fold<int>(0, (sum, p) => sum + p.balancePaise);
    return ReportData(
      title: label,
      subtitle: businessName,
      headers: const ['Name', 'Phone', 'Balance', 'Direction'],
      rows: rows,
      summaryLines: [
        'Total parties: ${parties.length}',
        'Net balance: ${Money.fromPaise(net).formatInr(signed: true)}',
      ],
    );
  }

  ReportData _balanceReport({
    required String businessName,
    required String title,
    required List<Party> parties,
  }) {
    final rows = parties
        .map(
          (p) => [
            p.name,
            p.phone,
            Money.fromPaise(p.balancePaise.abs()).formatInr(),
          ],
        )
        .toList();
    final total = parties.fold<int>(0, (sum, p) => sum + p.balancePaise.abs());
    return ReportData(
      title: title,
      subtitle: businessName,
      headers: const ['Name', 'Phone', 'Amount'],
      rows: rows,
      summaryLines: [
        'Parties: ${parties.length}',
        'Total: ${Money.fromPaise(total).formatInr()}',
      ],
    );
  }

  ReportData _transactionLedger({
    required String businessName,
    required String title,
    required List<LedgerTransaction> transactions,
    required String Function(String partyId) nameFor,
    bool includeAudit = false,
  }) {
    final rows = transactions.map((t) {
      final base = [
        _dateFormat.format(t.occurredAt),
        nameFor(t.partyId),
        t.type.name,
        t.paymentMode.name.toUpperCase(),
        Money.fromPaise(t.amountPaise).formatInr(),
        t.note ?? '',
      ];
      if (includeAudit) {
        base.add(_dateTimeFormat.format(t.occurredAt));
      }
      return base;
    }).toList();

    final inflow = transactions
        .where((t) => t.type == TransactionType.youGot)
        .fold<int>(0, (sum, t) => sum + t.amountPaise);
    final outflow = transactions
        .where((t) => t.type == TransactionType.youGave)
        .fold<int>(0, (sum, t) => sum + t.amountPaise);

    final headers = [
      'Date',
      'Party',
      'Type',
      'Mode',
      'Amount',
      'Note',
      if (includeAudit) 'Recorded at',
    ];

    return ReportData(
      title: title,
      subtitle: businessName,
      headers: headers,
      rows: rows,
      summaryLines: [
        'Entries: ${transactions.length}',
        'You got: ${Money.fromPaise(inflow).formatInr()}',
        'You gave: ${Money.fromPaise(outflow).formatInr()}',
      ],
    );
  }

  /// Generates a PDF file for the report and returns it.
  Future<File> generatePdf(ReportData data) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            data.subtitle,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            data.title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Generated: ${_dateTimeFormat.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 16),
          if (data.rows.isEmpty)
            pw.Text('No records for this report.')
          else
            pw.TableHelper.fromTextArray(
              headers: data.headers,
              data: data.rows,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
          pw.SizedBox(height: 18),
          ...data.summaryLines.map(
            (line) => pw.Text(
              line,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    final file = await _outputFile(data.title, 'pdf');
    await file.writeAsBytes(await doc.save(), flush: true);
    return file;
  }

  /// Generates a CSV file for the report and returns it.
  Future<File> generateCsv(ReportData data) async {
    final rows = <List<dynamic>>[
      [data.subtitle],
      [data.title],
      ['Generated', _dateTimeFormat.format(DateTime.now())],
      <dynamic>[],
      data.headers,
      ...data.rows,
      <dynamic>[],
      ...data.summaryLines.map((line) => [line]),
    ];
    final csv = csv_lib.csv.encode(rows);
    final file = await _outputFile(data.title, 'csv');
    await file.writeAsString(csv, flush: true);
    return file;
  }

  Future<void> share(File file, {required bool isPdf}) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'LedgerPro report',
        files: [
          XFile(
            file.path,
            mimeType: isPdf ? 'application/pdf' : 'text/csv',
          ),
        ],
      ),
    );
  }

  Future<File> _outputFile(String title, String extension) async {
    final dir = await getTemporaryDirectory();
    final safeName = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return File('${dir.path}/ledgerpro_${safeName}_$stamp.$extension');
  }
}
