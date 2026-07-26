import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_flow_controller.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_flow_state.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_providers.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_repository.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures/portal_result_fixtures.dart';

class _MockChallanRepository extends Mock implements ChallanRepository {}

/// Covers the delete-then-re-add behaviour.
///
/// Uniqueness now applies to live rows only (partial unique index), so deleting
/// a challan frees its number. The Flutter pre-check must agree with that, or
/// the UI would keep blocking a number the server would happily accept.
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

  EPassChallan row({String id = 'saved-1'}) => EPassChallan(
    id: id,
    organizationId: 'org',
    projectId: 'project-1',
    financialYear: '2026-2027',
    challanNumber: '2413812606031238531',
    normalizedChallanNumber: '2413812606031238531',
    portalMineralName: 'sand',
    quantity: 2,
    vehicleNumber: 'BR06GA1234',
    normalizedVehicleNumber: 'BR06GA1234',
    verificationStatus: ChallanVerificationStatus.portalCaptured,
    verificationMethod: ChallanVerificationMethod.webviewHumanVerification,
    createdAt: DateTime.utc(2026, 7, 26, 10),
  );

  setUp(() {
    repository = _MockChallanRepository();
    when(() => repository.deleteChallan(any())).thenAnswer((_) async {});
    when(
      () => repository.recordDuplicateBlocked(
        projectId: any(named: 'projectId'),
        challanNumber: any(named: 'challanNumber'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => repository.createCapturedChallan(any()),
    ).thenAnswer((invocation) async => row(id: 're-added-1'));

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

  Future<bool> attemptEntry() async {
    controller().selectProject('project-1');
    controller().selectFinancialYear('2026-2027');
    controller().setChallanNumber('2413812606031238531');
    return controller().continueFromSelection();
  }

  group('delete frees the challan number', () {
    test('a live duplicate blocks re-entry', () async {
      when(
        () => repository.challanExists(
          organizationId: any(named: 'organizationId'),
          financialYear: any(named: 'financialYear'),
          challanNumber: any(named: 'challanNumber'),
        ),
      ).thenAnswer((_) async => row());

      final advanced = await attemptEntry();

      expect(advanced, isFalse);
      expect(state().duplicateOf, isNotNull);
      expect(state().step, ChallanFlowStep.selection);
    });

    test('after deletion the same number is accepted again', () async {
      // The repository pre-check excludes deleted rows, so once the row is gone
      // it reports no duplicate.
      when(
        () => repository.challanExists(
          organizationId: any(named: 'organizationId'),
          financialYear: any(named: 'financialYear'),
          challanNumber: any(named: 'challanNumber'),
        ),
      ).thenAnswer((_) async => null);

      await container.read(challanRepositoryProvider).deleteChallan('saved-1');

      final advanced = await attemptEntry();

      expect(advanced, isTrue);
      expect(state().duplicateOf, isNull);
      expect(state().step, ChallanFlowStep.portal);
      verify(() => repository.deleteChallan('saved-1')).called(1);
    });

    test('the full re-add flow completes end to end after deletion', () async {
      when(
        () => repository.challanExists(
          organizationId: any(named: 'organizationId'),
          financialYear: any(named: 'financialYear'),
          challanNumber: any(named: 'challanNumber'),
        ),
      ).thenAnswer((_) async => null);

      await container.read(challanRepositoryProvider).deleteChallan('saved-1');
      await attemptEntry();

      final captured = await controller().captureFromPortal(
        () async => PortalFixtures.realPortalFilled,
      );
      expect(captured, isTrue);

      final saved = await controller().save();

      expect(saved, isNotNull);
      expect(saved!.id, 're-added-1');
      expect(state().savedChallan, isNotNull);
    });

    test('delete errors surface without crashing', () async {
      when(() => repository.deleteChallan(any())).thenThrow(StateError('boom'));

      expect(
        () => container.read(challanRepositoryProvider).deleteChallan('x'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('permissions', () {
    test('only owner and manager may delete', () {
      expect(
        const OrgPermissions(OrgMemberRole.owner).canDeleteChallan,
        isTrue,
      );
      expect(
        const OrgPermissions(OrgMemberRole.manager).canDeleteChallan,
        isTrue,
      );
      expect(
        const OrgPermissions(OrgMemberRole.accountant).canDeleteChallan,
        isFalse,
      );
      expect(
        const OrgPermissions(OrgMemberRole.siteStaff).canDeleteChallan,
        isFalse,
      );
      expect(
        const OrgPermissions(OrgMemberRole.viewer).canDeleteChallan,
        isFalse,
      );
      expect(
        const OrgPermissions(OrgMemberRole.customer).canDeleteChallan,
        isFalse,
      );
    });

    test('deleting does not imply permission to add', () {
      // Viewer can do neither; accountant can add but not delete.
      const accountant = OrgPermissions(OrgMemberRole.accountant);
      expect(accountant.canAddChallan, isTrue);
      expect(accountant.canDeleteChallan, isFalse);
    });
  });

  group('migration contract', () {
    test('the unique index is scoped to live rows only', () {
      // Guards the intent of 20260726090000: uniqueness must be partial so a
      // deleted challan number can be reused.
      final sql = _readMigration();

      expect(sql, contains('drop index if exists'));
      expect(sql, contains('epass_challans_unique_challan_idx'));
      expect(sql, contains('where deleted_at is null'));
    });

    test('the duplicate check in the RPC ignores deleted rows', () {
      expect(_readMigration(), contains('and c.deleted_at is null'));
    });

    test('delete_epass_challan soft-deletes and writes an audit row', () {
      final sql = _readMigration();

      expect(
        sql,
        contains('create or replace function public.delete_epass_challan'),
      );
      expect(sql, contains("'challan_deleted'"));
      expect(sql, contains('set deleted_at = now()'));
      // Restricted to owner/manager.
      expect(sql, contains("array['owner','manager']"));
      // Never granted to anonymous users.
      expect(
        sql,
        contains(
          'revoke execute on function public.delete_epass_challan(uuid) '
          'from public, anon;',
        ),
      );
    });
  });
}

String _readMigration() {
  const path =
      'supabase/migrations/20260726090000_epass_challan_delete_and_reuse.sql';
  return File(path).readAsStringSync();
}
