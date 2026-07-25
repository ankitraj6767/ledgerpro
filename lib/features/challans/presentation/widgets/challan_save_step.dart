import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/infra_theme.dart';
import '../../../../shared/components/infra_components.dart';
import '../../application/challan_providers.dart';
import '../../domain/challan_status.dart';

/// Step 5 — save outcome.
class ChallanSaveStep extends ConsumerWidget {
  const ChallanSaveStep({
    super.key,
    required this.onAddAnother,
    required this.onDone,
  });

  final VoidCallback onAddAnother;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challanFlowControllerProvider);
    final saved = state.savedChallan;

    if (state.isSaving || saved == null) {
      return const SectionCard(
        title: 'Save Entry',
        icon: Icons.save_outlined,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Saving the challan…',
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

    return SectionCard(
      title: 'Save Entry',
      icon: Icons.check_circle_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: InfraColors.green.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: InfraColors.green.withValues(alpha: 0.32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: InfraColors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Challan saved',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  saved.challanNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${saved.portalMineralName} · ${saved.quantityLabel} · '
                  '${saved.vehicleNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: InfraColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  saved.verificationStatus.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: saved.isPortalCaptured
                        ? InfraColors.green
                        : InfraColors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No project expense was created. Material movement and payable '
            'amounts are tracked separately.',
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: InfraColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onAddAnother,
                icon: const Icon(Icons.add),
                label: const Text('Add another challan'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.challanDetail(saved.id)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View entry'),
              ),
              TextButton(onPressed: onDone, child: const Text('Done')),
            ],
          ),
        ],
      ),
    );
  }
}
