import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../shared/components/infra_components.dart';
import '../../application/challan_providers.dart';

/// Step 3 — verification outcome.
///
/// Shown while the captured markup is being validated and whenever validation
/// fails. Every failure is actionable and never exposes raw portal HTML or a
/// stack trace.
class ChallanVerificationStep extends ConsumerWidget {
  const ChallanVerificationStep({
    super.key,
    required this.onRetry,
    required this.onBackToPortal,
    required this.onManualEntry,
  });

  final VoidCallback onRetry;
  final VoidCallback onBackToPortal;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challanFlowControllerProvider);

    if (state.isCapturing) {
      return const SectionCard(
        title: 'Challan Verification',
        icon: Icons.fact_check_outlined,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Reading the challan details shown by the portal…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: InfraColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final message = state.errorMessage;

    return SectionCard(
      title: 'Challan Verification',
      icon: Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InfraColors.red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InfraColors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: InfraColors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Could not capture this challan',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? 'The portal result could not be read.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: InfraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nothing was saved.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: InfraColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onBackToPortal,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to portal'),
              ),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry capture'),
              ),
              TextButton.icon(
                onPressed: onManualEntry,
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: const Text('Add manual entry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
