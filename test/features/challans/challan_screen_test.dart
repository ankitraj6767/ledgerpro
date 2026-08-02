import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_providers.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_repository.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/challan_screen.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/widgets/challan_card.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:mocktail/mocktail.dart';

class _MockChallanRepository extends Mock implements ChallanRepository {}

void main() {
  const projects = [
    InfraProject(
      id: 'project-1',
      organizationId: 'org',
      name: 'Highway Package 3',
      status: InfraProjectStatus.active,
    ),
    InfraProject(
      id: 'project-2',
      organizationId: 'org',
      name: 'Bridge Works',
      status: InfraProjectStatus.active,
    ),
  ];

  EPassChallan challan({
    String id = 'challan-1',
    String number = 'BR2026001234',
    ChallanVerificationStatus status = ChallanVerificationStatus.portalCaptured,
  }) => EPassChallan(
    id: id,
    organizationId: 'org',
    projectId: 'project-1',
    financialYear: '2026-2027',
    challanNumber: number,
    normalizedChallanNumber: number,
    portalMineralName: 'Sand',
    quantity: 12.5,
    vehicleNumber: 'BR 01 GH 4567',
    normalizedVehicleNumber: 'BR01GH4567',
    verificationStatus: status,
    verificationMethod: status == ChallanVerificationStatus.portalCaptured
        ? ChallanVerificationMethod.webviewHumanVerification
        : ChallanVerificationMethod.manualEntry,
    challanDate: DateTime.utc(2026, 5, 12),
    projectName: 'Highway Package 3',
    createdAt: DateTime.utc(2026, 5, 12, 10),
  );

  late _MockChallanRepository repository;

  setUp(() {
    repository = _MockChallanRepository();
    when(
      () => repository.challanExists(
        organizationId: any(named: 'organizationId'),
        financialYear: any(named: 'financialYear'),
        challanNumber: any(named: 'challanNumber'),
      ),
    ).thenAnswer((_) async => null);
  });

  Future<void> pumpChallanScreen(
    WidgetTester tester, {
    Size size = const Size(430, 1400),
    OrgMemberRole role = OrgMemberRole.owner,
    List<EPassChallan> challans = const [],
    bool online = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentOrgPermissionsProvider.overrideWithValue(
            OrgPermissions(role, currentUserId: 'user-1'),
          ),
          infraWorkspaceProvider.overrideWith(
            (ref) async => const InfraWorkspaceSession(
              organization: Organization(id: 'org', name: 'Test Org'),
              role: OrgMemberRole.owner,
            ),
          ),
          projectsProvider.overrideWith((ref) async => projects),
          challanRepositoryProvider.overrideWithValue(repository),
          challansProvider.overrideWith((ref) async => challans),
          networkOnlineProvider.overrideWithValue(online),
        ],
        child: const MaterialApp(home: ChallanScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('step 1 — selection', () {
    testWidgets('renders the five-step indicator and step 1 fields', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      expect(find.text('E-Pass Challan'), findsOneWidget);
      expect(find.textContaining('Step 1 of 5'), findsOneWidget);
      expect(find.text('Project & Material'), findsWidgets);
      expect(find.text('Select a project'), findsOneWidget);
      expect(find.text('Material type'), findsOneWidget);
      expect(find.text('Financial year'), findsOneWidget);
      expect(find.text('Challan number'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('offers every required material option', (tester) async {
      await pumpChallanScreen(tester);

      for (final label in [
        'Sand',
        'Stone',
        'Brick',
        'Aggregate',
        'Boulder',
        'Dust',
        'Other',
      ]) {
        expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
      }
    });

    testWidgets('Continue stays disabled until project and challan are set', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      FilledButton continueButton() => tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Continue'),
          matching: find.byType(FilledButton),
        ),
      );

      expect(continueButton().onPressed, isNull);

      // Challan number alone is not enough — a project is mandatory.
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 2413812606031238531'),
        'BR2026001234',
      );
      await tester.pumpAndSettle();
      expect(continueButton().onPressed, isNull);

      await tester.tap(find.text('Select a project'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highway Package 3').last);
      await tester.pumpAndSettle();

      expect(continueButton().onPressed, isNotNull);
    });

    testWidgets('challan number is upper-cased as it is typed', (tester) async {
      await pumpChallanScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 2413812606031238531'),
        'br-2026/1234',
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'e.g. 2413812606031238531'),
      );
      // Original separators are preserved; only casing changes.
      expect(field.controller!.text, 'BR-2026/1234');
    });

    testWidgets('defaults the financial year to the current Indian FY', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      final now = DateTime.now();
      final expected = now.month >= 4
          ? '${now.year}-${now.year + 1}'
          : '${now.year - 1}-${now.year}';

      expect(find.text(expected), findsWidgets);
    });
  });

  group('step 2 — portal', () {
    Future<void> advanceToPortal(WidgetTester tester) async {
      await tester.tap(find.text('Select a project'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highway Package 3').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 2413812606031238531'),
        'BR2026001234',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the portal step with the security notice', (
      tester,
    ) async {
      await pumpChallanScreen(tester);
      await advanceToPortal(tester);

      expect(find.textContaining('Step 2 of 5'), findsOneWidget);
      expect(find.text('khanansoft.bihar.gov.in'), findsOneWidget);
      expect(
        find.textContaining('LedgerPro never stores your government'),
        findsOneWidget,
      );
      expect(
        find.textContaining('press the portal\'s own Search button'),
        findsOneWidget,
      );
      // Users must be told that "NA" means the search has not returned yet.
      expect(find.textContaining('reads "NA"'), findsOneWidget);
    });

    testWidgets('offline disables the portal and offers manual entry', (
      tester,
    ) async {
      await pumpChallanScreen(tester, online: false);
      await advanceToPortal(tester);

      expect(find.text('Internet required'), findsOneWidget);
      expect(
        find.textContaining('needs an internet connection'),
        findsOneWidget,
      );
      expect(find.text('Open Bihar Portal'), findsNothing);
      expect(find.text('Add as manual entry instead'), findsOneWidget);
    });
  });

  group('step 4 — preview', () {
    testWidgets('shows captured fields read-only with the capture status', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChallanScreen)),
      );
      final controller = container.read(challanFlowControllerProvider.notifier);
      controller.selectProject('project-1');
      controller.setChallanNumber('BR2026001234');
      controller.setManualPayload(
        CapturedPortalPayload(
          challanNumber: 'BR2026001234',
          challanDate: DateTime.utc(2026, 5, 12),
          vehicleNumber: 'BR 01 GH 4567',
          mineralName: 'Sand',
          quantity: 12.5,
          quantityText: '12.500',
          quantityUnit: 'MT',
          capturedAt: DateTime.utc(2026, 5, 12, 10),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Auto Fetch & Preview'), findsWidgets);
      expect(find.text('Captured from portal'), findsOneWidget);
      expect(find.text('read-only'), findsOneWidget);
      expect(find.text('BR2026001234'), findsWidgets);
      expect(find.text('BR 01 GH 4567'), findsWidgets);
      expect(find.text('Confirm & save'), findsOneWidget);
      expect(find.text('Return to portal'), findsOneWidget);
      expect(find.text('Retry capture'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('a material mismatch blocks saving until confirmed', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChallanScreen)),
      );
      final controller = container.read(challanFlowControllerProvider.notifier);
      controller.selectProject('project-1');
      controller.setChallanNumber('BR2026001234');
      controller.selectMaterial(ChallanMaterialType.brick);
      controller.setManualPayload(
        CapturedPortalPayload(
          challanNumber: 'BR2026001234',
          challanDate: DateTime.utc(2026, 5, 12),
          vehicleNumber: 'BR01GH4567',
          mineralName: 'Sand',
          quantity: 12.5,
          quantityText: '12.500',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Material differs from the portal'), findsOneWidget);
      expect(find.textContaining('Both values will be stored'), findsOneWidget);

      final saveButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Confirm & save'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(saveButton.onPressed, isNull);

      await tester.tap(find.text('I understand, keep both values'));
      await tester.pumpAndSettle();

      expect(find.text('Difference confirmed'), findsOneWidget);
      final enabled = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Confirm & save'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(enabled.onPressed, isNotNull);
    });
  });

  group('challan list', () {
    testWidgets('empty state uses the specified copy and action', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      expect(find.text('No challans saved yet'), findsOneWidget);
      expect(
        find.text(
          'Verify an e-Pass challan from the Bihar Government portal to add a '
          'material entry.',
        ),
        findsOneWidget,
      );
      expect(find.text('Add Challan'), findsOneWidget);
    });

    testWidgets('saved challans render with status and capture method', (
      tester,
    ) async {
      await pumpChallanScreen(
        tester,
        challans: [
          challan(),
          challan(
            id: 'challan-2',
            number: 'BR2026005555',
            status: ChallanVerificationStatus.manualUnverified,
          ),
        ],
      );

      expect(find.byType(ChallanCard), findsNWidgets(2));
      expect(find.text('BR2026001234'), findsOneWidget);
      expect(find.text('BR2026005555'), findsOneWidget);
      expect(find.text('Portal captured'), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Portal (human verified)'), findsOneWidget);
      expect(find.text('Manual entry'), findsOneWidget);
      expect(find.text('Highway Package 3'), findsWidgets);
      expect(find.text('12.5 MT'), findsWidgets);
    });

    testWidgets('allows selecting multiple challans for the PDF export', (
      tester,
    ) async {
      await pumpChallanScreen(
        tester,
        challans: [
          challan(),
          challan(id: 'challan-2', number: 'BR2026005555'),
        ],
      );

      Finder checkboxFor(int index) => find.descendant(
        of: find.byType(ChallanCard).at(index),
        matching: find.byType(Checkbox),
      );

      await tester.tap(checkboxFor(0));
      await tester.pumpAndSettle();
      expect(find.text('1 challan(s) selected'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.picture_as_pdf_outlined),
            )
            .tooltip,
        'Download selected challans',
      );

      await tester.tap(checkboxFor(1));
      await tester.pumpAndSettle();
      expect(find.text('2 challan(s) selected'), findsOneWidget);
    });

    testWidgets('shows cached challans while the live list refreshes', (
      tester,
    ) async {
      final pendingChallans = Completer<List<EPassChallan>>();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1400);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentOrgPermissionsProvider.overrideWithValue(
              const OrgPermissions(OrgMemberRole.owner),
            ),
            infraWorkspaceProvider.overrideWith(
              (ref) async => const InfraWorkspaceSession(
                organization: Organization(id: 'org', name: 'Test Org'),
                role: OrgMemberRole.owner,
              ),
            ),
            projectsProvider.overrideWith((ref) async => projects),
            challanRepositoryProvider.overrideWithValue(repository),
            challansProvider.overrideWith(
              (ref) => pendingChallans.future,
            ),
            cachedChallansProvider.overrideWithValue([challan()]),
            networkOnlineProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: ChallanScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(ChallanCard), findsOneWidget);
      expect(find.text('BR2026001234'), findsOneWidget);
    });

    testWidgets('the PDF export is offered once there is something to export', (
      tester,
    ) async {
      await pumpChallanScreen(tester, challans: [challan()]);

      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.picture_as_pdf_outlined),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('the PDF export is disabled when the list is empty', (
      tester,
    ) async {
      await pumpChallanScreen(tester);

      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.picture_as_pdf_outlined),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('search and filter controls are available', (tester) async {
      await pumpChallanScreen(tester, challans: [challan()]);

      expect(
        find.widgetWithText(TextField, 'Search challan or vehicle number'),
        findsOneWidget,
      );
      expect(find.text('Project'), findsWidgets);
      expect(find.text('Material'), findsWidgets);
      expect(find.text('Status'), findsWidgets);
      expect(find.text('Date range'), findsWidgets);
    });
  });

  group('permission gating', () {
    testWidgets('a viewer sees the list but not the entry flow', (
      tester,
    ) async {
      await pumpChallanScreen(
        tester,
        role: OrgMemberRole.viewer,
        challans: [challan()],
      );

      expect(find.textContaining('Step 1 of 5'), findsNothing);
      expect(find.text('Project & Material'), findsNothing);
      expect(
        find.textContaining('You can view challans but not add them'),
        findsOneWidget,
      );
      // Reading still works.
      expect(find.byType(ChallanCard), findsOneWidget);
    });

    testWidgets('a customer is read-only', (tester) async {
      await pumpChallanScreen(
        tester,
        role: OrgMemberRole.customer,
        challans: [challan()],
      );

      expect(find.text('Project & Material'), findsNothing);
      expect(find.byType(ChallanCard), findsOneWidget);
    });

    testWidgets('site staff can use the entry flow', (tester) async {
      await pumpChallanScreen(tester, role: OrgMemberRole.siteStaff);

      expect(find.textContaining('Step 1 of 5'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('a user with no org role gets no challan access', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentOrgPermissionsProvider.overrideWithValue(
              const OrgPermissions(null),
            ),
            challanRepositoryProvider.overrideWithValue(repository),
            challansProvider.overrideWith((ref) async => const []),
            networkOnlineProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: ChallanScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No access to challans'), findsOneWidget);
    });
  });

  group('adaptive layout', () {
    testWidgets('desktop shows the flow and the list side by side', (
      tester,
    ) async {
      await pumpChallanScreen(
        tester,
        size: const Size(1500, 1100),
        challans: [challan()],
      );

      expect(find.text('How this works'), findsOneWidget);
      expect(find.text('Recent challans'), findsOneWidget);
      expect(find.byType(ChallanCard), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('tablet renders the full stepper without overflow', (
      tester,
    ) async {
      await pumpChallanScreen(tester, size: const Size(900, 1200));

      expect(find.text('Government Portal'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile renders without horizontal overflow', (tester) async {
      await pumpChallanScreen(tester, size: const Size(360, 900));

      expect(tester.takeException(), isNull);
    });
  });
}
