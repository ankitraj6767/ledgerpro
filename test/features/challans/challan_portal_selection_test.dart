import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_flow_state.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_providers.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_repository.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/challan_screen.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures/portal_result_fixtures.dart';

class _MockChallanRepository extends Mock implements ChallanRepository {}

void main() {
  const projects = [
    InfraProject(
      id: 'project-1',
      organizationId: 'org',
      name: 'Highway Package 3',
      status: InfraProjectStatus.active,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(
      const EPassChallanDraft(
        projectId: 'p',
        financialYear: '2026-2027',
        challanNumber: 'X',
        payload: CapturedPortalPayload(),
      ),
    );
  });

  late _MockChallanRepository repository;

  setUp(() {
    repository = _MockChallanRepository();
    when(
      () => repository.challanExists(
        organizationId: any(named: 'organizationId'),
        financialYear: any(named: 'financialYear'),
        challanNumber: any(named: 'challanNumber'),
        sourcePortal: any(named: 'sourcePortal'),
      ),
    ).thenAnswer((_) async => null);
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        challanRepositoryProvider.overrideWithValue(repository),
        infraWorkspaceProvider.overrideWith(
          (ref) async => const InfraWorkspaceSession(
            organization: Organization(id: 'org', name: 'Test Org'),
            role: OrgMemberRole.owner,
          ),
        ),
        challansProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('flow portal selection', () {
    test('defaults to Bihar so existing behaviour is unchanged', () {
      final container = makeContainer();

      expect(
        container.read(challanFlowControllerProvider).portal,
        ChallanPortal.bihar,
      );
    });

    test('selecting Jharkhand tags the draft with its source_portal', () async {
      final container = makeContainer();
      final controller = container.read(challanFlowControllerProvider.notifier);

      controller.selectPortal(ChallanPortal.jharkhand);
      controller.selectProject('project-1');
      controller.selectFinancialYear('2026-2027');
      controller.setChallanNumber('JH/2026/0012345');
      await controller.continueFromSelection();

      final captured = await controller.captureFromPortal(
        () async => PortalFixtures.jharkhandFilled,
      );
      expect(captured, isTrue);

      final draft = container.read(challanFlowControllerProvider).toDraft();
      expect(draft!.sourcePortal, 'jharkhand_minerals_portal');
      expect(draft.portalUrl, ChallanPortal.jharkhand.url);
      expect(
        draft.verificationStatus,
        ChallanVerificationStatus.portalCaptured,
      );
    });

    test('the duplicate pre-check is scoped to the selected portal', () async {
      final container = makeContainer();
      final controller = container.read(challanFlowControllerProvider.notifier);

      controller.selectPortal(ChallanPortal.jharkhand);
      controller.selectProject('project-1');
      controller.setChallanNumber('JH/2026/0012345');
      await controller.continueFromSelection();

      // The same number on the other portal must not be treated as a duplicate,
      // which is why source_portal is part of the lookup (and of the DB key).
      verify(
        () => repository.challanExists(
          organizationId: 'org',
          financialYear: any(named: 'financialYear'),
          challanNumber: 'JH/2026/0012345',
          sourcePortal: 'jharkhand_minerals_portal',
        ),
      ).called(1);
    });

    test('switching portal discards a capture from the previous one', () async {
      final container = makeContainer();
      final controller = container.read(challanFlowControllerProvider.notifier);

      controller.selectProject('project-1');
      controller.setChallanNumber('2413812606031238531');
      await controller.continueFromSelection();
      await controller.captureFromPortal(
        () async => PortalFixtures.realPortalFilled,
      );
      expect(container.read(challanFlowControllerProvider).hasCapture, isTrue);

      controller.selectPortal(ChallanPortal.jharkhand);

      final state = container.read(challanFlowControllerProvider);
      // A Bihar capture must never be saved against Jharkhand.
      expect(state.hasCapture, isFalse);
      expect(state.captureResult, isNull);
      expect(state.step, ChallanFlowStep.selection);
      expect(state.portal, ChallanPortal.jharkhand);
    });

    test('re-selecting the same portal is a no-op', () async {
      final container = makeContainer();
      final controller = container.read(challanFlowControllerProvider.notifier);

      controller.selectProject('project-1');
      controller.setChallanNumber('2413812606031238531');
      await controller.continueFromSelection();
      await controller.captureFromPortal(
        () async => PortalFixtures.realPortalFilled,
      );

      controller.selectPortal(ChallanPortal.bihar);

      expect(container.read(challanFlowControllerProvider).hasCapture, isTrue);
    });

    test('the portal survives startAnother and reset', () async {
      final container = makeContainer();
      final controller = container.read(challanFlowControllerProvider.notifier);

      controller.selectPortal(ChallanPortal.jharkhand);
      controller.startAnother();
      expect(
        container.read(challanFlowControllerProvider).portal,
        ChallanPortal.jharkhand,
      );

      controller.reset();
      expect(
        container.read(challanFlowControllerProvider).portal,
        ChallanPortal.jharkhand,
      );
    });

    test('a Bihar capture is rejected while Jharkhand is selected', () async {
      final container = makeContainer();
      final controller = container.read(challanFlowControllerProvider.notifier);

      controller.selectPortal(ChallanPortal.jharkhand);
      controller.selectProject('project-1');
      controller.setChallanNumber('2413812606031238531');
      await controller.continueFromSelection();

      // Bihar markup read through the Jharkhand id map: the Bihar-only ids are
      // absent, so this must not silently produce a capture.
      final captured = await controller.captureFromPortal(
        () async => PortalFixtures.englishLabelRows,
      );

      expect(captured, isFalse);
    });
  });

  group('portal selector UI', () {
    Future<void> pump(WidgetTester tester) async {
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
            challansProvider.overrideWith((ref) async => const []),
            networkOnlineProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: ChallanScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows a State portal dropdown defaulting to Bihar', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('State portal'), findsOneWidget);
      expect(find.text('Bihar'), findsWidgets);
      expect(find.text('Opens khanansoft.bihar.gov.in'), findsOneWidget);
    });

    testWidgets('offers both Bihar and Jharkhand', (tester) async {
      await pump(tester);

      await tester.tap(find.text('State portal'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<ChallanPortal>));
      await tester.pumpAndSettle();

      expect(find.text('Jharkhand'), findsWidgets);
      expect(find.text('Bihar'), findsWidgets);
    });

    testWidgets('choosing Jharkhand updates the host and field labels', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byType(DropdownButtonFormField<ChallanPortal>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jharkhand').last);
      await tester.pumpAndSettle();

      expect(
        find.text('Opens mineralsportal.jharkhand.gov.in'),
        findsOneWidget,
      );
      // Jharkhand calls it a Pass number.
      expect(find.text('Pass number'), findsOneWidget);
      expect(find.text('Challan number'), findsNothing);
    });

    testWidgets('the Jharkhand portal step mentions its CAPTCHA', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byType(DropdownButtonFormField<ChallanPortal>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jharkhand').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select a project'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highway Package 3').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(
          TextField,
          ChallanPortal.jharkhand.challanNumberHint,
        ),
        'JH/2026/0012345',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('mineralsportal.jharkhand.gov.in'), findsOneWidget);
      expect(
        find.textContaining('You are viewing the Jharkhand Government portal'),
        findsOneWidget,
      );
      expect(find.textContaining('You type the CAPTCHA'), findsOneWidget);
      expect(find.text('Open Jharkhand Portal'), findsOneWidget);
    });

    testWidgets('the Bihar portal step does not mention typing a CAPTCHA', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('Select a project'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highway Package 3').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, ChallanPortal.bihar.challanNumberHint),
        '2413812606031238531',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('You are viewing the Bihar Government portal'),
        findsOneWidget,
      );
      expect(find.textContaining('You type the CAPTCHA'), findsNothing);
      expect(find.text('Open Bihar Portal'), findsOneWidget);
    });

    testWidgets('the Madhya Pradesh portal step matches the MP page', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byType(DropdownButtonFormField<ChallanPortal>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Madhya Pradesh').last);
      await tester.pumpAndSettle();

      expect(find.text('Opens ekhanij.mp.gov.in'), findsOneWidget);
      // MP calls it an eTP number.
      expect(find.text('eTP number'), findsOneWidget);
      expect(find.text('Challan number'), findsNothing);

      await tester.tap(find.text('Select a project'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highway Package 3').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(
          TextField,
          ChallanPortal.madhyaPradesh.challanNumberHint,
        ),
        '1234567890',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('ekhanij.mp.gov.in'), findsOneWidget);
      expect(find.textContaining('You type the CAPTCHA'), findsOneWidget);
      // MP's submit button says Verify, and its page reloads once while it
      // switches into eTP-number search mode.
      expect(find.textContaining('Verify button'), findsOneWidget);
      expect(find.textContaining('The portal reloads once'), findsOneWidget);
      // The "every field reads NA" warning is Bihar/Jharkhand only.
      expect(find.textContaining('reads "NA"'), findsNothing);
      expect(find.text('Open Madhya Pradesh Portal'), findsOneWidget);
    });
  });
}
