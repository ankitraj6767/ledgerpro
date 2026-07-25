import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ledgerpro_mobile/app/constants/app_constants.dart';
import 'package:ledgerpro_mobile/core/sync/infra_realtime_service.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/project_detail_screen.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:ledgerpro_mobile/shared/widgets/infra_shell.dart';

void main() {
  const project = InfraProject(
    id: 'project-1',
    organizationId: 'org',
    name: 'Highway Package 3',
    status: InfraProjectStatus.active,
  );

  /// Pumps the real InfraShell behind a GoRouter so the navigation
  /// destinations under test are the production ones.
  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => InfraShell(child: child),
          routes: [
            for (final path in [
              AppRoutes.home,
              AppRoutes.projects,
              AppRoutes.expenses,
              AppRoutes.challans,
              AppRoutes.profile,
            ])
              GoRoute(
                path: path,
                builder: (context, state) =>
                    Scaffold(body: Center(child: Text('screen $path'))),
              ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The shell watches the realtime bridge; stub it so no Supabase
          // client is required.
          infraRealtimeBridgeProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('main navigation', () {
    testWidgets('mobile bottom nav shows Challan instead of Reports', (
      tester,
    ) async {
      await pumpShell(tester, const Size(420, 900));

      expect(find.text('Challan'), findsOneWidget);
      expect(find.text('Reports'), findsNothing);

      // The other four destinations are untouched.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Challan sits at index 3, between Expenses and Profile', (
      tester,
    ) async {
      await pumpShell(tester, const Size(420, 900));

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      final labels = bar.destinations
          .cast<NavigationDestination>()
          .map((d) => d.label)
          .toList();

      expect(labels, ['Home', 'Projects', 'Expenses', 'Challan', 'Profile']);
    });

    testWidgets('tapping Challan navigates to /challans', (tester) async {
      await pumpShell(tester, const Size(420, 900));

      await tester.tap(find.text('Challan'));
      await tester.pumpAndSettle();

      expect(find.text('screen ${AppRoutes.challans}'), findsOneWidget);
    });

    testWidgets('tablet rail shows Challan', (tester) async {
      await pumpShell(tester, const Size(900, 1000));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Challan'), findsWidgets);
      expect(find.text('Reports'), findsNothing);
    });

    testWidgets('desktop sidebar shows Challan and keeps the command bar', (
      tester,
    ) async {
      await pumpShell(tester, const Size(1500, 1000));

      expect(find.text('Challan'), findsWidgets);
      expect(find.text('Reports'), findsNothing);
      // Command bar search field survives.
      expect(find.text('Search projects, expenses, challans'), findsOneWidget);
    });
  });

  group('route constants', () {
    test('challans route is registered', () {
      expect(AppRoutes.challans, '/challans');
      expect(AppRoutes.challanDetail('abc'), '/challans/abc');
      expect(AppRoutes.challanDetailPath, '/challans/:challanId');
    });

    test('reports routes are preserved for backward compatibility', () {
      // The global reports deep link still exists (now a full-screen route).
      expect(AppRoutes.reports, '/reports');
      // Project-level reports are completely untouched.
      expect(AppRoutes.projectReports('p1'), '/projects/p1/reports');
      expect(AppRoutes.projectReportsPath, '/projects/:projectId/reports');
    });

    test('the project detail Reports tab index is unchanged', () {
      expect(AppRoutes.projectDetail('p1', tab: 4), '/projects/p1?tab=4');
      expect(AppRoutes.projectDetailExpensesTab, 3);
    });
  });

  group('project detail tabs are not degraded', () {
    testWidgets('all five tabs including Reports are still present', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1400);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentOrgPermissionsProvider.overrideWithValue(
              const OrgPermissions(OrgMemberRole.owner),
            ),
            projectsProvider.overrideWith((ref) async => [project]),
            projectFinancialSummaryProvider(
              project.id,
            ).overrideWith((ref) async => const ProjectFinancialSummary()),
            projectInvestmentsProvider(
              project.id,
            ).overrideWith((ref) async => const []),
            projectInvestorsProvider(
              project.id,
            ).overrideWith((ref) async => const []),
            investmentReturnsProvider(
              project.id,
            ).overrideWith((ref) async => const []),
            governmentFundsProvider(
              project.id,
            ).overrideWith((ref) async => const []),
            projectExpensesProvider(
              project.id,
            ).overrideWith((ref) async => const []),
            projectNotesProvider(
              project.id,
            ).overrideWith((ref) async => const []),
            projectDetailCacheWriterProvider(project.id).overrideWith((ref) {}),
            cachedProjectDetailProvider(project.id).overrideWithValue(null),
          ],
          child: const MaterialApp(
            home: ProjectDetailScreen(
              projectId: 'project-1',
              initialProject: project,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      final labels = tabBar.tabs.cast<Tab>().map((t) => t.text).toList();

      expect(labels, [
        'Overview',
        'Investors',
        'Government Funds',
        'Expenses',
        'Reports',
      ]);
      expect(labels.length, 5);
    });
  });
}
