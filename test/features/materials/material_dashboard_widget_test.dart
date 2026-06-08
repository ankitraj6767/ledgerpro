import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/data/repositories/material_repository.dart';
import 'package:ledgerpro_mobile/features/materials/presentation/materials_module_screen.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:ledgerpro_mobile/shared/models/material_models.dart';

void main() {
  testWidgets('material dashboard matches the mobile materials UX', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpMaterials(
      tester,
      permissions: const OrgPermissions(OrgMemberRole.manager),
    );

    await tester.pumpAndSettle();

    expect(find.text('Electricity Tender - 2024'), findsWidgets);
    expect(find.text('Total Schools'), findsOneWidget);
    expect(find.text('Warehouse Stock Summary'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('My Schools'), findsOneWidget);
    expect(find.text('1 GPS photo'), findsOneWidget);
    expect(find.text('Add School'), findsOneWidget);
    expect(find.text('Material\nIssue'), findsOneWidget);
    expect(find.text('Material\nReceive'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Issue'), findsWidgets);
    expect(find.text('Warehouse'), findsWidgets);
    expect(find.text('Reports'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.dragUntilVisible(
      find.text('Recent Issues'),
      find.byType(Scrollable).first,
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent Issues'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer material dashboard is read-only on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpMaterials(
      tester,
      permissions: const OrgPermissions(OrgMemberRole.customer),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Customer read-only access'), findsOneWidget);
    expect(find.text('Add School'), findsNothing);
    expect(find.text('Material\nIssue'), findsNothing);
    expect(find.text('Material\nReceive'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.dragUntilVisible(
      find.text('Warehouse\nStock'),
      find.byType(Scrollable).first,
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    expect(find.text('Warehouse\nStock'), findsOneWidget);
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('Add School'), findsNothing);
    expect(find.text('Material\nIssue'), findsNothing);
    expect(find.text('Material\nReceive'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpMaterials(
  WidgetTester tester, {
  required OrgPermissions permissions,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentOrgPermissionsProvider.overrideWith((ref) => permissions),
        tendersProvider.overrideWith(
          (ref) async => const [
            Tender(
              id: 'tender',
              organizationId: 'org',
              name: 'Electricity Tender',
              year: 2024,
            ),
          ],
        ),
        districtsProvider.overrideWith(
          (ref) async => const [
            District(
              id: 'district',
              organizationId: 'org',
              name: 'Madhubani',
              state: 'Bihar',
            ),
          ],
        ),
        allWarehousesProvider.overrideWith(
          (ref) async => const [
            Warehouse(
              id: 'warehouse',
              organizationId: 'org',
              name: 'Central Warehouse',
              districtId: 'district',
              isCentral: true,
            ),
          ],
        ),
        warehousesProvider.overrideWith(
          (ref) async => const [
            Warehouse(
              id: 'warehouse',
              organizationId: 'org',
              name: 'Central Warehouse',
              districtId: 'district',
              isCentral: true,
            ),
          ],
        ),
        allSchoolsProvider.overrideWith(
          (ref) async => const [
            School(
              id: 'school',
              organizationId: 'org',
              tenderId: 'tender',
              name: 'Madhubani School - 01',
              districtId: 'district',
              status: 'running',
              progressPercent: 75,
              roomQuantity: 6,
              gpsPhotoPaths: ['org/material-schools/school/photo.jpg'],
            ),
          ],
        ),
        schoolsProvider.overrideWith(
          (ref) async => const [
            School(
              id: 'school',
              organizationId: 'org',
              tenderId: 'tender',
              name: 'Madhubani School - 01',
              districtId: 'district',
              status: 'running',
              progressPercent: 75,
              roomQuantity: 6,
              gpsPhotoPaths: ['org/material-schools/school/photo.jpg'],
            ),
          ],
        ),
        siteManagersProvider.overrideWith(
          (ref) async => const [
            SiteManager(
              id: 'manager',
              organizationId: 'org',
              fullName: 'Ravi Kumar',
            ),
          ],
        ),
        materialItemsProvider.overrideWith(
          (ref) async => const [
            MaterialItem(
              id: 'switch',
              organizationId: 'org',
              name: 'Switch',
              unit: 'Nos.',
            ),
          ],
        ),
        effectiveTenderIdProvider.overrideWith((ref) => 'tender'),
        effectiveWarehouseIdProvider.overrideWith((ref) => 'warehouse'),
        materialDashboardSummaryProvider.overrideWith(
          (ref) async => const MaterialDashboardSummary(
            totalSchools: 250,
            runningSchools: 180,
            completedSchools: 120,
            pendingSchools: 70,
            totalItemsInWarehouse: 18,
            lowStockItems: 4,
          ),
        ),
        warehouseStockSummaryProvider.overrideWith(
          (ref) async => const [
            WarehouseStockRow(
              materialId: 'switch',
              materialName: 'Switch',
              unit: 'Nos.',
              totalReceived: 5000,
              totalIssued: 2950,
              remainingStock: 2050,
            ),
          ],
        ),
        schoolRequirementIssueProvider.overrideWith(
          (ref) async => const [
            SchoolRequirementIssueRow(
              schoolId: 'school',
              schoolName: 'Madhubani School - 01',
              totalItems: 8,
              requiredPercent: 100,
              issuedPercent: 75,
              pendingPercent: 25,
              status: 'partial',
            ),
          ],
        ),
        recentMaterialIssuesProvider.overrideWith(
          (ref) async => [
            RecentMaterialIssue(
              issueId: 'issue',
              managerName: 'Ravi Kumar',
              schoolName: 'Madhubani School - 01',
              issueDate: DateTime(2024, 5, 2),
              summaryText: 'Received: 15 Switch, 20 LED Bulb, 10 Fan',
              materialCount: 3,
              totalQuantity: 45,
            ),
          ],
        ),
        lowStockAlertsProvider.overrideWith((ref) async => const []),
        managerMaterialIssueSummaryProvider.overrideWith(
          (ref) async => const [],
        ),
      ],
      child: const MaterialApp(home: MaterialsModuleScreen()),
    ),
  );
}
