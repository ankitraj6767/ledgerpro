import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/communication_service.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../shared/models/ledger_models.dart';

class BusinessCardScreen extends ConsumerWidget {
  const BusinessCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Business card')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load business profile: $error'),
          ),
        ),
        data: (profile) {
          final upi = profile.upiId?.trim() ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (profile.ownerName != null) ...[
                        const SizedBox(height: 4),
                        Text(profile.ownerName!),
                      ],
                      const Divider(height: 28),
                      if (profile.phone != null)
                        _line(Icons.phone_outlined, profile.phone!),
                      if (profile.gstin != null)
                        _line(Icons.receipt_long_outlined,
                            'GSTIN: ${profile.gstin!}'),
                      if (profile.address != null)
                        _line(Icons.location_on_outlined, profile.address!),
                      if (upi.isNotEmpty) ...[
                        _line(Icons.qr_code_2_outlined, upi),
                        const SizedBox(height: 16),
                        Center(
                          child: QrImageView(
                            data: const CommunicationService()
                                .upiDeepLink(
                                  upiId: upi,
                                  payeeName: profile.name,
                                )
                                .toString(),
                            size: 160,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _share(context, profile),
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Share business card (PDF)'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context, BusinessProfile profile) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a6,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(profile.name,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              if (profile.ownerName != null) pw.Text(profile.ownerName!),
              pw.SizedBox(height: 8),
              if (profile.phone != null) pw.Text('Phone: ${profile.phone}'),
              if (profile.gstin != null) pw.Text('GSTIN: ${profile.gstin}'),
              if (profile.address != null) pw.Text(profile.address!),
              if ((profile.upiId ?? '').isNotEmpty)
                pw.Text('UPI: ${profile.upiId}'),
            ],
          ),
        ),
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/business_card.pdf');
      await file.writeAsBytes(await doc.save(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          title: profile.name,
          files: [XFile(file.path, mimeType: 'application/pdf')],
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not share business card: $error')),
      );
    }
  }
}
