import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_constants.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Reminders', Icons.notifications_active_outlined, AppRoutes.reminders),
      ('Invoices', Icons.receipt_long_outlined, AppRoutes.invoices),
      ('Inventory', Icons.inventory_2_outlined, AppRoutes.inventory),
      ('Staff', Icons.admin_panel_settings_outlined, AppRoutes.staff),
      ('App lock', Icons.lock_outline, AppRoutes.appLock),
      ('Business card', Icons.badge_outlined, AppRoutes.businessCard),
      ('Audit logs', Icons.manage_search_outlined, AppRoutes.auditLogs),
      ('Sync queue', Icons.sync_outlined, AppRoutes.syncQueue),
      ('Settings', Icons.settings_outlined, AppRoutes.settings),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.push(item.$3),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$2),
                    const Spacer(),
                    Text(
                      item.$1,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
