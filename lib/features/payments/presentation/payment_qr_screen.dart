import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/utils/communication_service.dart';
import '../../../data/repositories/ledger_repository.dart';

class PaymentQrScreen extends ConsumerWidget {
  const PaymentQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment QR')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                Text(
                  'Could not load business profile: $error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(businessProfileProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          final upiId = profile.upiId?.trim() ?? '';
          if (upiId.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No business UPI id is set yet. Add a UPI id to your business '
                  'profile to generate a payment QR.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final uri = const CommunicationService().upiDeepLink(
            upiId: upiId,
            payeeName: profile.name,
            note: 'LedgerPro payment',
          );

          return ListView(
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
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
            ],
          );
        },
      ),
    );
  }
}
