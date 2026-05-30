import 'dart:io';

import 'package:csv/csv.dart' as csv_lib;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/money/money.dart';
import '../../../shared/models/infra_models.dart';

/// Generates project finance reports (PDF + CSV) from real data.
class InfraReportService {
  const InfraReportService();

  static final _dateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final _date = DateFormat('yyyy-MM-dd');

  Future<File> projectSummaryPdf({
    required String organizationName,
    required InfraProject project,
    required ProjectFinancialSummary summary,
    required List<ProjectInvestment> investments,
    required List<GovernmentFund> funds,
    required List<ProjectExpense> expenses,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(organizationName,
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text('Project Financial Summary',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(project.name,
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.Text('Generated: ${_dateTime.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: const ['Metric', 'Amount'],
            data: [
              ['Total Investment', _inr(summary.totalInvestmentPaise)],
              ['Govt Sanctioned', _inr(summary.totalGovtSanctionedPaise)],
              ['Govt Received', _inr(summary.totalGovtReceivedPaise)],
              ['Govt Pending', _inr(summary.pendingGovtPaise)],
              ['Total Expenses', _inr(summary.totalExpensePaise)],
              ['Available Balance', _inr(summary.availableBalancePaise)],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Investments',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (investments.isEmpty)
            pw.Text('No investments recorded.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Investor', 'Date', 'Amount'],
              data: investments
                  .map((i) => [
                        i.investorName ?? 'Investor',
                        i.investmentDate == null
                            ? ''
                            : _date.format(i.investmentDate!),
                        _inr(i.amountPaise),
                      ])
                  .toList(),
            ),
          pw.SizedBox(height: 16),
          pw.Text('Government Funds',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (funds.isEmpty)
            pw.Text('No government funds recorded.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Department', 'Sanctioned', 'Received', 'Pending'],
              data: funds
                  .map((f) => [
                        f.departmentName,
                        _inr(f.amountSanctionedPaise),
                        _inr(f.amountReceivedPaise),
                        _inr(f.pendingAmountPaise),
                      ])
                  .toList(),
            ),
          pw.SizedBox(height: 16),
          pw.Text('Expenses',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (expenses.isEmpty)
            pw.Text('No expenses recorded.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Date', 'Category', 'Vendor', 'Amount'],
              data: expenses
                  .map((e) => [
                        e.expenseDate == null
                            ? ''
                            : _date.format(e.expenseDate!),
                        e.category,
                        e.vendorName ?? '',
                        _inr(e.amountPaise),
                      ])
                  .toList(),
            ),
        ],
      ),
    );
    return _write(project.name, 'summary', 'pdf', await doc.save());
  }

  Future<File> expensesCsv({
    required InfraProject project,
    required List<ProjectExpense> expenses,
  }) async {
    final rows = <List<dynamic>>[
      ['Project', project.name],
      ['Generated', _dateTime.format(DateTime.now())],
      <dynamic>[],
      ['Date', 'Category', 'Vendor', 'Payment Mode', 'Bill No', 'Amount (INR)'],
      ...expenses.map((e) => [
            e.expenseDate == null ? '' : _date.format(e.expenseDate!),
            e.category,
            e.vendorName ?? '',
            e.paymentMode,
            e.billNumber ?? '',
            (e.amountPaise / 100).toStringAsFixed(2),
          ]),
    ];
    final content = csv_lib.csv.encode(rows);
    return _write(project.name, 'expenses', 'csv', content);
  }

  Future<File> investorsCsv({
    required InfraProject project,
    required List<ProjectInvestment> investments,
  }) async {
    final rows = <List<dynamic>>[
      ['Project', project.name],
      ['Generated', _dateTime.format(DateTime.now())],
      <dynamic>[],
      ['Investor', 'Date', 'Payment Mode', 'Reference', 'Amount (INR)'],
      ...investments.map((i) => [
            i.investorName ?? 'Investor',
            i.investmentDate == null ? '' : _date.format(i.investmentDate!),
            i.paymentMode,
            i.referenceNumber ?? '',
            (i.amountPaise / 100).toStringAsFixed(2),
          ]),
    ];
    final content = csv_lib.csv.encode(rows);
    return _write(project.name, 'investors', 'csv', content);
  }

  Future<void> share(File file, {required bool isPdf}) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'Royal Infra report',
        files: [
          XFile(file.path, mimeType: isPdf ? 'application/pdf' : 'text/csv'),
        ],
      ),
    );
  }

  static String _inr(int paise) => Money.fromPaise(paise).formatInr();

  Future<File> _write(
    String projectName,
    String kind,
    String ext,
    dynamic content,
  ) async {
    final dir = await getTemporaryDirectory();
    final safe = projectName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/royalinfra_${safe}_${kind}_$stamp.$ext');
    if (content is String) {
      await file.writeAsString(content, flush: true);
    } else {
      await file.writeAsBytes(content as List<int>, flush: true);
    }
    return file;
  }
}
