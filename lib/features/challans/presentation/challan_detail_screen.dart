import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../core/money/money.dart';
import '../../../core/refresh/pull_to_refresh.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../application/challan_providers.dart';
import '../domain/challan_exceptions.dart';
import '../domain/challan_models.dart';
import '../domain/challan_portal.dart';
import '../domain/challan_status.dart';
import '../domain/material_type.dart';
import 'widgets/challan_card.dart';

/// Read-only detail view for one saved challan.
class ChallanDetailScreen extends ConsumerWidget {
  const ChallanDetailScreen({super.key, required this.challanId});

  final String challanId;

  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _dayFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challanAsync = ref.watch(challanByIdProvider(challanId));
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return Scaffold(
      backgroundColor: InfraColors.background,
      appBar: AppBar(
        title: const Text('Challan Details'),
        actions: [
          if (permissions.canDeleteChallan)
            challanAsync.maybeWhen(
              data: (challan) => challan == null
                  ? const SizedBox.shrink()
                  : PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(context, ref, challan);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete challan',
                            style: TextStyle(color: InfraColors.red),
                          ),
                        ),
                      ],
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: challanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(
          message: error is ChallanException
              ? error.message
              : 'Could not load this challan.',
          onRetry: () => ref.invalidate(challanByIdProvider(challanId)),
        ),
        data: (challan) {
          if (challan == null) {
            return const EmptyState(
              icon: Icons.search_off_outlined,
              title: 'Challan not found',
              message: 'It may have been archived.',
            );
          }
          return _body(context, ref, challan);
        },
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, EPassChallan challan) {
    final project = ref.watch(projectByIdProvider(challan.projectId));

    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(challanByIdProvider(challanId));
        return ref.awaitRefresh(
          ref.read(challanByIdProvider(challanId).future),
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  challan.challanNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              ChallanStatusBadge(status: challan.verificationStatus),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challan.verificationStatus.labelFor(challan.portal),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: challan.isPortalCaptured
                  ? InfraColors.green
                  : InfraColors.orange,
            ),
          ),
          const SizedBox(height: 16),

          if (challan.hasMaterialMismatch)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: InfraColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: InfraColors.orange.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Selected material "${challan.selectedMaterialType?.label}" '
                'differs from the portal mineral "${challan.portalMineralName}". '
                'Both values are stored as recorded.',
                style: const TextStyle(fontSize: 12, height: 1.35),
              ),
            ),

          SectionCard(
            title: 'Entry',
            icon: Icons.inventory_2_outlined,
            child: Column(
              children: [
                _row('Project', project?.name ?? challan.projectName ?? '—'),
                _row('Financial year', challan.financialYear),
                _row(
                  'Selected material',
                  challan.selectedMaterialType?.label ?? 'Not specified',
                ),
                _row('Source portal', _portalLabel(challan.sourcePortal)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'Challan',
            icon: Icons.receipt_long_outlined,
            child: Column(
              children: [
                _row('Challan number', challan.challanNumber),
                _row('UID number', challan.uidNumber ?? '—'),
                _row('Challan date', _formatIst(challan.challanDate)),
                _row('Valid until', _formatIst(challan.validUntil)),
                _row('Mineral (portal)', challan.portalMineralName),
                _row('Quantity', challan.quantityLabel),
                _row('Generated from', challan.generatedFrom ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'Transport',
            icon: Icons.local_shipping_outlined,
            child: Column(
              children: [
                _row('Vehicle number', challan.vehicleNumber),
                _row('Vehicle type', challan.vehicleType ?? '—'),
                _row('Consignor', challan.consignorName ?? '—'),
                _row('Consignee', challan.consigneeName ?? '—'),
                _row('Source', challan.sourceLocation ?? '—'),
                _row('Destination', challan.destination ?? '—'),
              ],
            ),
          ),

          if (challan.royaltyAmountPaise != null) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Royalty',
              icon: Icons.payments_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    'Amount (as per portal)',
                    Money.fromPaise(challan.royaltyAmountPaise!).formatInr(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Recorded on the challan only. This amount is not included '
                    'in project expense totals — create an expense explicitly '
                    'if it is payable.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          SectionCard(
            title: 'Verification',
            icon: Icons.shield_outlined,
            child: Column(
              children: [
                _row(
                  'Status',
                  challan.verificationStatus.labelFor(challan.portal),
                ),
                _row('Method', challan.verificationMethod.label),
                _row('Captured at', _formatLocal(challan.capturedAt)),
                _row('Saved at', _formatLocal(challan.createdAt)),
                if (challan.portalResponseHash != null)
                  _row(
                    'Response hash',
                    '${challan.portalResponseHash!.substring(0, 16)}…',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Portal name for display, resolved through the portal enum so a new portal
  /// only has to be added in one place.
  static String _portalLabel(String sourcePortal) =>
      ChallanPortalMapping.fromDb(sourcePortal).displayName;

  static String _formatIst(DateTime? value) {
    if (value == null) return '—';
    final ist = value.toUtc().add(const Duration(hours: 5, minutes: 30));
    final naive = DateTime(ist.year, ist.month, ist.day, ist.hour, ist.minute);
    final hasTime = ist.hour != 0 || ist.minute != 0;
    return '${hasTime ? _dateTimeFormat.format(naive) : _dayFormat.format(naive)} IST';
  }

  static String _formatLocal(DateTime? value) =>
      value == null ? '—' : _dateTimeFormat.format(value.toLocal());

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    EPassChallan challan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this challan?'),
        content: Text(
          'Challan ${challan.challanNumber} will be removed from your challan '
          'list. The deletion is recorded in the audit trail, and the challan '
          'number becomes free again so you can re-add it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: InfraColors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(challanRepositoryProvider).deleteChallan(challan.id);
      ref.invalidate(challansProvider);
      ref.invalidate(challanByIdProvider(challan.id));
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on ChallanException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
