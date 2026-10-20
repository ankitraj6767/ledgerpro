import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../domain/challan_models.dart';
import '../../domain/challan_status.dart';
import 'royalty_unmark_dialog.dart';

/// One row in the recent-challan list.
class ChallanCard extends StatefulWidget {
  const ChallanCard({
    super.key,
    required this.challan,
    this.onTap,
    this.selected = false,
    this.onSelectionChanged,
    this.onRoyaltyPaidChanged,
  });

  final EPassChallan challan;
  final VoidCallback? onTap;
  final bool selected;
  final ValueChanged<bool?>? onSelectionChanged;
  final Future<void> Function(bool paid)? onRoyaltyPaidChanged;

  @override
  State<ChallanCard> createState() => _ChallanCardState();
}

class _ChallanCardState extends State<ChallanCard> {
  bool? _optimisticRoyaltyPaid;
  bool _updatingRoyalty = false;

  @override
  void didUpdateWidget(covariant ChallanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_updatingRoyalty &&
        oldWidget.challan.royaltyPaid != widget.challan.royaltyPaid) {
      _optimisticRoyaltyPaid = null;
    }
  }

  Future<void> _setRoyaltyPaid(bool paid) async {
    final callback = widget.onRoyaltyPaidChanged;
    if (callback == null || _updatingRoyalty) return;

    final currentRoyaltyPaid =
        _optimisticRoyaltyPaid ?? widget.challan.royaltyPaid;
    if (currentRoyaltyPaid && !paid) {
      final confirmed = await RoyaltyUnmarkDialog.confirm(
        context,
        challan: widget.challan,
      );
      if (!confirmed || !mounted) return;
    }

    setState(() {
      _optimisticRoyaltyPaid = paid;
      _updatingRoyalty = true;
    });
    try {
      await callback(paid);
      if (!mounted) return;
      setState(() {
        // Keep the confirmed value visible until the refreshed provider data
        // arrives. This also keeps the UI correct when a test or offline
        // cache supplies the previous snapshot for one more frame.
        _optimisticRoyaltyPaid = paid;
        _updatingRoyalty = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _optimisticRoyaltyPaid = widget.challan.royaltyPaid;
        _updatingRoyalty = false;
      });
    }
  }

  static final _dayFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final challan = widget.challan;
    final royaltyPaid = _optimisticRoyaltyPaid ?? challan.royaltyPaid;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: widget.selected ? InfraColors.navy : InfraColors.border,
          width: widget.selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challan.challanNumber,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: InfraColors.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (widget.onSelectionChanged != null)
                        Semantics(
                          label:
                              'Select challan ${challan.challanNumber} for PDF',
                          child: Checkbox(
                            value: widget.selected,
                            onChanged: widget.onSelectionChanged,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ChallanStatusBadge(status: challan.verificationStatus),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.business_outlined,
                        size: 16,
                        color: InfraColors.textSecondary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          challan.projectName ?? 'Project',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: InfraColors.navy,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final paired =
                          constraints.maxWidth >= 260 &&
                          MediaQuery.textScalerOf(context).scale(13) <= 18;
                      final width = paired
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final fact in [
                            _Fact(
                              icon: Icons.event_outlined,
                              text: challan.challanDate == null
                                  ? 'No date'
                                  : _dayFormat.format(
                                      _toIst(challan.challanDate!),
                                    ),
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
                          ])
                            SizedBox(width: width, child: fact),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        challan.verificationMethod ==
                                ChallanVerificationMethod
                                    .webviewHumanVerification
                            ? Icons.shield_outlined
                            : Icons.edit_note_outlined,
                        size: 14,
                        color: InfraColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          challan.verificationMethod.label,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
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
                            size: 18,
                            color: InfraColors.orange,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: InfraColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 48,
                    child: _updatingRoyalty
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Semantics(
                            label: 'Government royalty paid',
                            child: Checkbox(
                              value: royaltyPaid,
                              onChanged: widget.onRoyaltyPaidChanged == null
                                  ? null
                                  : (value) => _setRoyaltyPaid(value ?? false),
                            ),
                          ),
                  ),
                  Icon(
                    royaltyPaid
                        ? Icons.verified_outlined
                        : Icons.schedule_outlined,
                    size: 16,
                    color: royaltyPaid
                        ? const Color(0xFF147647)
                        : const Color(0xFF946018),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          royaltyPaid ? 'Royalty paid' : 'Royalty pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: royaltyPaid
                                ? const Color(0xFF147647)
                                : const Color(0xFF946018),
                          ),
                        ),
                        if (challan.royaltyPaidAt != null)
                          Text(
                            _dayFormat.format(_toIst(challan.royaltyPaidAt!)),
                            style: const TextStyle(
                              fontSize: 11,
                              color: InfraColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      ChallanVerificationStatus.portalCaptured => const Color(0xFF147647),
      ChallanVerificationStatus.officialApiVerified => const Color(0xFF175CD3),
      ChallanVerificationStatus.manualUnverified => const Color(0xFF946018),
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
          fontWeight: FontWeight.w600,
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
        Icon(icon, size: 15, color: InfraColors.textSecondary),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: InfraColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
