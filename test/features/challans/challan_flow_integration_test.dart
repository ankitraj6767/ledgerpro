import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_flow_controller.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_flow_state.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_providers.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_repository.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_exceptions.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures/portal_result_fixtures.dart';

class _MockChallanRepository extends Mock implements ChallanRepository {}

/// End-to-end exercise of the five-step journey against a local HTML fixture.
///
/// Nothing here contacts the live government portal or a real Supabase project:
/// the portal is a static fixture string and the repository is mocked.
void main() {
  setUpAll(() {
    registerFallbackValue(
      const EPassChallanDraft(
        projectId: 'p',
        financialYear: '2026-2027',
        challanNumber: 'BR1',
        payload: CapturedPortalPayload(),
      ),
    );
  });

  late _MockChallanRepository repository;
  late ProviderContainer container;

  EPassChallan savedRow(EPassChallanDraft draft) => EPassChallan(
    id: 'saved-1',
    organizationId: 'org',
    projectId: draft.projectId,
    financialYear: draft.financialYear,
    challanNumber: draft.challanNumber,
    normalizedChallanNumber: draft.normalizedChallanNumber,
    selectedMaterialType: draft.selectedMaterialType,
    portalMineralName: draft.payload.mineralName ?? '',
    quantity: draft.payload.quantity ?? 0,
    quantityUnit: draft.payload.quantityUnit ?? 'MT',
    vehicleNumber: draft.payload.vehicleNumber ?? '',
    normalizedVehicleNumber: ChallanText.normalizeToken(
      draft.payload.vehicleNumber ?? '',
    ),
    verificationStatus: draft.verificationStatus,
    verificationMethod: draft.verificationMethod,
    challanDate: draft.payload.challanDate,
    capturedAt: draft.payload.capturedAt,
    createdAt: DateTime.utc(2026, 5, 12, 10),
  );

  setUp(() {
    repository = _MockChallanRepository();
    when(
      () => repository.challanExists(
        organizationId: any(named: 'organizationId'),
        financialYear: any(named: 'financialYear'),
        challanNumber: any(named: 'challanNumber'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repository.recordDuplicateBlocked(
        projectId: any(named: 'projectId'),
        challanNumber: any(named: 'challanNumber'),
      ),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
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
  });

  ChallanFlowController controller() =>
      container.read(challanFlowControllerProvider.notifier);
  ChallanFlowState state() => container.read(challanFlowControllerProvider);

  /// Steps 1 and 2.
  Future<void> completeSelection({
    String challan = 'BR2026001234',
    String year = '2026-2027',
    ChallanMaterialType? material = ChallanMaterialType.sand,
  }) async {
    controller().selectProject('project-1');
    controller().selectMaterial(material);
    controller().selectFinancialYear(year);
    controller().setChallanNumber(challan);
    await controller().continueFromSelection();
  }

  group('happy path', () {
    test('capture → preview → save stores a portal_captured record', () async {
      when(() => repository.createCapturedChallan(any())).thenAnswer((
        invocation,
      ) async {
        final draft = invocation.positionalArguments.first as EPassChallanDraft;
        return savedRow(draft);
      });

      // Step 1 + 2.
      await completeSelection();
      expect(state().step, ChallanFlowStep.portal);

      // Step 3 — capture from the fixture "portal".
      final captured = await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );

      expect(captured, isTrue);
      expect(state().step, ChallanFlowStep.preview);
      expect(state().hasCapture, isTrue);
      expect(state().errorMessage, isNull);

      // Step 4 — every mandatory field is present and read-only.
      final payload = state().payload!;
      expect(payload.challanNumber, 'BR2026001234');
      expect(payload.vehicleNumber, 'BR 01 GH 4567');
      expect(payload.mineralName, 'Sand (Balu)');
      expect(payload.quantity, 12.5);
      expect(payload.quantityUnit, 'MT');
      expect(payload.responseHash, isNotNull);
      expect(state().hasMaterialMismatch, isFalse);

      // Step 5 — save.
      final saved = await controller().save();

      expect(saved, isNotNull);
      expect(
        saved!.verificationStatus,
        ChallanVerificationStatus.portalCaptured,
      );
      expect(
        saved.verificationMethod,
        ChallanVerificationMethod.webviewHumanVerification,
      );
      expect(state().step, ChallanFlowStep.save);
      expect(state().savedChallan, isNotNull);
      verify(() => repository.createCapturedChallan(any())).called(1);
      verifyNever(() => repository.createManualChallan(any()));
    });

    test(
      'the draft sent to the repository carries both material values',
      () async {
        EPassChallanDraft? sent;
        when(() => repository.createCapturedChallan(any())).thenAnswer((
          invocation,
        ) async {
          sent = invocation.positionalArguments.first as EPassChallanDraft;
          return savedRow(sent!);
        });

        await completeSelection(material: ChallanMaterialType.sand);
        await controller().captureFromPortal(
          () async => PortalFixtures.aspNetLabelIds,
        );
        await controller().save();

        expect(sent, isNotNull);
        expect(sent!.selectedMaterialType, ChallanMaterialType.sand);
        expect(sent!.payload.mineralName, 'Sand (Balu)');
        // Exact decimal text is preserved for the numeric column.
        expect(sent!.payload.quantityText, '12.500');
        expect(sent!.challanNumber, 'BR2026001234');
      },
    );
  });

  group('duplicate prevention', () {
    test(
      'a pre-existing challan blocks step 1 and surfaces the record',
      () async {
        final existing = savedRow(
          const EPassChallanDraft(
            projectId: 'project-1',
            financialYear: '2026-2027',
            challanNumber: 'BR2026001234',
            payload: CapturedPortalPayload(mineralName: 'Sand'),
          ),
        );
        when(
          () => repository.challanExists(
            organizationId: any(named: 'organizationId'),
            financialYear: any(named: 'financialYear'),
            challanNumber: any(named: 'challanNumber'),
          ),
        ).thenAnswer((_) async => existing);

        await completeSelection();

        // Never advanced past step 1.
        expect(state().step, ChallanFlowStep.selection);
        expect(state().duplicateOf, isNotNull);
        expect(state().duplicateOf!.id, existing.id);
      },
    );

    test(
      'the server rejection is the authority, even if the pre-check passed',
      () async {
        when(
          () => repository.createCapturedChallan(any()),
        ).thenThrow(ChallanException.duplicate('BR2026001234'));

        await completeSelection();
        await controller().captureFromPortal(
          () async => PortalFixtures.aspNetLabelIds,
        );
        final saved = await controller().save();

        expect(saved, isNull);
        expect(state().errorMessage, 'This challan is already saved');
        // The user stays on the preview with their capture intact.
        expect(state().step, ChallanFlowStep.preview);
        expect(state().hasCapture, isTrue);
      },
    );

    test('a blocked duplicate is written to the audit trail', () async {
      when(
        () => repository.createCapturedChallan(any()),
      ).thenThrow(ChallanException.duplicate('BR2026001234'));

      await completeSelection();
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );
      await controller().save();

      verify(
        () => repository.recordDuplicateBlocked(
          projectId: 'project-1',
          challanNumber: 'BR2026001234',
        ),
      ).called(1);
    });

    test('differently formatted numbers are treated as the same challan', () {
      expect(
        ChallanText.normalizeToken('br 2026 001234'),
        ChallanText.normalizeToken('BR-2026-001234'),
      );
    });
  });

  group('rejected captures never reach the database', () {
    Future<void> expectNoSave(String html, ChallanErrorKind kind) async {
      await completeSelection();
      final captured = await controller().captureFromPortal(() async => html);

      expect(captured, isFalse);
      expect(state().step, ChallanFlowStep.verification);
      expect(state().hasCapture, isFalse);
      expect(state().errorMessage, isNotNull);

      // Saving is refused because there is no capture.
      final saved = await controller().save();
      expect(saved, isNull);
      verifyNever(() => repository.createCapturedChallan(any()));
    }

    test('un-searched page', () async {
      await expectNoSave(
        PortalFixtures.searchFormOnly,
        ChallanErrorKind.captchaNotCompleted,
      );
    });

    test('no record found', () async {
      await expectNoSave(
        PortalFixtures.noRecord,
        ChallanErrorKind.challanNotFound,
      );
    });

    test('changed portal layout', () async {
      await expectNoSave(
        PortalFixtures.layoutChangedPartial,
        ChallanErrorKind.portalLayoutChanged,
      );
    });

    test('mismatched challan number', () async {
      controller().selectProject('project-1');
      controller().setChallanNumber('BR2026009999');
      await controller().continueFromSelection();

      final captured = await controller().captureFromPortal(
        () async => PortalFixtures.mismatchedChallan,
      );

      expect(captured, isFalse);
      expect(state().errorMessage, contains('BR2026000001'));
      verifyNever(() => repository.createCapturedChallan(any()));
    });
  });

  group('material mismatch', () {
    test('save is blocked until the user explicitly confirms', () async {
      when(() => repository.createCapturedChallan(any())).thenAnswer(
        (invocation) async =>
            savedRow(invocation.positionalArguments.first as EPassChallanDraft),
      );

      // Portal says Sand; the user selected Brick.
      await completeSelection(material: ChallanMaterialType.brick);
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );

      expect(state().hasMaterialMismatch, isTrue);
      expect(state().needsMaterialConfirmation, isTrue);

      final blocked = await controller().save();
      expect(blocked, isNull);
      expect(state().errorMessage, contains('Confirm the material'));
      verifyNever(() => repository.createCapturedChallan(any()));

      controller().acknowledgeMaterialMismatch();
      expect(state().needsMaterialConfirmation, isFalse);

      final saved = await controller().save();
      expect(saved, isNotNull);
      // Neither value was overwritten.
      expect(saved!.selectedMaterialType, ChallanMaterialType.brick);
      expect(saved.portalMineralName, 'Sand (Balu)');
    });
  });

  group('manual fallback', () {
    test('a corrected entry is downgraded to manual_unverified', () async {
      when(() => repository.createManualChallan(any())).thenAnswer((
        invocation,
      ) async {
        final draft = invocation.positionalArguments.first as EPassChallanDraft;
        expect(
          draft.verificationStatus,
          ChallanVerificationStatus.portalCaptured,
          reason: 'the repository performs the downgrade',
        );
        return savedRow(
          draft.copyWith(
            verificationStatus: ChallanVerificationStatus.manualUnverified,
            verificationMethod: ChallanVerificationMethod.manualEntry,
          ),
        );
      });

      await completeSelection();
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );
      // The user needs to correct something.
      controller().switchToManualEntry();

      final saved = await controller().save();

      expect(saved, isNotNull);
      expect(
        saved!.verificationStatus,
        ChallanVerificationStatus.manualUnverified,
      );
      verify(() => repository.createManualChallan(any())).called(1);
      verifyNever(() => repository.createCapturedChallan(any()));
    });

    test('an offline manual payload is never portal_captured', () async {
      controller().setOffline(true);
      controller().selectProject('project-1');
      controller().setChallanNumber('BR2026008888');
      controller().setManualPayload(
        CapturedPortalPayload(
          challanNumber: 'BR2026008888',
          challanDate: DateTime.utc(2026, 5, 12),
          vehicleNumber: 'BR07XX1234',
          mineralName: 'Stone',
          quantity: 9,
          quantityText: '9',
        ),
      );

      expect(
        state().captureResult!.status,
        ChallanVerificationStatus.manualUnverified,
      );
      expect(
        state().captureResult!.method,
        ChallanVerificationMethod.manualEntry,
      );
      expect(state().manualFallback, isTrue);
    });

    test('offline skips the duplicate pre-check instead of failing', () async {
      controller().setOffline(true);
      await completeSelection();

      expect(state().step, ChallanFlowStep.portal);
      verifyNever(
        () => repository.challanExists(
          organizationId: any(named: 'organizationId'),
          financialYear: any(named: 'financialYear'),
          challanNumber: any(named: 'challanNumber'),
        ),
      );
    });
  });

  group('step 1 validation', () {
    test('a missing project blocks the flow', () async {
      controller().setChallanNumber('BR2026001234');
      final advanced = await controller().continueFromSelection();

      expect(advanced, isFalse);
      expect(state().step, ChallanFlowStep.selection);
      expect(state().errorMessage, 'Select a project to continue.');
    });

    test('a challan number with no letters or digits is rejected', () async {
      controller().selectProject('project-1');
      controller().setChallanNumber('---/// ');
      final advanced = await controller().continueFromSelection();

      expect(advanced, isFalse);
      expect(state().errorMessage, contains('valid challan number'));
    });

    test('the financial year defaults to the current Indian FY', () {
      expect(state().financialYear, FinancialYear.current());
    });
  });

  group('save failures keep the capture recoverable', () {
    test('a permission failure returns the user to the preview', () async {
      when(
        () => repository.createCapturedChallan(any()),
      ).thenThrow(ChallanException.permissionDenied);

      await completeSelection();
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );
      final saved = await controller().save();

      expect(saved, isNull);
      expect(state().step, ChallanFlowStep.preview);
      expect(state().hasCapture, isTrue);
      expect(state().errorMessage, contains('permission'));
      expect(state().isSaving, isFalse);
    });

    test('an unexpected error is reported without leaking internals', () async {
      when(
        () => repository.createCapturedChallan(any()),
      ).thenThrow(StateError('internal socket 0x7ffee sensitive'));

      await completeSelection();
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );
      final saved = await controller().save();

      expect(saved, isNull);
      expect(state().errorMessage, isNot(contains('socket')));
      expect(state().errorMessage, isNot(contains('sensitive')));
    });
  });

  group('flow navigation', () {
    test('retry returns to the portal and clears the stale capture', () async {
      await completeSelection();
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );
      expect(state().hasCapture, isTrue);

      controller().retryCapture();

      expect(state().step, ChallanFlowStep.portal);
      expect(state().captureResult, isNull);
    });

    test('startAnother keeps the project, material and year', () async {
      when(() => repository.createCapturedChallan(any())).thenAnswer(
        (invocation) async =>
            savedRow(invocation.positionalArguments.first as EPassChallanDraft),
      );

      await completeSelection(material: ChallanMaterialType.sand);
      await controller().captureFromPortal(
        () async => PortalFixtures.aspNetLabelIds,
      );
      await controller().save();

      controller().startAnother();

      expect(state().step, ChallanFlowStep.selection);
      expect(state().projectId, 'project-1');
      expect(state().materialType, ChallanMaterialType.sand);
      expect(state().financialYear, '2026-2027');
      // But not the previous challan or capture.
      expect(state().challanNumber, isEmpty);
      expect(state().captureResult, isNull);
      expect(state().savedChallan, isNull);
    });

    test('reset clears everything', () async {
      await completeSelection();
      controller().reset();

      expect(state().step, ChallanFlowStep.selection);
      expect(state().projectId, isNull);
      expect(state().challanNumber, isEmpty);
    });
  });
}
