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
  static const _navy = PdfColor.fromInt(0xFF03152E);
  static const _blue = PdfColor.fromInt(0xFF1D74F5);
  static const _gold = PdfColor.fromInt(0xFFD6A83A);
  static const _green = PdfColor.fromInt(0xFF138A4A);
  static const _orange = PdfColor.fromInt(0xFFF59E0B);
  static const _red = PdfColor.fromInt(0xFFDC2626);
  static const _ink = PdfColor.fromInt(0xFF101828);
  static const _muted = PdfColor.fromInt(0xFF667085);
  static const _line = PdfColor.fromInt(0xFFE4E7EC);
  static const _soft = PdfColor.fromInt(0xFFF5F7FB);
  static const _white = PdfColor.fromInt(0xFFFFFFFF);

  Future<File> projectSummaryPdf({
    required String organizationName,
    required InfraProject project,
    required ProjectFinancialSummary summary,
    required List<ProjectInvestment> investments,
    required List<GovernmentFund> funds,
    required List<ProjectExpense> expenses,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.fromLTRB(28, 28, 28, 32),
        ),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            generatedAt: generatedAt,
          ),
          pw.SizedBox(height: 16),
          _projectPulse(project),
          pw.SizedBox(height: 16),
          _kpiGrid(summary),
          pw.SizedBox(height: 18),
          _fundingSnapshot(summary),
          pw.SizedBox(height: 20),
          _sectionTitle(
            title: 'Investor Contributions',
            subtitle: '${investments.length} investment record(s)',
            accent: _gold,
          ),
          if (investments.isEmpty)
            _emptySection('No investments recorded.')
          else
            _premiumTable(
              headers: const [
                'Investor',
                'Date',
                'Mode',
                'Reference',
                'Amount',
              ],
              rightAlignedColumns: const {4},
              rows: investments
                  .map(
                    (i) => [
                      i.investorName ?? 'Investor',
                      _formatDate(i.investmentDate),
                      _label(i.paymentMode),
                      i.referenceNumber ?? '-',
                      _inr(i.amountPaise),
                    ],
                  )
                  .toList(),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Government Funds',
            subtitle: '${funds.length} sanctioned fund record(s)',
            accent: _green,
          ),
          if (funds.isEmpty)
            _emptySection('No government funds recorded.')
          else
            _premiumTable(
              headers: const [
                'Department',
                'Scheme',
                'Status',
                'Sanctioned',
                'Received',
                'Pending',
              ],
              rightAlignedColumns: const {3, 4, 5},
              rows: funds
                  .map(
                    (f) => [
                      f.departmentName,
                      f.schemeName ?? '-',
                      _fundStatusLabel(f.status),
                      _inr(f.amountSanctionedPaise),
                      _inr(f.amountReceivedPaise),
                      _inr(f.pendingAmountPaise),
                    ],
                  )
                  .toList(),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Project Expenses',
            subtitle: '${expenses.length} expense record(s)',
            accent: _red,
          ),
          if (expenses.isEmpty)
            _emptySection('No expenses recorded.')
          else
            _premiumTable(
              headers: const [
                'Date',
                'Category',
                'Vendor',
                'Mode',
                'Bill',
                'Amount',
              ],
              rightAlignedColumns: const {5},
              rows: expenses
                  .map(
                    (e) => [
                      _formatDate(e.expenseDate),
                      e.category,
                      e.vendorName ?? '-',
                      _label(e.paymentMode),
                      e.billNumber ?? '-',
                      _inr(e.amountPaise),
                    ],
                  )
                  .toList(),
            ),
        ],
      ),
    );
    return _write(project.name, 'summary', 'pdf', await doc.save());
  }

  pw.Widget _coverHeader({
    required String organizationName,
    required InfraProject project,
    required DateTime generatedAt,
  }) {
    final orgName = organizationName.trim().isEmpty
        ? 'Navdream Infra Pvt. Ltd.'
        : organizationName.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      orgName,
                      style: pw.TextStyle(
                        color: _gold,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Project Financial Summary',
                      style: pw.TextStyle(
                        color: _white,
                        fontSize: 25,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      project.name,
                      style: pw.TextStyle(
                        color: _white,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _projectLocation(project),
                      style: const pw.TextStyle(color: _line, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: 118,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF0A2548),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFF183A63),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generated',
                      style: const pw.TextStyle(color: _line, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _dateTime.format(generatedAt),
                      style: pw.TextStyle(
                        color: _white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if ((project.code ?? '').trim().isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Project Code',
                        style: const pw.TextStyle(color: _line, fontSize: 8),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        project.code!,
                        style: pw.TextStyle(
                          color: _gold,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip(
                _projectStatusLabel(project.status),
                _projectStatusColor(project.status),
              ),
              if ((project.category ?? '').trim().isNotEmpty)
                _heroChip(project.category!, _blue),
              _heroChip(
                '${project.progressPercent.clamp(0, 100)}% complete',
                _gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _heroChip(String label, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(999),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          color: _white,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _projectPulse(InfraProject project) {
    final progress = project.progressPercent.clamp(0, 100).toInt();
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _white,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _line),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Execution Pulse',
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '$progress%',
                style: pw.TextStyle(
                  color: _blue,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          _linearBar(progress, _blue),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _miniMeta('Status', _projectStatusLabel(project.status)),
              _miniMeta('Start', _formatDate(project.startDate)),
              _miniMeta('Target', _formatDate(project.expectedEndDate)),
              _miniMeta(
                'Estimated Cost',
                _inr(project.totalEstimatedCostPaise),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _kpiGrid(ProjectFinancialSummary summary) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metricCard(
          'Investor Capital',
          _inr(summary.totalInvestmentPaise),
          _gold,
        ),
        _metricCard(
          'Govt Sanctioned',
          _inr(summary.totalGovtSanctionedPaise),
          _blue,
        ),
        _metricCard(
          'Govt Received',
          _inr(summary.totalGovtReceivedPaise),
          _green,
        ),
        _metricCard('Govt Pending', _inr(summary.pendingGovtPaise), _orange),
        _metricCard('Total Expenses', _inr(summary.totalExpensePaise), _red),
        _metricCard(
          'Available Balance',
          _inr(summary.availableBalancePaise),
          summary.availableBalancePaise >= 0 ? _green : _red,
          highlighted: true,
        ),
      ],
    );
  }

  pw.Widget _metricCard(
    String label,
    String value,
    PdfColor accent, {
    bool highlighted = false,
  }) {
    return pw.Container(
      width: 166,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: highlighted ? const PdfColor.fromInt(0xFFF8FBFF) : _white,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: highlighted ? _blue : _line, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 28,
            height: 3,
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(99),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            label,
            style: const pw.TextStyle(color: _muted, fontSize: 8.5),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _fundingSnapshot(ProjectFinancialSummary summary) {
    final totalCashIn =
        summary.totalInvestmentPaise + summary.totalGovtReceivedPaise;
    final spentPercent = totalCashIn <= 0
        ? 0
        : ((summary.totalExpensePaise / totalCashIn) * 100)
              .clamp(0, 100)
              .round();
    final availablePercent = totalCashIn <= 0
        ? 0
        : ((summary.availableBalancePaise / totalCashIn) * 100)
              .clamp(0, 100)
              .round();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Funding Health',
                style: pw.TextStyle(
                  color: _white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Cash in: ${_inr(totalCashIn)}',
                style: pw.TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Spent $spentPercent% of received funding. Available balance is $availablePercent%.',
            style: const pw.TextStyle(color: _line, fontSize: 9.5),
          ),
          pw.SizedBox(height: 12),
          _linearBar(
            spentPercent,
            _gold,
            trackColor: const PdfColor.fromInt(0xFF17395F),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle({
    required String title,
    required String subtitle,
    required PdfColor accent,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 5,
            height: 28,
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(99),
            ),
          ),
          pw.SizedBox(width: 9),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                subtitle,
                style: const pw.TextStyle(color: _muted, fontSize: 8.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _premiumTable({
    required List<String> headers,
    required List<List<String>> rows,
    Set<int> rightAlignedColumns = const {},
  }) {
    return pw.Table(
      columnWidths: {
        for (var i = 0; i < headers.length; i++)
          i: pw.FlexColumnWidth(_columnWeight(headers[i])),
      },
      border: pw.TableBorder(
        top: const pw.BorderSide(color: _line, width: 0.7),
        bottom: const pw.BorderSide(color: _line, width: 0.7),
        left: const pw.BorderSide(color: _line, width: 0.7),
        right: const pw.BorderSide(color: _line, width: 0.7),
        horizontalInside: const pw.BorderSide(color: _line, width: 0.45),
      ),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _navy),
          children: [
            for (var i = 0; i < headers.length; i++)
              _tableCell(
                headers[i],
                isHeader: true,
                alignRight: rightAlignedColumns.contains(i),
              ),
          ],
        ),
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rowIndex.isEven ? _white : _soft,
            ),
            children: [
              for (var i = 0; i < headers.length; i++)
                _tableCell(
                  i < rows[rowIndex].length ? rows[rowIndex][i] : '',
                  alignRight: rightAlignedColumns.contains(i),
                ),
            ],
          ),
      ],
    );
  }

  pw.Widget _tableCell(
    String value, {
    bool isHeader = false,
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        value,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          color: isHeader ? _white : _ink,
          fontSize: isHeader ? 8.3 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _emptySection(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _soft,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _line),
      ),
      child: pw.Text(
        message,
        style: const pw.TextStyle(color: _muted, fontSize: 9.5),
      ),
    );
  }

  pw.Widget _linearBar(
    int percent,
    PdfColor color, {
    PdfColor trackColor = _line,
  }) {
    final safePercent = percent.clamp(0, 100).toInt();
    return pw.Container(
      height: 8,
      decoration: pw.BoxDecoration(
        color: trackColor,
        borderRadius: pw.BorderRadius.circular(99),
      ),
      child: pw.Row(
        children: [
          if (safePercent > 0)
            pw.Expanded(
              flex: safePercent,
              child: pw.Container(
                height: 8,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(99),
                ),
              ),
            ),
          if (safePercent < 100)
            pw.Expanded(flex: 100 - safePercent, child: pw.SizedBox(height: 8)),
        ],
      ),
    );
  }

  pw.Widget _miniMeta(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: _muted, fontSize: 8)),
          pw.SizedBox(height: 3),
          pw.Text(
            value.isEmpty ? '-' : value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context context, DateTime generatedAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Navdream Infra financial report | ${_dateTime.format(generatedAt)}',
              style: const pw.TextStyle(color: _muted, fontSize: 8),
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  double _columnWeight(String header) {
    final normalized = header.toLowerCase();
    if (normalized.contains('department') ||
        normalized.contains('investor') ||
        normalized.contains('category') ||
        normalized.contains('vendor') ||
        normalized.contains('scheme')) {
      return 1.45;
    }
    if (normalized.contains('amount') ||
        normalized.contains('sanctioned') ||
        normalized.contains('received') ||
        normalized.contains('pending')) {
      return 1.15;
    }
    if (normalized.contains('date') ||
        normalized.contains('mode') ||
        normalized.contains('bill') ||
        normalized.contains('status')) {
      return 0.9;
    }
    return 1;
  }

  PdfColor _projectStatusColor(InfraProjectStatus status) => switch (status) {
    InfraProjectStatus.active => _green,
    InfraProjectStatus.completed => _blue,
    InfraProjectStatus.onHold => _orange,
    InfraProjectStatus.cancelled => _red,
    InfraProjectStatus.planning => _muted,
  };

  String _projectStatusLabel(InfraProjectStatus status) => switch (status) {
    InfraProjectStatus.planning => 'Planning',
    InfraProjectStatus.active => 'Active',
    InfraProjectStatus.onHold => 'On Hold',
    InfraProjectStatus.completed => 'Completed',
    InfraProjectStatus.cancelled => 'Cancelled',
  };

  String _fundStatusLabel(GovtFundStatus status) => switch (status) {
    GovtFundStatus.sanctioned => 'Sanctioned',
    GovtFundStatus.partiallyReceived => 'Partially Received',
    GovtFundStatus.fullyReceived => 'Fully Received',
    GovtFundStatus.delayed => 'Delayed',
    GovtFundStatus.cancelled => 'Cancelled',
  };

  String _projectLocation(InfraProject project) {
    final cityState = [
      project.locationCity,
      project.locationState,
    ].where((part) => (part ?? '').trim().isNotEmpty).join(', ');
    if (cityState.isNotEmpty) return cityState;
    if ((project.address ?? '').trim().isNotEmpty) return project.address!;
    return 'Location not set';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return _date.format(value);
  }

  String _label(String value) {
    return value
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
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
      ...expenses.map(
        (e) => [
          e.expenseDate == null ? '' : _date.format(e.expenseDate!),
          e.category,
          e.vendorName ?? '',
          e.paymentMode,
          e.billNumber ?? '',
          (e.amountPaise / 100).toStringAsFixed(2),
        ],
      ),
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
      ...investments.map(
        (i) => [
          i.investorName ?? 'Investor',
          i.investmentDate == null ? '' : _date.format(i.investmentDate!),
          i.paymentMode,
          i.referenceNumber ?? '',
          (i.amountPaise / 100).toStringAsFixed(2),
        ],
      ),
    ];
    final content = csv_lib.csv.encode(rows);
    return _write(project.name, 'investors', 'csv', content);
  }

  Future<void> share(File file, {required bool isPdf}) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'Navdream Infra Pvt. Ltd. report',
        files: [
          XFile(file.path, mimeType: isPdf ? 'application/pdf' : 'text/csv'),
        ],
      ),
    );
  }

  static String _inr(int paise) {
    return Money.fromPaise(paise).formatInr().replaceFirst('₹', 'INR ');
  }

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
    final file = File('${dir.path}/navdreaminfra_${safe}_${kind}_$stamp.$ext');
    if (content is String) {
      await file.writeAsString(content, flush: true);
    } else {
      await file.writeAsBytes(content as List<int>, flush: true);
    }
    return file;
  }
}
