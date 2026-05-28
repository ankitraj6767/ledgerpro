import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../models/ledger_models.dart';

class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SyncStatus.synced => AppTheme.emerald,
      SyncStatus.pending => AppTheme.brass,
      SyncStatus.failed => AppTheme.crimson,
    };
    final icon = switch (status) {
      SyncStatus.synced => Icons.cloud_done_outlined,
      SyncStatus.pending => Icons.sync_outlined,
      SyncStatus.failed => Icons.cloud_off_outlined,
    };
    final label = switch (status) {
      SyncStatus.synced => 'Synced',
      SyncStatus.pending => 'Pending',
      SyncStatus.failed => 'Failed',
    };

    return Semantics(
      label: 'Sync status $label',
      child: Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
