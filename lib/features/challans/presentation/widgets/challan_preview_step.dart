import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../core/money/money.dart';
import '../../../../data/repositories/infra_repository.dart';
import '../../../../shared/components/infra_components.dart';
import '../../application/challan_providers.dart';
import '../../domain/challan_models.dart';
import '../../domain/challan_status.dart';
import '../../domain/material_type.dart';

/// Step 4 — read-only preview of the captured challan.
///
/// Portal-captured values are intentionally not editable. Editing would break
/// the meaning of `portal_captured`, so the user must instead downgrade the
/// record to a manual entry, which preserves the original extracted payload.
class ChallanPreviewStep extends ConsumerWidget {
  const ChallanPreviewStep({
    super.key,
    required this.onConfirm,
    required this.onRetry,
    required this.onBackToPortal,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onRetry;
  final VoidCallback onBackToPortal;
  final VoidCallback onCancel;

  static final _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _dayFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challanFlowControllerProvider);
    final controller = ref.read(challanFlowControllerProvider.notifier);
    final payload = state.payload;
    if (payload == null) {
      return const SectionCard(
        title: 'Preview',
        icon: Icons.preview_outlined,
        child: EmptyState(
          icon: Icons.document_scanner_outlined,
          title: 'Nothing captured yet',
          message: 'Capture the challan from the government portal first.',
        ),
      );
    }

    final project = state.projectId == null
        ? null
        : ref.watch(projectByIdProvider(state.projectId!));
    final status =
        state.captureResult?.status ??
        ChallanVerificationStatus.manualUnverified;

    return SectionCard(
      title: 'Auto Fetch & Preview',
      icon: Icons.preview_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CaptureBanner(status: status, capturedAt: payload.capturedAt),
          const SizedBox(height: 14),

          if (state.hasMaterialMismatch)
            _MaterialMismatchWarning(
              selected: state.materialType!,
              portalMineral: payload.mineralName ?? '—',
              acknowledged: state.materialMismatchAcknowledged,
              onAcknowledge: controller.acknowledgeMaterialMismatch,
            ),

          if (state.manualFallback) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: InfraColors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'This will be saved as a manual entry (Manual — unverified). '
                'The originally extracted portal payload is still preserved on '
                'the record.',
                style: TextStyle(fontSize: 12, height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
          ],

          _Group(
            title: 'LedgerPro selection',
            rows: [
              _Row('Project', project?.name ?? '—'),
              _Row(
                'Selected material',
                state.materialType?.label ?? 'Not specified',
              ),
              _Row('Financial year', state.financialYear),
            ],
          ),
          const SizedBox(height: 4),
          _Group(
            title: 'Captured from portal',
            readOnly: true,
            rows: [
              _Row('Challan number', payload.challanNumber ?? '—'),
              _Row('UID number', payload.uidNumber ?? '—'),
              _Row('Challan date', _formatDate(payload.challanDate)),
              _Row('Validity', _formatDate(payload.validUntil)),
              _Row('Consignor', payload.consignorName ?? '—'),
              _Row('Generated from', payload.generatedFrom ?? '—'),
              _Row('Source', payload.sourceLocation ?? '—'),
              _Row('Destination', payload.destination ?? '—'),
              _Row('Vehicle type', payload.vehicleType ?? '—'),
              _Row('Vehicle number', payload.vehicleNumber ?? '—'),
              _Row('Mineral', payload.mineralName ?? '—'),
              _Row('Quantity', _formatQuantity(payload)),
              _Row('Consignee', payload.consigneeName ?? '—'),
              if (payload.royaltyAmountPaise != null)
                _Row(
                  'Royalty amount',
                  Money.fromPaise(payload.royaltyAmountPaise!).formatInr(),
                ),
            ],
          ),

          if (payload.royaltyAmountPaise != null) ...[
            const SizedBox(height: 10),
            const Text(
              'Saving this challan does not create a project expense. '
              'Royalty is recorded on the challan only.',
              style: TextStyle(
                fontSize: 11,
                color: InfraColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: InfraColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: InfraColors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: InfraColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: state.isBusy || state.needsMaterialConfirmation
                    ? null
                    : onConfirm,
                icon: state.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(state.isSaving ? 'Saving…' : 'Confirm & save'),
              ),
              OutlinedButton.icon(
                onPressed: state.isBusy ? null : onBackToPortal,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to portal'),
              ),
              OutlinedButton.icon(
                onPressed: state.isBusy ? null : onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry capture'),
              ),
              TextButton(
                onPressed: state.isBusy ? null : onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),

          if (!state.manualFallback) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: state.isBusy ? null : controller.switchToManualEntry,
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: const Text('Need to correct something?'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return '—';
    // Portal timestamps are absolute instants; render them in India Standard
    // Time so the date always matches what the portal displayed.
    final ist = value.toUtc().add(const Duration(hours: 5, minutes: 30));
    final naive = DateTime(ist.year, ist.month, ist.day, ist.hour, ist.minute);
    final hasTime = ist.hour != 0 || ist.minute != 0;
    return '${hasTime ? _dateFormat.format(naive) : _dayFormat.format(naive)} IST';
  }

  static String _formatQuantity(CapturedPortalPayload payload) {
    final text = payload.quantityText ?? payload.quantity?.toString() ?? '—';
    if (payload.quantityUnit == null) {
      return '$text (unit not shown by portal — saved as MT)';
    }
    return '$text ${payload.quantityUnit}';
  }
}

class _CaptureBanner extends StatelessWidget {
  const _CaptureBanner({required this.status, this.capturedAt});

  final ChallanVerificationStatus status;
  final DateTime? capturedAt;

  @override
  Widget build(BuildContext context) {
    final captured = status == ChallanVerificationStatus.portalCaptured;
    final color = captured ? InfraColors.green : InfraColors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Icon(
            captured ? Icons.verified_outlined : Icons.edit_note_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
                if (capturedAt != null)
                  Text(
                    'Captured ${ChallanPreviewStep._dateFormat.format(capturedAt!.toLocal())}',
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
    );
  }
}

class _MaterialMismatchWarning extends StatelessWidget {
  const _MaterialMismatchWarning({
    required this.selected,
    required this.portalMineral,
    required this.acknowledged,
    required this.onAcknowledge,
  });

  final ChallanMaterialType selected;
  final String portalMineral;
  final bool acknowledged;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InfraColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InfraColors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 18,
                color: InfraColors.orange,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Material differs from the portal',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You selected "${selected.label}" but the portal reports '
            '"$portalMineral". Both values will be stored — nothing is '
            'overwritten. Confirm to continue.',
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          if (acknowledged)
            const Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: InfraColors.green),
                SizedBox(width: 6),
                Text(
                  'Difference confirmed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: InfraColors.green,
                  ),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: onAcknowledge,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('I understand, keep both values'),
            ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.rows,
    this.readOnly = false,
  });

  final String title;
  final List<_Row> rows;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Wrap rather than Row: on a narrow phone the title plus the
        // "read-only" affordance can exceed one line.
        Wrap(
          spacing: 6,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: InfraColors.textPrimary,
              ),
            ),
            if (readOnly)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: InfraColors.textSecondary,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'read-only',
                    style: TextStyle(
                      fontSize: 10,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        ...rows,
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: InfraColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
