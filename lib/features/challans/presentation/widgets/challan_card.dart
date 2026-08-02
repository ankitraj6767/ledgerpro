import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../domain/challan_models.dart';
import '../../domain/challan_status.dart';

/// One row in the recent-challan list.
class ChallanCard extends StatelessWidget {
  const ChallanCard({
    super.key,
    required this.challan,
    this.onTap,
    this.selected = false,
    this.onSelectionChanged,
  });

  final EPassChallan challan;
  final VoidCallback? onTap;
  final bool selected;
  final ValueChanged<bool?>? onSelectionChanged;

  static final _dayFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onSelectionChanged != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Checkbox(
                    value: selected,
                    visualDensity: VisualDensity.compact,
                    onChanged: onSelectionChanged,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            challan.challanNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChallanStatusBadge(status: challan.verificationStatus),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      challan.projectName ?? 'Project',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: InfraColors.royalBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _Fact(
                          icon: Icons.event_outlined,
                          text: challan.challanDate == null
                              ? 'No date'
                              : _dayFormat.format(_toIst(challan.challanDate!)),
                        ),
                        _Fact(
                          icon: Icons.landscape_outlined,
                          text: challan.portalMineralName.isEmpty
                              ? '—'
                              : challan.portalMineralName,
                        ),
                        _Fact(
                          icon: Icons.scale_outlined,
                          text: challan.quantityLabel,
                        ),
                        _Fact(
                          icon: Icons.local_shipping_outlined,
                          text: challan.vehicleNumber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          challan.verificationMethod ==
                                  ChallanVerificationMethod
                                      .webviewHumanVerification
                              ? Icons.shield_outlined
                              : Icons.edit_note_outlined,
                          size: 12,
                          color: InfraColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            challan.verificationMethod.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: InfraColors.textSecondary,
                            ),
                          ),
                        ),
                        if (challan.hasMaterialMismatch)
                          const Tooltip(
                            message:
                                'Selected material differs from portal mineral',
                            child: Icon(
                              Icons.warning_amber_outlined,
                              size: 14,
                              color: InfraColors.orange,
                            ),
                          ),
                      ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static DateTime _toIst(DateTime value) =>
      value.toUtc().add(const Duration(hours: 5, minutes: 30));
}

/// Verification status badge. Uses the module's explicit wording so a portal
/// capture is never mistaken for an officially verified record.
class ChallanStatusBadge extends StatelessWidget {
  const ChallanStatusBadge({
    super.key,
    required this.status,
    this.full = false,
  });

  final ChallanVerificationStatus status;

  /// Shows the long label ("Captured from Bihar Government Portal").
  final bool full;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ChallanVerificationStatus.portalCaptured => InfraColors.green,
      ChallanVerificationStatus.officialApiVerified => InfraColors.royalBlue,
      ChallanVerificationStatus.manualUnverified => InfraColors.orange,
      ChallanVerificationStatus.invalid => InfraColors.red,
      ChallanVerificationStatus.expired => InfraColors.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        full ? status.label : status.shortLabel,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: InfraColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: InfraColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
