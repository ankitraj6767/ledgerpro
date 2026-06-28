import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/infra_home_screen.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  final projects = [
    const InfraProject(
      id: 'active',
      organizationId: 'org',
      name: 'Active Project',
      status: InfraProjectStatus.active,
      totalEstimatedCostPaise: 10000,
      totalInvestmentPaise: 9000,
      totalInvestmentReturnedPaise: 3000,
    ),
    const InfraProject(
      id: 'planning',
      organizationId: 'org',
      name: 'Planning Project',
      status: InfraProjectStatus.planning,
    ),
    const InfraProject(
      id: 'completed',
      organizationId: 'org',
      name: 'Completed Project',
      status: InfraProjectStatus.completed,
    ),
  ];

  Future<void> pumpHome(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardCacheWriterProvider.overrideWith((ref) {}),
          cachedDashboardProvider.overrideWithValue(null),
          currentOrgPermissionsProvider.overrideWithValue(
            const OrgPermissions(OrgMemberRole.owner),
          ),
          infraWorkspaceProvider.overrideWith(
            (ref) async => const InfraWorkspaceSession(
              organization: Organization(id: 'org', name: 'Test Org'),
              role: OrgMemberRole.owner,
            ),
          ),
          dashboardSummaryProvider.overrideWith(
            (ref) async => const InfraDashboardSummary(
              totalProjects: 3,
              activeProjects: 1,
              completedProjects: 1,
              totalInvestmentPaise: 6000,
            ),
          ),
          projectsProvider.overrideWith((ref) async => projects),
        ],
        child: const MaterialApp(home: InfraHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('desktop home shows projects of every status', (tester) async {
    await pumpHome(tester, const Size(1400, 1000));

    expect(find.text('My Projects'), findsOneWidget);
    expect(find.text('Active Project'), findsOneWidget);
    expect(find.text('Planning Project'), findsOneWidget);
    expect(find.text('Completed Project'), findsOneWidget);
  });

  testWidgets('mobile project card labels estimated and net investment', (
    tester,
  ) async {
    await pumpHome(tester, const Size(430, 1400));

    expect(find.text('Estimated Cost'), findsWidgets);
    expect(find.text('Net Invested'), findsWidgets);
  });
}
