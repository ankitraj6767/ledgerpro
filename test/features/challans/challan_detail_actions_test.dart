import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_providers.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/challan_detail_screen.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

/// Actions available on the challan detail screen.
///
/// Downloading a PDF is a read-only action, so unlike deleting it must be
/// offered to every role that can open the screen at all.
void main() {
  final challan = EPassChallan(
    id: 'challan-1',
    organizationId: 'org',
    projectId: 'project-1',
    financialYear: '2026-2027',
    challanNumber: '241381260603123853167',
    normalizedChallanNumber: '241381260603123853167',
    portalMineralName: 'SAND',
    quantity: 39.23,
    quantityUnit: 'INMT',
    vehicleNumber: 'BR09PB4263',
    normalizedVehicleNumber: 'BR09PB4263',
    verificationStatus: ChallanVerificationStatus.portalCaptured,
    verificationMethod: ChallanVerificationMethod.webviewHumanVerification,
    challanDate: DateTime.utc(2026, 6, 3, 7, 8),
    projectName: 'Madhubani Bus Stand',
    createdAt: DateTime.utc(2026, 6, 3, 8),
  );

  Future<void> pumpDetail(
    WidgetTester tester, {
    OrgMemberRole role = OrgMemberRole.owner,
    EPassChallan? record,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentOrgPermissionsProvider.overrideWithValue(
            OrgPermissions(role, currentUserId: 'user-1'),
          ),
          projectsProvider.overrideWith((ref) async => const []),
          challanByIdProvider(
            'challan-1',
          ).overrideWith((ref) async => record ?? challan),
        ],
        child: const MaterialApp(
          home: ChallanDetailScreen(challanId: 'challan-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the challan renders with a PDF download action', (tester) async {
    await pumpDetail(tester);

    expect(find.text('Challan Details'), findsOneWidget);
    expect(find.text('241381260603123853167'), findsWidgets);

    final download = find.widgetWithIcon(
      IconButton,
      Icons.picture_as_pdf_outlined,
    );
    expect(download, findsOneWidget);
    expect(tester.widget<IconButton>(download).onPressed, isNotNull);
  });

  testWidgets('a read-only role can still download the PDF but cannot delete', (
    tester,
  ) async {
    await pumpDetail(tester, role: OrgMemberRole.customer);

    expect(
      find.widgetWithIcon(IconButton, Icons.picture_as_pdf_outlined),
      findsOneWidget,
    );
    // No overflow menu means no delete entry.
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('an owner also gets delete alongside the download', (
    tester,
  ) async {
    await pumpDetail(tester);

    expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Download PDF'), findsOneWidget);
    expect(find.text('Delete challan'), findsOneWidget);
  });

  testWidgets('a missing challan offers no actions at all', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentOrgPermissionsProvider.overrideWithValue(
            OrgPermissions(OrgMemberRole.owner, currentUserId: 'user-1'),
          ),
          projectsProvider.overrideWith((ref) async => const []),
          challanByIdProvider('challan-1').overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          home: ChallanDetailScreen(challanId: 'challan-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Challan not found'), findsOneWidget);
    expect(
      find.widgetWithIcon(IconButton, Icons.picture_as_pdf_outlined),
      findsNothing,
    );
  });
}
