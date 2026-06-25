import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/data/repositories/material_repository.dart';
import 'package:ledgerpro_mobile/features/materials/presentation/materials_module_screen.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:ledgerpro_mobile/shared/models/material_models.dart';

void main() {
  testWidgets('material dashboard fits a small phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentOrgPermissionsProvider.overrideWith(
            (ref) => const OrgPermissions(OrgMemberRole.viewer),
          ),
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
          districtsProvider.overrideWith((ref) async => const []),
          allWarehousesProvider.overrideWith(
            (ref) async => const [
              Warehouse(
                id: 'warehouse',
                organizationId: 'org',
                name: 'Central Warehouse',
              ),
            ],
          ),
          warehousesProvider.overrideWith(
            (ref) async => const [
              Warehouse(
                id: 'warehouse',
                organizationId: 'org',
                name: 'Central Warehouse',
              ),
            ],
          ),
          allSchoolsProvider.overrideWith((ref) async => const []),
          schoolsProvider.overrideWith((ref) async => const []),
          siteManagersProvider.overrideWith((ref) async => const []),
          materialItemsProvider.overrideWith((ref) async => const []),
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
          warehouseStockSummaryProvider.overrideWith((ref) async => const []),
          schoolRequirementIssueProvider.overrideWith((ref) async => const []),
          recentMaterialIssuesProvider.overrideWith((ref) async => const []),
          lowStockAlertsProvider.overrideWith((ref) async => const []),
          managerMaterialIssueSummaryProvider.overrideWith(
            (ref) async => const [],
          ),
        ],
        child: const MaterialApp(home: MaterialsModuleScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Material Dashboard'), findsOneWidget);
    expect(find.text('Total Schools'), findsOneWidget);
    expect(find.text('Schools'), findsWidgets);
    expect(find.text('Warehouse'), findsWidgets);
    expect(find.text('Reports'), findsWidgets);

    await tester.tap(find.text('Set up'));
    await tester.pumpAndSettle();

    expect(find.text('Material Setup'), findsOneWidget);
    expect(find.text('Tender'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
