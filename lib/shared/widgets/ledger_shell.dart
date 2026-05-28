import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';

class LedgerShell extends StatelessWidget {
  const LedgerShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFor(path);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_routes[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Parties',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more),
            label: 'More',
          ),
        ],
      ),
    );
  }

  static const _routes = [
    AppRoutes.home,
    AppRoutes.parties,
    AppRoutes.add,
    AppRoutes.reports,
    AppRoutes.more,
  ];

  int _indexFor(String path) {
    if (path.startsWith(AppRoutes.parties)) return 1;
    if (path.startsWith(AppRoutes.add)) return 2;
    if (path.startsWith(AppRoutes.reports)) return 3;
    if (path.startsWith(AppRoutes.more) ||
        path.startsWith(AppRoutes.settings) ||
        path.startsWith(AppRoutes.inventory) ||
        path.startsWith(AppRoutes.invoices) ||
        path.startsWith(AppRoutes.reminders)) {
      return 4;
    }
    return 0;
  }
}
