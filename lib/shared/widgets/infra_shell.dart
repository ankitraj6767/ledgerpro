import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/infra_theme.dart';
import '../../core/network/network_monitor.dart';
import '../../core/sync/infra_realtime_service.dart';
import '../../core/sync/offline_sync_service.dart';
import '../../data/repositories/infra_repository.dart';
import '../components/navdream_logo.dart';

class AdaptiveBreakpoints {
  const AdaptiveBreakpoints._();

  static const mobileMax = 699.0;
  static const tabletMax = 1099.0;
}

/// Adaptive navigation shell for mobile, tablet, and desktop.
class InfraShell extends ConsumerWidget {
  const InfraShell({super.key, required this.child});

  final Widget child;

  static const _routes = [
    AppRoutes.home,
    AppRoutes.projects,
    AppRoutes.expenses,
    AppRoutes.reports,
    AppRoutes.profile,
  ];

  static const _items = [
    _ShellItem(Icons.home_outlined, Icons.home, 'Home'),
    _ShellItem(Icons.business_outlined, Icons.business, 'Projects'),
    _ShellItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Expenses'),
    _ShellItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Reports'),
    _ShellItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  int _indexFor(String path) {
    if (path.startsWith(AppRoutes.projects)) return 1;
    if (path.startsWith(AppRoutes.expenses)) return 2;
    if (path.startsWith(AppRoutes.reports)) return 3;
    if (path.startsWith(AppRoutes.profile) ||
        path.startsWith(AppRoutes.settings) ||
        path.startsWith(AppRoutes.customers) ||
        path.startsWith(AppRoutes.auditLogs) ||
        path.startsWith(AppRoutes.syncQueue)) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(infraRealtimeBridgeProvider);
    final width = MediaQuery.sizeOf(context).width;
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFor(path);

    if (width <= AdaptiveBreakpoints.mobileMax) {
      return _MobileShell(
        selectedIndex: selectedIndex,
        onSelected: (index) => context.go(_routes[index]),
        child: child,
      );
    }

    if (width <= AdaptiveBreakpoints.tabletMax) {
      return _TabletShell(
        selectedIndex: selectedIndex,
        onSelected: (index) => context.go(_routes[index]),
        child: child,
      );
    }

    return _DesktopShell(
      selectedIndex: selectedIndex,
      onSelected: (index) => context.go(_routes[index]),
      child: child,
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: InfraShell._items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: InfraColors.navy,
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.only(top: 18, bottom: 18),
              child: NavdreamLogo(
                size: 42,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                showBorder: true,
              ),
            ),
            selectedIconTheme: const IconThemeData(color: InfraColors.gold),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(
              color: InfraColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            destinations: InfraShell._items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1, color: InfraColors.border),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopShell extends ConsumerWidget {
  const _DesktopShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: InfraColors.background,
      body: Row(
        children: [
          _DesktopSidebar(selectedIndex: selectedIndex, onSelected: onSelected),
          Expanded(
            child: Column(
              children: [
                const _CommandBar(),
                const Divider(height: 1, color: InfraColors.border),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgName =
        ref.watch(infraWorkspaceProvider).value?.name ??
        ref.watch(cachedDashboardProvider)?.orgName ??
        AppConstants.appName;
    return Container(
      width: 244,
      color: InfraColors.navy,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const NavdreamLogo(
                    size: 42,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    showBorder: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      orgName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              for (var i = 0; i < InfraShell._items.length; i++) ...[
                _SidebarButton(
                  item: InfraShell._items[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
                const SizedBox(height: 6),
              ],
              const Spacer(),
              const _SyncBadge(compact: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandBar extends ConsumerStatefulWidget {
  const _CommandBar();

  @override
  ConsumerState<_CommandBar> createState() => _CommandBarState();
}

class _CommandBarState extends ConsumerState<_CommandBar> {
  final _search = TextEditingController();
  bool _syncing = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        color: InfraColors.surface,
        child: Row(
          children: [
            SizedBox(
              width: 380,
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => context.go(AppRoutes.projects),
                decoration: const InputDecoration(
                  hintText: 'Search projects, expenses, reports',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const Spacer(),
            _CommandButton(
              icon: Icons.add_business_outlined,
              label: 'Project',
              onPressed: () => context.push(AppRoutes.newProject),
            ),
            const SizedBox(width: 8),
            _CommandButton(
              icon: Icons.receipt_long_outlined,
              label: 'Expense',
              onPressed: () => context.go(AppRoutes.expenses),
            ),
            const SizedBox(width: 12),
            const _SyncBadge(compact: true),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Sync now',
              onPressed: _syncing ? null : _syncNow,
              icon: _syncing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
            ),
            IconButton(
              tooltip: 'Profile',
              onPressed: () => context.go(AppRoutes.profile),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncNow() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    try {
      final result = await ref.read(offlineSyncServiceProvider).syncPending();
      ref.invalidate(syncOverviewProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Sync: ${result.synced} synced, ${result.failed} failed.',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Sync failed: $error')));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }
}

class _SyncBadge extends ConsumerWidget {
  const _SyncBadge({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(networkMonitorProvider).value ?? true;
    final overview = ref.watch(syncOverviewProvider).value;
    final failed = overview?.failedCount ?? 0;
    final pending = overview?.pendingCount ?? 0;
    final status = !online
        ? _SyncStatus(Icons.cloud_off_outlined, 'Offline', InfraColors.orange)
        : failed > 0
        ? _SyncStatus(Icons.error_outline, '$failed errors', InfraColors.red)
        : pending > 0
        ? _SyncStatus(
            Icons.cloud_sync_outlined,
            '$pending pending',
            InfraColors.orange,
          )
        : _SyncStatus(Icons.cloud_done_outlined, 'Synced', InfraColors.green);

    return Container(
      constraints: BoxConstraints(minWidth: compact ? 0 : 150),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: status.color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Icon(status.icon, size: 18, color: status.color),
          if (!compact) const SizedBox(width: 8),
          if (!compact)
            Expanded(
              child: Text(
                status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: status.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _ShellItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? InfraColors.royalBlue.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: selected ? InfraColors.gold : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ShellItem {
  const _ShellItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _SyncStatus {
  const _SyncStatus(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;
}
