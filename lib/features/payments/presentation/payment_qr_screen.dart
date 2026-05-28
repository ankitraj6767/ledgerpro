import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/utils/communication_service.dart';
import '../../../data/repositories/demo_ledger_provider.dart';

class PaymentQrScreen extends ConsumerWidget {
  const PaymentQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upiId = ref.watch(ownerUpiIdProvider);
    final businessName = ref.watch(businessNameProvider);
    final uri = const CommunicationService().upiDeepLink(
      upiId: upiId,
      payeeName: businessName,
      note: 'LedgerPro payment',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Payment QR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  QrImageView(data: uri.toString(), size: 240),
                  const SizedBox(height: 16),
                  Text(
                    upiId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Static UPI QR. Payment status must be manually confirmed unless a gateway webhook confirms it.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark as paid manually'),
          ),
        ],
      ),
    );
  }
}
