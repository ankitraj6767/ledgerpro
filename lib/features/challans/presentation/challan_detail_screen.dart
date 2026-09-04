import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../core/money/money.dart';
import '../../../core/refresh/pull_to_refresh.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../infra/data/infra_report_service.dart';
import '../application/challan_providers.dart';
import '../domain/challan_exceptions.dart';
import '../domain/challan_formatting.dart';
import '../domain/challan_models.dart';
import '../domain/challan_portal.dart';
import '../domain/challan_status.dart';
import '../domain/material_type.dart';
import 'widgets/challan_card.dart';
import 'widgets/royalty_unmark_dialog.dart';

/// Read-only detail view for one saved challan.
class ChallanDetailScreen extends ConsumerStatefulWidget {
  const ChallanDetailScreen({super.key, required this.challanId});

  final String challanId;

  @override
  ConsumerState<ChallanDetailScreen> createState() =>
      _ChallanDetailScreenState();
}

class _ChallanDetailScreenState extends ConsumerState<ChallanDetailScreen> {
  bool _updatingRoyalty = false;

  @override
  Widget build(BuildContext context) {
    final challanAsync = ref.watch(challanByIdProvider(widget.challanId));
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return Scaffold(
      backgroundColor: InfraColors.background,
      appBar: AppBar(
        title: const Text('Challan Details'),
        actions: [
          challanAsync.maybeWhen(
            data: (challan) => challan == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      IconButton(
                        tooltip: 'Download PDF',
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        onPressed: () => _downloadPdf(context, ref, challan),
                      ),
                      if (permissions.canDeleteChallan)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'pdf':
                                _downloadPdf(context, ref, challan);
                              case 'delete':
                                _confirmDelete(context, ref, challan);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'pdf',
                              child: Text('Download PDF'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete challan',
                                style: TextStyle(color: InfraColors.red),
                              ),
                            ),
                          ],
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
          onRetry: () => ref.invalidate(challanByIdProvider(widget.challanId)),
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
    final permissions = ref.watch(currentOrgPermissionsProvider);

    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(challanByIdProvider(widget.challanId));
        return ref.awaitRefresh(
          ref.read(challanByIdProvider(widget.challanId).future),
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

          Card(
            child: SwitchListTile.adaptive(
              value: challan.royaltyPaid,
              onChanged: permissions.canMarkChallanRoyalty && !_updatingRoyalty
                  ? (paid) =>
                        unawaited(_setRoyaltyPaid(context, ref, challan, paid))
                  : null,
              secondary: _updatingRoyalty
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      challan.royaltyPaid
                          ? Icons.verified_outlined
                          : Icons.pending_outlined,
                      color: challan.royaltyPaid
                          ? InfraColors.green
                          : InfraColors.textSecondary,
                    ),
              title: const Text(
                'Government royalty paid',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                challan.royaltyPaid
                    ? 'Marked paid${challan.royaltyPaidAt == null ? '' : ' on ${_formatDate(challan.royaltyPaidAt!)}'}'
                    : 'Mark this when the royalty has been paid to the government.',
              ),
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

  Future<void> _setRoyaltyPaid(
    BuildContext context,
    WidgetRef ref,
    EPassChallan challan,
    bool paid,
  ) async {
    if (_updatingRoyalty) return;
    if (challan.royaltyPaid && !paid) {
      final confirmed = await RoyaltyUnmarkDialog.confirm(
        context,
        challan: challan,
      );
      if (!confirmed || !context.mounted) return;
    }

    setState(() => _updatingRoyalty = true);
    try {
      await ref
          .read(challanRepositoryProvider)
          .updateRoyaltyPaid(challanId: challan.id, royaltyPaid: paid);
      ref.invalidate(challanByIdProvider(challan.id));
      ref.invalidate(challansProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ChallanException
                ? error.message
                : 'Could not update royalty status. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingRoyalty = false);
    }
  }

  static String _formatDate(DateTime value) {
    final date = value.toUtc().add(const Duration(hours: 5, minutes: 30));
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
  }

  static String _monthName(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  /// Portal name for display, resolved through the portal enum so a new portal
  /// only has to be added in one place.
  static String _portalLabel(String sourcePortal) =>
      ChallanPortalMapping.fromDb(sourcePortal).displayName;

  /// Generates the compact one-page challan PDF and hands it to the OS.
  Future<void> _downloadPdf(
    BuildContext context,
    WidgetRef ref,
    EPassChallan challan,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      // Optional: the cover falls back to the joined project name when the
      // project itself has not been loaded into the cache.
      final project = ref.read(projectByIdProvider(challan.projectId));
      const service = InfraReportService();
      final file = await service.challanDetailPdf(
        organizationName: org.name,
        project: project,
        challan: challan,
      );
      await service.share(file, isPdf: true);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Challan PDF generated.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $error')),
      );
    }
  }

  static String _formatIst(DateTime? value) => ChallanDates.ist(value);

  static String _formatLocal(DateTime? value) => ChallanDates.local(value);

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
