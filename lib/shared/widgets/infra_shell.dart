import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';

/// Bottom-navigation shell for the Navdream Infra app:
/// Home · Projects · Expenses · Reports · Profile.
class InfraShell extends StatelessWidget {
  const InfraShell({super.key, required this.child});

  final Widget child;

  static const _routes = [
    AppRoutes.home,
    AppRoutes.projects,
    AppRoutes.expenses,
    AppRoutes.reports,
    AppRoutes.profile,
  ];

  int _indexFor(String path) {
    if (path.startsWith(AppRoutes.projects)) return 1;
    if (path.startsWith(AppRoutes.expenses)) return 2;
    if (path.startsWith(AppRoutes.reports)) return 3;
    if (path.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(path),
        onDestinationSelected: (index) => context.go(_routes[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
