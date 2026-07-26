import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/infra_theme.dart';
import '../../../../data/repositories/infra_repository.dart';
import '../../domain/challan_models.dart';
import '../../domain/material_type.dart';

/// Shown when the same challan is already saved in this organization.
///
/// RLS guarantees the existing record can only ever belong to the caller's own
/// organization, so nothing here can leak another org's data. The user's name is
/// only shown to roles allowed to see audit information.
class DuplicateChallanDialog extends ConsumerWidget {
  const DuplicateChallanDialog({super.key, required this.existing});

  final EPassChallan existing;

  static Future<void> show(BuildContext context, EPassChallan existing) {
    return showDialog<void>(
      context: context,
      builder: (context) => DuplicateChallanDialog(existing: existing),
    );
  }

  static final _dayFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final project = ref.watch(projectByIdProvider(existing.projectId));

    return AlertDialog(
      icon: const Icon(
        Icons.copy_all_outlined,
        color: InfraColors.orange,
        size: 28,
      ),
      title: const Text('This challan is already saved'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            existing.challanNumber,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _row(
            'Previously saved',
            existing.createdAt == null
                ? '—'
                : _dayFormat.format(existing.createdAt!.toLocal()),
          ),
          _row('Project', project?.name ?? existing.projectName ?? '—'),
          _row(
            'Material',
            existing.selectedMaterialType?.label ??
                (existing.portalMineralName.isEmpty
                    ? '—'
                    : existing.portalMineralName),
          ),
          _row('Vehicle number', existing.vehicleNumber),
          if (permissions.canViewAuditLogs && existing.createdBy != null)
            _row('Saved by', _shortId(existing.createdBy!)),
          const SizedBox(height: 12),
          const Text(
            'A challan can only be saved once per organization and financial '
            'year. Nothing was changed. If this entry is wrong, open it and '
            'delete it — the number becomes free to add again.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: InfraColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.challanDetail(existing.id));
          },
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Open existing entry'),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  /// Shows a short, non-identifying reference rather than a bare UUID.
  static String _shortId(String userId) =>
      'User ${userId.substring(0, userId.length.clamp(0, 8))}';
}
