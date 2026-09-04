import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../domain/challan_models.dart';

/// A deliberate confirmation barrier for reversing a recorded royalty payment.
///
/// Marking a payment is a routine bookkeeping action; removing that marker is
/// materially different because it changes the team's follow-up queue. Keeping
/// this dialog in one place ensures the list card and detail screen always use
/// the same copy, visual hierarchy, and confirmation semantics.
class RoyaltyUnmarkDialog extends StatelessWidget {
  const RoyaltyUnmarkDialog({super.key, required this.challan});

  final EPassChallan challan;

  static Future<bool> confirm(
    BuildContext context, {
    required EPassChallan challan,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => RoyaltyUnmarkDialog(challan: challan),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InfraColors.orange.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: InfraColors.orange,
          size: 28,
        ),
      ),
      title: const Text('Unmark government royalty?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will move the challan back to Royalty pending. Only continue '
            'if the payment marker was added by mistake or needs correction.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: InfraColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InfraColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: InfraColors.royalBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    challan.challanNumber,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.history_outlined,
                size: 17,
                color: InfraColors.textSecondary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The change will be recorded in the audit trail.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: InfraColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep marked paid'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: InfraColors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.undo_outlined, size: 18),
          label: const Text('Unmark as unpaid'),
        ),
      ],
    );
  }
}
