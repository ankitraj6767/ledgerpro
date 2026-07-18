import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/money/money.dart';
import '../../../core/richtext/rich_text_document.dart';
import '../../../shared/models/infra_models.dart';

/// Generates project finance reports from real data.
class InfraReportService {
  const InfraReportService();

  static final _dateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final _date = DateFormat('yyyy-MM-dd');
  static const _blue = PdfColor.fromInt(0xFF0A4F9E);
  static const _gold = PdfColor.fromInt(0xFFE59B12);
  static const _green = PdfColor.fromInt(0xFF15803D);
  static const _orange = PdfColor.fromInt(0xFFF97316);
  static const _red = PdfColor.fromInt(0xFFB42318);
  static const _navy = PdfColor.fromInt(0xFF051B36);
  static const _ink = PdfColor.fromInt(0xFF111827);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFD7DEE8);
  static const _soft = PdfColor.fromInt(0xFFF6F8FB);
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
    final logo = await _loadLogo();
    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            reportTitle: 'Project Financial Summary',
            generatedAt: generatedAt,
            logo: logo,
          ),
          pw.SizedBox(height: 16),
          _projectPulse(project),
          pw.SizedBox(height: 16),
          if (!richTextIsEmpty(project.description)) ...[
            _richTextSection(
              title: 'Project Description',
              accent: _blue,
              markdown: project.description,
            )!,
            pw.SizedBox(height: 16),
          ],
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
              headers: const ['S.No', 'Date', 'Category', 'Notes', 'Amount'],
              rightAlignedColumns: const {4},
              rows: [
                for (var i = 0; i < expenses.length; i++)
                  [
                    '${i + 1}',
                    _formatDate(expenses[i].expenseDate),
                    expenses[i].category,
                    _plainNotes(expenses[i].notes),
                    _inr(expenses[i].amountPaise),
                  ],
              ],
            ),
        ],
      ),
    );
    return _write(project.name, 'summary', 'pdf', await doc.save());
  }

  Future<File> investorsPdf({
    required String organizationName,
    required InfraProject project,
    required List<ProjectInvestment> investments,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final logo = await _loadLogo();
    final sorted = [...investments]
      ..sort((a, b) => _compareDateDesc(a.investmentDate, b.investmentDate));
    final total = sorted.fold<int>(0, (sum, item) => sum + item.amountPaise);
    final uniqueInvestors = sorted
        .map((item) => (item.investorName ?? item.investorId).trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;

    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            reportTitle: 'Investor Contribution Report',
            generatedAt: generatedAt,
            logo: logo,
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard('Total Investment', _inr(total), _gold),
              _metricCard('Investment Records', '${sorted.length}', _blue),
              _metricCard('Investor Names', '$uniqueInvestors', _green),
              _metricCard(
                'Latest Contribution',
                _formatDate(_latestDate(sorted.map((e) => e.investmentDate))),
                _orange,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Investor Breakdown',
            subtitle: 'Contribution totals grouped by investor',
            accent: _gold,
          ),
          if (sorted.isEmpty)
            _emptySection('No investments recorded.')
          else
            _premiumTable(
              headers: const ['Investor', 'Records', 'Total Amount', 'Share'],
              rightAlignedColumns: const {1, 2, 3},
              rows: _investmentBreakdownRows(sorted, total),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Investment Ledger',
            subtitle: '${sorted.length} investment transaction(s)',
            accent: _blue,
          ),
          if (sorted.isEmpty)
            _emptySection('No investment transactions available.')
          else
            _premiumTable(
              headers: const [
                'Investor',
                'Date',
                'Mode',
                'Reference',
                'Notes',
                'Amount',
              ],
              rightAlignedColumns: const {5},
              rows: sorted
                  .map(
                    (item) => [
                      item.investorName ?? 'Investor',
                      _formatDate(item.investmentDate),
                      _label(item.paymentMode),
                      _present(item.referenceNumber),
                      _plainNotes(item.notes),
                      _inr(item.amountPaise),
                    ],
                  )
                  .toList(),
            ),
        ],
      ),
    );
    return _write(project.name, 'investors', 'pdf', await doc.save());
  }

  Future<File> investorStatementPdf({
    required String organizationName,
    required InfraProject project,
    required String investorName,
    required List<ProjectInvestment> investments,
    required List<InvestmentReturn> returns,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final logo = await _loadLogo();

    final sortedInvestments = [...investments]
      ..sort((a, b) => _compareDateDesc(a.investmentDate, b.investmentDate));
    final sortedReturns = [...returns]
      ..sort((a, b) => _compareDateDesc(a.returnDate, b.returnDate));

    final totalInvested = sortedInvestments.fold<int>(
      0,
      (sum, item) => sum + item.amountPaise,
    );
    final totalReturned = sortedReturns.fold<int>(
      0,
      (sum, item) => sum + item.amountPaise,
    );
    final netInvestment = totalInvested - totalReturned;
    final safeInvestorName =
        investorName.trim().isEmpty ? 'Investor' : investorName.trim();

    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            reportTitle: 'Investor Statement',
            generatedAt: generatedAt,
            logo: logo,
          ),
          pw.SizedBox(height: 16),
          _sectionTitle(
            title: safeInvestorName,
            subtitle: 'Investor account statement',
            accent: _blue,
          ),
          pw.SizedBox(height: 4),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard('Total Invested', _inr(totalInvested), _gold),
              _metricCard('Total Returned', _inr(totalReturned), _red),
              _metricCard(
                'Net Investment',
                _inr(netInvestment),
                netInvestment >= 0 ? _green : _red,
                highlighted: true,
              ),
              _metricCard(
                'Latest Activity',
                _formatDate(
                  _latestDate([
                    ...sortedInvestments.map((e) => e.investmentDate),
                    ...sortedReturns.map((e) => e.returnDate),
                  ]),
                ),
                _orange,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Investment Ledger',
            subtitle: '${sortedInvestments.length} investment record(s)',
            accent: _gold,
          ),
          if (sortedInvestments.isEmpty)
            _emptySection('No investments recorded for this investor.')
          else
            _premiumTable(
              headers: const ['Date', 'Mode', 'Reference', 'Notes', 'Amount'],
              rightAlignedColumns: const {4},
              rows: sortedInvestments
                  .map(
                    (item) => [
                      _formatDate(item.investmentDate),
                      _label(item.paymentMode),
                      _present(item.referenceNumber),
                      _plainNotes(item.notes),
                      _inr(item.amountPaise),
                    ],
                  )
                  .toList(),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Returns Ledger',
            subtitle: '${sortedReturns.length} return record(s)',
            accent: _red,
          ),
          if (sortedReturns.isEmpty)
            _emptySection('No returns recorded for this investor.')
          else
            _premiumTable(
              headers: const ['Date', 'Mode', 'Reference', 'Notes', 'Amount'],
              rightAlignedColumns: const {4},
              rows: sortedReturns
                  .map(
                    (item) => [
                      _formatDate(item.returnDate),
                      _label(item.paymentMode),
                      _present(item.referenceNumber),
                      _plainNotes(item.notes),
                      _inr(item.amountPaise),
                    ],
                  )
                  .toList(),
            ),
        ],
      ),
    );

    return _write(project.name, 'investor_statement', 'pdf', await doc.save());
  }

  Future<File> expensesPdf({
    required String organizationName,
    required InfraProject project,
    required List<ProjectExpense> expenses,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final logo = await _loadLogo();
    final sorted = [...expenses]
      ..sort((a, b) => _compareDateDesc(a.expenseDate, b.expenseDate));
    final total = sorted.fold<int>(0, (sum, item) => sum + item.amountPaise);

    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            reportTitle: 'Expense Report',
            generatedAt: generatedAt,
            logo: logo,
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard('Total Expenses', _inr(total), _red),
              _metricCard('Expense Records', '${sorted.length}', _blue),
              _metricCard(
                'Categories Used',
                '${sorted.map((e) => e.category).toSet().length}',
                _gold,
              ),
              _metricCard(
                'Latest Expense',
                _formatDate(_latestDate(sorted.map((e) => e.expenseDate))),
                _orange,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Category Breakdown',
            subtitle: 'Expense distribution by category',
            accent: _red,
          ),
          if (sorted.isEmpty)
            _emptySection('No expenses recorded.')
          else
            _premiumTable(
              headers: const ['Category', 'Records', 'Total Amount', 'Share'],
              rightAlignedColumns: const {1, 2, 3},
              rows: _expenseBreakdownRows(sorted, total),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Expense Ledger',
            subtitle: '${sorted.length} expense transaction(s)',
            accent: _blue,
          ),
          if (sorted.isEmpty)
            _emptySection('No expense transactions available.')
          else
            _premiumTable(
              headers: const ['S.No', 'Date', 'Category', 'Notes', 'Amount'],
              rightAlignedColumns: const {4},
              rows: [
                for (var i = 0; i < sorted.length; i++)
                  [
                    '${i + 1}',
                    _formatDate(sorted[i].expenseDate),
                    sorted[i].category,
                    _plainNotes(sorted[i].notes),
                    _inr(sorted[i].amountPaise),
                  ],
              ],
            ),
        ],
      ),
    );
    return _write(project.name, 'expenses', 'pdf', await doc.save());
  }

  Future<File> governmentFundsPdf({
    required String organizationName,
    required InfraProject project,
    required List<GovernmentFund> funds,
    Map<String, List<GovernmentFundReceipt>> receiptsByFundId = const {},
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final logo = await _loadLogo();
    final sorted = [...funds]
      ..sort((a, b) => _compareDateDesc(a.sanctionDate, b.sanctionDate));
    final receipts = [
      for (final fund in sorted)
        ...(receiptsByFundId[fund.id] ?? const <GovernmentFundReceipt>[]),
    ]..sort((a, b) => _compareDateDesc(a.receivedDate, b.receivedDate));
    final sanctioned = sorted.fold<int>(
      0,
      (sum, item) => sum + item.amountSanctionedPaise,
    );
    final received = sorted.fold<int>(
      0,
      (sum, item) => sum + item.amountReceivedPaise,
    );
    final pending = sorted.fold<int>(
      0,
      (sum, item) => sum + item.pendingAmountPaise,
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            reportTitle: 'Government Funds Report',
            generatedAt: generatedAt,
            logo: logo,
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard('Total Sanctioned', _inr(sanctioned), _blue),
              _metricCard('Total Received', _inr(received), _green),
              _metricCard('Pending Balance', _inr(pending), _orange),
              _metricCard('Fund Records', '${sorted.length}', _gold),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Sanction Register',
            subtitle: '${sorted.length} government fund record(s)',
            accent: _green,
          ),
          if (sorted.isEmpty)
            _emptySection('No government funds recorded.')
          else
            _premiumTable(
              headers: const [
                'Department',
                'Scheme',
                'Order No.',
                'Status',
                'Sanctioned',
                'Received',
                'Pending',
              ],
              rightAlignedColumns: const {4, 5, 6},
              rows: sorted
                  .map(
                    (item) => [
                      item.departmentName,
                      _present(item.schemeName),
                      _present(item.sanctionOrderNumber),
                      _fundStatusLabel(item.status),
                      _inr(item.amountSanctionedPaise),
                      _inr(item.amountReceivedPaise),
                      _inr(item.pendingAmountPaise),
                    ],
                  )
                  .toList(),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle(
            title: 'Receipt Ledger',
            subtitle: '${receipts.length} receipt transaction(s)',
            accent: _blue,
          ),
          if (receipts.isEmpty)
            _emptySection('No receipt transactions recorded.')
          else
            _premiumTable(
              headers: const [
                'Department',
                'Date',
                'Mode',
                'Reference',
                'Amount',
              ],
              rightAlignedColumns: const {4},
              rows: receipts
                  .map(
                    (receipt) => [
                      _fundDepartment(sorted, receipt.governmentFundId),
                      _formatDate(receipt.receivedDate),
                      _label(receipt.paymentMode),
                      _present(receipt.referenceNumber),
                      _inr(receipt.amountPaise),
                    ],
                  )
                  .toList(),
            ),
        ],
      ),
    );
    return _write(project.name, 'government_funds', 'pdf', await doc.save());
  }

  Future<File> investmentDetailPdf({
    required String organizationName,
    required InfraProject project,
    required ProjectInvestment investment,
  }) {
    final investorName = _present(investment.investorName) == '-'
        ? 'Investor'
        : investment.investorName!.trim();
    return _recordPdf(
      organizationName: organizationName,
      project: project,
      reportTitle: 'Investor Contribution Detail',
      kind: 'investment_${investment.id}',
      metrics: [
        _PdfMetric('Investment Amount', _inr(investment.amountPaise), _gold),
        _PdfMetric('Investor', investorName, _blue),
        _PdfMetric('Payment Mode', _label(investment.paymentMode), _green),
        _PdfMetric(
          'Investment Date',
          _formatDate(investment.investmentDate),
          _orange,
        ),
      ],
      sections: [
        _PdfDetailSection(
          title: 'Investment Details',
          accent: _gold,
          rows: [
            ['Investor', investorName],
            ['Investment Date', _formatDate(investment.investmentDate)],
            ['Payment Mode', _label(investment.paymentMode)],
            ['Reference Number', _present(investment.referenceNumber)],
          ],
        ),
        _PdfDetailSection(
          title: 'Record',
          accent: _blue,
          rows: [
            ['Created', _formatDateTime(investment.createdAt)],
            ['Updated', _formatDateTime(investment.updatedAt)],
          ],
        ),
      ],
      extraWidgets: _notesExtra(investment.notes, _gold),
    );
  }

  Future<File> investmentReturnDetailPdf({
    required String organizationName,
    required InfraProject project,
    required InvestmentReturn entry,
  }) {
    final investorName = _present(entry.investorName) == '-'
        ? 'Investor'
        : entry.investorName!.trim();
    return _recordPdf(
      organizationName: organizationName,
      project: project,
      reportTitle: 'Investor Return Detail',
      kind: 'investment_return_${entry.id}',
      metrics: [
        _PdfMetric('Return Amount', _inr(entry.amountPaise), _red),
        _PdfMetric('Investor', investorName, _blue),
        _PdfMetric('Payment Mode', _label(entry.paymentMode), _green),
        _PdfMetric('Return Date', _formatDate(entry.returnDate), _orange),
      ],
      sections: [
        _PdfDetailSection(
          title: 'Return Details',
          accent: _red,
          rows: [
            ['Investor', investorName],
            ['Return Date', _formatDate(entry.returnDate)],
            ['Payment Mode', _label(entry.paymentMode)],
            ['Reference Number', _present(entry.referenceNumber)],
          ],
        ),
        _PdfDetailSection(
          title: 'Record',
          accent: _blue,
          rows: [
            ['Created', _formatDateTime(entry.createdAt)],
            ['Updated', _formatDateTime(entry.updatedAt)],
          ],
        ),
      ],
      extraWidgets: _notesExtra(entry.notes, _red),
    );
  }

  Future<File> expenseDetailPdf({
    required String organizationName,
    required InfraProject project,
    required ProjectExpense expense,
  }) {
    return _recordPdf(
      organizationName: organizationName,
      project: project,
      reportTitle: 'Expense Detail',
      kind: 'expense_${expense.id}',
      metrics: [
        _PdfMetric('Expense Amount', _inr(expense.amountPaise), _red),
        _PdfMetric('Category', expense.category, _blue),
        _PdfMetric('Payment Mode', _label(expense.paymentMode), _gold),
        _PdfMetric('Expense Date', _formatDate(expense.expenseDate), _orange),
      ],
      sections: [
        _PdfDetailSection(
          title: 'Expense Details',
          accent: _red,
          rows: [
            ['Category', expense.category],
            ['Expense Date', _formatDate(expense.expenseDate)],
            ['Payment Mode', _label(expense.paymentMode)],
            ['Created By', _present(expense.createdBy)],
          ],
        ),
        _PdfDetailSection(
          title: 'Record',
          accent: _blue,
          rows: [
            ['Created', _formatDateTime(expense.createdAt)],
            ['Updated', _formatDateTime(expense.updatedAt)],
          ],
        ),
      ],
      extraWidgets: _notesExtra(expense.notes, _red),
    );
  }

  Future<File> governmentFundDetailPdf({
    required String organizationName,
    required InfraProject project,
    required GovernmentFund fund,
    List<GovernmentFundReceipt> receipts = const [],
  }) {
    final receivedPercent = _percentOf(
      fund.amountReceivedPaise,
      fund.amountSanctionedPaise,
    );
    final sortedReceipts = [...receipts]
      ..sort((a, b) => _compareDateDesc(a.receivedDate, b.receivedDate));
    return _recordPdf(
      organizationName: organizationName,
      project: project,
      reportTitle: 'Government Fund Detail',
      kind: 'government_fund_${fund.id}',
      metrics: [
        _PdfMetric(
          'Sanctioned Amount',
          _inr(fund.amountSanctionedPaise),
          _green,
        ),
        _PdfMetric('Received Amount', _inr(fund.amountReceivedPaise), _blue),
        _PdfMetric('Pending Amount', _inr(fund.pendingAmountPaise), _orange),
        _PdfMetric('Received %', receivedPercent, _gold),
      ],
      sections: [
        _PdfDetailSection(
          title: 'Fund Details',
          accent: _green,
          rows: [
            ['Department', fund.departmentName],
            ['Scheme', _present(fund.schemeName)],
            ['Status', _fundStatusLabel(fund.status)],
            ['Sanction Order', _present(fund.sanctionOrderNumber)],
            ['Sanction Date', _formatDate(fund.sanctionDate)],
            ['Last Received', _formatDate(fund.lastReceivedDate)],
            ['Document', _present(fund.documentPath)],
          ],
        ),
        _PdfDetailSection(
          title: 'Money Movement',
          accent: _orange,
          rows: [
            ['Sanctioned', _inr(fund.amountSanctionedPaise)],
            ['Received', _inr(fund.amountReceivedPaise)],
            ['Pending', _inr(fund.pendingAmountPaise)],
          ],
        ),
        _PdfDetailSection(
          title: 'Record',
          accent: _blue,
          rows: [
            ['Created', _formatDateTime(fund.createdAt)],
            ['Updated', _formatDateTime(fund.updatedAt)],
          ],
        ),
      ],
      extraWidgets: [
        ..._notesExtra(fund.notes, _green),
        pw.SizedBox(height: 16),
        _sectionTitle(
          title: 'Receipt Ledger',
          subtitle: '${sortedReceipts.length} receipt transaction(s)',
          accent: _blue,
        ),
        if (sortedReceipts.isEmpty)
          _emptySection('No receipt transactions recorded.')
        else
          _premiumTable(
            headers: const ['Date', 'Mode', 'Reference', 'Notes', 'Amount'],
            rightAlignedColumns: const {4},
            rows: sortedReceipts
                .map(
                  (receipt) => [
                    _formatDate(receipt.receivedDate),
                    _label(receipt.paymentMode),
                    _present(receipt.referenceNumber),
                    _plainNotes(receipt.notes),
                    _inr(receipt.amountPaise),
                  ],
                )
                .toList(),
          ),
      ],
    );
  }

  Future<File> _recordPdf({
    required String organizationName,
    required InfraProject project,
    required String reportTitle,
    required String kind,
    required List<_PdfMetric> metrics,
    required List<_PdfDetailSection> sections,
    List<pw.Widget> extraWidgets = const [],
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final logo = await _loadLogo();

    doc.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => _footer(context, generatedAt),
        build: (context) => [
          _coverHeader(
            organizationName: organizationName,
            project: project,
            reportTitle: reportTitle,
            generatedAt: generatedAt,
            logo: logo,
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final metric in metrics)
                _metricCard(metric.label, metric.value, metric.accent),
            ],
          ),
          pw.SizedBox(height: 18),
          for (final section in sections) ...[
            _sectionTitle(
              title: section.title,
              subtitle: '${section.rows.length} field(s)',
              accent: section.accent,
            ),
            _premiumTable(
              headers: const ['Field', 'Value'],
              rows: section.rows,
            ),
            pw.SizedBox(height: 16),
          ],
          ...extraWidgets,
        ],
      ),
    );

    return _write(project.name, kind, 'pdf', await doc.save());
  }

  pw.Widget _coverHeader({
    required String organizationName,
    required InfraProject project,
    required String reportTitle,
    required DateTime generatedAt,
    required pw.MemoryImage? logo,
  }) {
    final orgName = organizationName.trim().isEmpty
        ? 'NAVDREAM Infra Pvt. Ltd.'
        : organizationName.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _navy,
        border: pw.Border.all(color: _navy, width: 1),
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
                    pw.Row(
                      children: [
                        if (logo != null) ...[
                          // Clip the logo to a rounded square so the opaque
                          // corners baked into the PNG don't show as white
                          // squares against the navy header.
                          pw.ClipRRect(
                            horizontalRadius: 13,
                            verticalRadius: 13,
                            child: pw.SizedBox(
                              width: 44,
                              height: 44,
                              child: pw.Image(logo, fit: pw.BoxFit.cover),
                            ),
                          ),
                          pw.SizedBox(width: 10),
                        ],
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'NAVDREAM',
                              style: pw.TextStyle(
                                color: _white,
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            pw.Text(
                              'INFRA PVT LTD',
                              style: pw.TextStyle(
                                color: _gold,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 14),
                    pw.Text(
                      orgName,
                      style: pw.TextStyle(
                        color: _white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      reportTitle,
                      style: pw.TextStyle(
                        color: _white,
                        fontSize: 23,
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
                      style: const pw.TextStyle(color: _soft, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: 118,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _white,
                  border: pw.Border.all(color: _line, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generated',
                      style: const pw.TextStyle(color: _ink, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _dateTime.format(generatedAt),
                      style: pw.TextStyle(
                        color: _ink,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if ((project.code ?? '').trim().isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Project Code',
                        style: const pw.TextStyle(color: _ink, fontSize: 8),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        project.code!,
                        style: pw.TextStyle(
                          color: _ink,
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
                '${project.financialProgressPercent}% complete',
                _gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('assets/branding/navdream_logo.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 32),
      buildBackground: (context) => pw.Container(color: _white),
    );
  }

  pw.Widget _heroChip(String label, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _white,
        border: pw.Border.all(color: color),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          color: _ink,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _projectPulse(InfraProject project) {
    final progress = project.financialProgressPercent;
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _white,
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
          'Net Investor Capital',
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
        color: _white,
        border: pw.Border.all(color: highlighted ? _blue : _line, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(width: 28, height: 3, color: accent),
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
        color: _white,
        border: pw.Border.all(color: _line, width: 1),
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
                  color: _ink,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Cash in: ${_inr(totalCashIn)}',
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Spent $spentPercent% of received funding. Available balance is $availablePercent%.',
            style: const pw.TextStyle(color: _ink, fontSize: 9.5),
          ),
          pw.SizedBox(height: 12),
          _linearBar(spentPercent, _gold),
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
          pw.Container(width: 5, height: 28, color: accent),
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

  /// Renders a rich-text (Markdown subset) value as a titled, bordered block
  /// so notes/descriptions appear in reports with the same formatting
  /// (headings, bold, italic, lists, quotes, links) the user applied in the
  /// app. Returns null when there is nothing to render.
  pw.Widget? _richTextSection({
    required String title,
    required PdfColor accent,
    required String? markdown,
  }) {
    final blocks = parseRichText(markdown);
    if (blocks.isEmpty) return null;
    final children = <pw.Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) children.add(pw.SizedBox(height: 5));
      children.add(_richBlock(blocks[i]));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title: title, subtitle: 'Formatted notes', accent: accent),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _white,
            border: pw.Border.all(color: _line),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  pw.Widget _richBlock(RtBlock block) {
    switch (block.type) {
      case RtBlockType.h1:
        return pw.RichText(text: _richInline(block.spans, size: 15, bold: true));
      case RtBlockType.h2:
        return pw.RichText(text: _richInline(block.spans, size: 13, bold: true));
      case RtBlockType.h3:
        return pw.RichText(text: _richInline(block.spans, size: 11, bold: true));
      case RtBlockType.bullet:
        return _richListItem(block, '•  ');
      case RtBlockType.ordered:
        return _richListItem(block, '${block.orderedNumber ?? 1}.  ');
      case RtBlockType.quote:
        return pw.Container(
          padding: const pw.EdgeInsets.only(left: 10, top: 3, bottom: 3),
          decoration: const pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: _line, width: 3)),
          ),
          child: pw.RichText(text: _richInline(block.spans, italic: true, color: _muted)),
        );
      case RtBlockType.paragraph:
        return pw.RichText(text: _richInline(block.spans));
    }
  }

  pw.Widget _richListItem(RtBlock block, String marker) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          marker,
          style: pw.TextStyle(color: _ink, fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.Expanded(child: pw.RichText(text: _richInline(block.spans))),
      ],
    );
  }

  pw.TextSpan _richInline(
    List<RtSpan> spans, {
    double size = 9.5,
    bool bold = false,
    bool italic = false,
    PdfColor color = _ink,
  }) {
    return pw.TextSpan(
      children: spans.map((span) {
        final isLink = span.link != null;
        return pw.TextSpan(
          text: span.text,
          style: pw.TextStyle(
            color: isLink ? _blue : color,
            fontSize: size,
            fontWeight: (bold || span.bold) ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontStyle: (italic || span.italic)
                ? pw.FontStyle.italic
                : pw.FontStyle.normal,
            decoration: isLink ? pw.TextDecoration.underline : pw.TextDecoration.none,
          ),
        );
      }).toList(),
    );
  }

  /// Extra widget list holding a formatted "Notes" block, or empty when there
  /// are no notes. Appended after the detail sections in [_recordPdf].
  List<pw.Widget> _notesExtra(String? markdown, PdfColor accent) {
    final section = _richTextSection(
      title: 'Notes',
      accent: accent,
      markdown: markdown,
    );
    return section == null ? const [] : [section];
  }

  /// Plain, marker-stripped form of rich text for compact table cells.
  String _plainNotes(String? markdown) => _present(richTextToPlain(markdown));

  pw.Widget _emptySection(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _soft,
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
        color: _soft,
        border: pw.Border.all(color: trackColor, width: 0.7),
      ),
      child: pw.Row(
        children: [
          if (safePercent > 0)
            pw.Expanded(
              flex: safePercent,
              child: pw.Container(height: 8, color: color),
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
              'NAVDREAM financial report | ${_dateTime.format(generatedAt)}',
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
    if (normalized.contains('s.no') ||
        normalized.contains('date') ||
        normalized.contains('mode') ||
        normalized.contains('bill') ||
        normalized.contains('status')) {
      return normalized.contains('s.no') ? 0.5 : 0.9;
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

  List<List<String>> _investmentBreakdownRows(
    List<ProjectInvestment> investments,
    int totalPaise,
  ) {
    final buckets = <String, List<int>>{};
    for (final item in investments) {
      final name = _present(item.investorName) == '-'
          ? 'Investor'
          : item.investorName!.trim();
      final bucket = buckets.putIfAbsent(name, () => [0, 0]);
      bucket[0] += 1;
      bucket[1] += item.amountPaise;
    }
    final entries = buckets.entries.toList()
      ..sort((a, b) => b.value[1].compareTo(a.value[1]));
    return entries
        .map(
          (entry) => [
            entry.key,
            '${entry.value[0]}',
            _inr(entry.value[1]),
            _percentOf(entry.value[1], totalPaise),
          ],
        )
        .toList();
  }

  List<List<String>> _expenseBreakdownRows(
    List<ProjectExpense> expenses,
    int totalPaise,
  ) {
    final buckets = <String, List<int>>{};
    for (final item in expenses) {
      final category = item.category.trim().isEmpty
          ? 'Miscellaneous'
          : item.category.trim();
      final bucket = buckets.putIfAbsent(category, () => [0, 0]);
      bucket[0] += 1;
      bucket[1] += item.amountPaise;
    }
    final entries = buckets.entries.toList()
      ..sort((a, b) => b.value[1].compareTo(a.value[1]));
    return entries
        .map(
          (entry) => [
            entry.key,
            '${entry.value[0]}',
            _inr(entry.value[1]),
            _percentOf(entry.value[1], totalPaise),
          ],
        )
        .toList();
  }

  String _fundDepartment(List<GovernmentFund> funds, String fundId) {
    for (final fund in funds) {
      if (fund.id == fundId) return fund.departmentName;
    }
    return 'Government fund';
  }

  DateTime? _latestDate(Iterable<DateTime?> values) {
    DateTime? latest;
    for (final value in values) {
      if (value == null) continue;
      if (latest == null || value.isAfter(latest)) latest = value;
    }
    return latest;
  }

  int _compareDateDesc(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  String _percentOf(int part, int total) {
    if (total <= 0) return '0%';
    final percent = (part / total) * 100;
    return '${percent.toStringAsFixed(percent >= 10 ? 0 : 1)}%';
  }

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

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return _dateTime.format(value);
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

  String _present(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '-' : trimmed;
  }

  Future<void> share(File file, {required bool isPdf}) async {
    if (_isDesktop) {
      await _revealInFileManager(file);
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        title: 'NAVDREAM report',
        files: [
          XFile(file.path, mimeType: isPdf ? 'application/pdf' : 'text/csv'),
        ],
      ),
    );
  }

  bool get _isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<void> _revealInFileManager(File file) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', ['-R', file.path]);
        return;
      }
      if (Platform.isWindows) {
        await Process.run('explorer', ['/select,${file.path}']);
        return;
      }
      if (Platform.isLinux) {
        await Process.run('xdg-open', [file.parent.path]);
      }
    } catch (_) {
      // The report is already saved. File-manager reveal is best-effort.
    }
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
    final dir = await _reportsDirectory();
    final safe = projectName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      '${dir.path}${Platform.pathSeparator}navdreaminfra_${safe}_${kind}_$stamp.$ext',
    );
    if (content is String) {
      await file.writeAsString(content, flush: true);
    } else {
      await file.writeAsBytes(content as List<int>, flush: true);
    }
    return file;
  }

  Future<Directory> _reportsDirectory() async {
    if (!_isDesktop) return getTemporaryDirectory();
    final base =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}NAVDREAM Reports',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

class _PdfMetric {
  const _PdfMetric(this.label, this.value, this.accent);

  final String label;
  final String value;
  final PdfColor accent;
}

class _PdfDetailSection {
  const _PdfDetailSection({
    required this.title,
    required this.accent,
    required this.rows,
  });

  final String title;
  final PdfColor accent;
  final List<List<String>> rows;
}
