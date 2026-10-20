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
      barrierColor: InfraColors.navy.withValues(alpha: 0.62),
      builder: (dialogContext) => RoyaltyUnmarkDialog(challan: challan),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFF946018);
    const danger = Color(0xFFB42318);
    final actionTextStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 14);
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: InfraColors.navy.withValues(alpha: 0.2),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      constraints: const BoxConstraints(maxWidth: 440),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: InfraColors.border),
      ),
      // Material keeps the decision buttons visible while the explanation can
      // scroll on compact screens or when the user increases their text size.
      scrollable: true,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E8),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFF1DEB7)),
                ),
                child: const Icon(Icons.undo_rounded, color: amber, size: 21),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'PAYMENT CORRECTION',
                  style: TextStyle(
                    color: InfraColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Unmark government royalty?',
            style: TextStyle(
              color: InfraColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.2,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Only continue if the payment marker was added by mistake '
            'or needs correction.',
            style: TextStyle(
              color: InfraColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: InfraColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: InfraColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 21,
                        color: InfraColors.navy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CHALLAN',
                            style: TextStyle(
                              color: InfraColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            challan.challanNumber,
                            style: const TextStyle(
                              color: InfraColors.navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: InfraColors.border),
                ),
                const Text(
                  'AFTER CONFIRMATION',
                  style: TextStyle(
                    color: InfraColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: amber,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Royalty pending',
                        style: TextStyle(
                          color: amber,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                    height: 1.5,
                    color: InfraColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: InfraColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: InfraColors.navy,
                  foregroundColor: Colors.white,
                  textStyle: actionTextStyle?.copyWith(color: Colors.white),
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Keep marked paid',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFAF9),
                  foregroundColor: danger,
                  textStyle: actionTextStyle?.copyWith(color: danger),
                  side: const BorderSide(color: Color(0xFFF0CFCB)),
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.undo_rounded, size: 18),
                    SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        'Unmark as unpaid',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
