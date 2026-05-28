import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../money/money.dart';
import '../../shared/models/ledger_models.dart';

class CommunicationService {
  const CommunicationService();

  Future<void> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openWhatsappReminder({
    required String phone,
    required String name,
    required String businessName,
    required int amountPaise,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final message =
        'Namaste $name, ${Money.fromPaise(amountPaise).formatInr()} pending hai. Kripya payment kar dein. - $businessName';
    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Uri upiDeepLink({
    required String upiId,
    required String payeeName,
    int? amountPaise,
    String? note,
  }) {
    final amount = amountPaise == null
        ? null
        : '${amountPaise ~/ 100}.${(amountPaise.abs() % 100).toString().padLeft(2, '0')}';
    final queryParameters = <String, String>{
      'pa': upiId,
      'pn': payeeName,
      'cu': 'INR',
    };
    if (amount != null) queryParameters['am'] = amount;
    if (note != null) queryParameters['tn'] = note;
    return Uri(scheme: 'upi', host: 'pay', queryParameters: queryParameters);
  }

  Future<File> createStatementPdf({
    required Party party,
    required List<LedgerTransaction> transactions,
    required String businessName,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            businessName,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Statement for ${party.name}'),
          pw.Text(
            'Balance: ${Money.fromPaise(party.balancePaise).formatInr()}',
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Type', 'Amount', 'Note'],
            data: transactions
                .map(
                  (entry) => [
                    entry.occurredAt.toIso8601String().substring(0, 10),
                    entry.type.name,
                    Money.fromPaise(entry.amountPaise).formatInr(),
                    entry.note ?? '',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ledgerpro_${party.id}_statement.pdf');
    await file.writeAsBytes(await doc.save(), flush: true);
    return file;
  }

  Future<void> shareStatementPdf(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'LedgerPro statement',
        files: [XFile(file.path, mimeType: 'application/pdf')],
      ),
    );
  }
}
