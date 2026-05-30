import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../app/constants/app_constants.dart';
import '../../../core/money/money.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            tooltip: 'Create invoice',
            onPressed: () => context.push(AppRoutes.createInvoice),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                Text('Could not load invoices: $error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(invoicesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No invoices yet. Tap + to create your first invoice.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final parties = ref.watch(partiesProvider).value ?? const <Party>[];
          String partyName(String id) =>
              parties.where((p) => p.id == id).firstOrNull?.name ?? 'Customer';

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(invoicesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Card(
                  child: ListTile(
                    onTap: () => context.push(
                      AppRoutes.invoicePreview,
                      extra: invoice,
                    ),
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${partyName(invoice.partyId)} · ${invoice.status.name}',
                    ),
                    trailing: Text(
                      Money.fromPaise(invoice.totalPaise).formatInr(),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _gstController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  String? _partyId;
  bool _saving = false;
  bool _numberInitialized = false;

  @override
  void initState() {
    super.initState();
    _initNumber();
  }

  Future<void> _initNumber() async {
    try {
      final number = await ref.read(ledgerRepositoryProvider).nextInvoiceNumber();
      if (mounted && !_numberInitialized) {
        _numberController.text = number;
        _numberInitialized = true;
      }
    } catch (_) {
      // Leave blank; user can type a number manually.
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _gstController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create invoice')),
      body: partiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load customers: $error'),
          ),
        ),
        data: (parties) {
          final customers = parties
              .where((p) =>
                  p.type == PartyType.customer || p.type == PartyType.both)
              .toList();
          if (customers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Add a customer before creating an invoice.'),
              ),
            );
          }
          _partyId ??= customers.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _partyId,
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: customers
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _partyId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Invoice number',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (subtotal)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _gstController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'GST %',
                  prefixIcon: Icon(Icons.percent_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save invoice'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final partyId = _partyId;
    if (partyId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select a customer.')),
      );
      return;
    }
    int subtotal;
    try {
      subtotal = LedgerRepository.parsePaise(_amountController.text);
      if (subtotal <= 0) throw const FormatException('Amount required');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(ledgerRepositoryProvider).createInvoice(
            partyId: partyId,
            invoiceNumber: _numberController.text.trim().isEmpty
                ? await ref.read(ledgerRepositoryProvider).nextInvoiceNumber()
                : _numberController.text.trim(),
            subtotalPaise: subtotal,
            gstRate: double.tryParse(_gstController.text.trim()) ?? 0,
            notes: _notesController.text,
          );
      ref.invalidate(invoicesProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Invoice created.')),
      );
      router.pop();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not create invoice: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class InvoicePreviewScreen extends ConsumerWidget {
  const InvoicePreviewScreen({super.key, this.invoice});

  final Invoice? invoice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = invoice;
    if (inv == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice preview')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Open an invoice from the list to preview it.'),
          ),
        ),
      );
    }

    final parties = ref.watch(partiesProvider).value ?? const <Party>[];
    final partyName =
        parties.where((p) => p.id == inv.partyId).firstOrNull?.name ??
            'Customer';
    final businessName =
        ref.watch(businessNameProvider).value ?? 'LedgerPro Business';

    return Scaffold(
      appBar: AppBar(title: Text(inv.invoiceNumber)),
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
                    inv.invoiceNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$businessName → $partyName'),
                  Text('Status: ${inv.status.name}'),
                  const Divider(height: 28),
                  _row('Subtotal', inv.subtotalPaise),
                  _row('GST', inv.gstPaise),
                  _row('Total', inv.totalPaise, bold: true),
                  if (inv.paidPaise > 0) _row('Paid', inv.paidPaise),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _sharePdf(context, inv, businessName, partyName),
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('Share PDF invoice'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, int paise, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            Money.fromPaise(paise).formatInr(),
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf(
    BuildContext context,
    Invoice inv,
    String businessName,
    String partyName,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(businessName,
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Tax Invoice: ${inv.invoiceNumber}'),
              pw.Text('Bill to: $partyName'),
              pw.Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(inv.date)}',
              ),
              pw.SizedBox(height: 18),
              pw.TableHelper.fromTextArray(
                headers: const ['Description', 'Amount'],
                data: [
                  ['Subtotal', Money.fromPaise(inv.subtotalPaise).formatInr()],
                  ['GST', Money.fromPaise(inv.gstPaise).formatInr()],
                  ['Total', Money.fromPaise(inv.totalPaise).formatInr()],
                ],
              ),
              pw.SizedBox(height: 18),
              if (inv.notes != null) pw.Text('Notes: ${inv.notes}'),
            ],
          ),
        ),
      );
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/invoice_${inv.invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}.pdf',
      );
      await file.writeAsBytes(await doc.save(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          title: 'Invoice ${inv.invoiceNumber}',
          files: [XFile(file.path, mimeType: 'application/pdf')],
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate invoice PDF: $error')),
      );
    }
  }
}
