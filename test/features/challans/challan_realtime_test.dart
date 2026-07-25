import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/sync/infra_realtime_service.dart';
import 'package:ledgerpro_mobile/data/remote/supabase_ledger_api.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_providers.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_repository.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes a real [Ref] bound to the test container so the production
/// invalidation function can be driven exactly as the Realtime bridge does.
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  PostgresChangePayload payload({
    required String table,
    PostgresChangeEvent event = PostgresChangeEvent.insert,
    Map<String, dynamic> newRecord = const {},
    Map<String, dynamic> oldRecord = const {},
  }) => PostgresChangePayload(
    schema: 'public',
    table: table,
    commitTimestamp: DateTime.utc(2026, 5, 12),
    eventType: event,
    newRecord: newRecord,
    oldRecord: oldRecord,
    errors: null,
  );

  group('realtime table registration', () {
    test('epass_challans is subscribed to', () {
      expect(SupabaseLedgerApi.infraRealtimeTables, contains('epass_challans'));
    });

    test('no existing realtime table was removed', () {
      const previouslySubscribed = <String>[
        'organizations',
        'organization_members',
        'infra_projects',
        'investors',
        'project_investments',
        'government_funds',
        'government_fund_receipts',
        'project_expenses',
        'project_notes',
        'project_progress_updates',
        'project_documents',
        'customer_project_assignments',
        'project_audit_logs',
      ];

      expect(
        SupabaseLedgerApi.infraRealtimeTables,
        containsAll(previouslySubscribed),
      );
    });
  });

  group('provider invalidation', () {
    /// Counts how many times each provider was rebuilt.
    late Map<String, int> builds;
    late ProviderContainer container;
    late List<ProviderSubscription<Object?>> subscriptions;

    setUp(() {
      builds = <String, int>{};
      container = ProviderContainer(
        overrides: [
          challanRepositoryProvider.overrideWithValue(
            const _StubChallanRepository(),
          ),
          infraWorkspaceProvider.overrideWith((ref) async {
            builds['workspace'] = (builds['workspace'] ?? 0) + 1;
            return const InfraWorkspaceSession(
              organization: Organization(id: 'org', name: 'Test Org'),
              role: OrgMemberRole.owner,
            );
          }),
          challansProvider.overrideWith((ref) async {
            builds['challans'] = (builds['challans'] ?? 0) + 1;
            return const <EPassChallan>[];
          }),
          projectsProvider.overrideWith((ref) async {
            builds['projects'] = (builds['projects'] ?? 0) + 1;
            return const <InfraProject>[];
          }),
          projectExpensesProvider('project-1').overrideWith((ref) async {
            builds['expenses'] = (builds['expenses'] ?? 0) + 1;
            return const <ProjectExpense>[];
          }),
          challanByIdProvider('challan-1').overrideWith((ref) async {
            builds['challanDetail'] = (builds['challanDetail'] ?? 0) + 1;
            return null;
          }),
        ],
      );
      // Keep everything alive so invalidation triggers a rebuild.
      subscriptions = [
        container.listen(challansProvider, (_, _) {}),
        container.listen(projectsProvider, (_, _) {}),
        container.listen(projectExpensesProvider('project-1'), (_, _) {}),
        container.listen(challanByIdProvider('challan-1'), (_, _) {}),
      ];
      addTearDown(() {
        for (final subscription in subscriptions) {
          subscription.close();
        }
        container.dispose();
      });
    });

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('a challan insert refreshes the challan list', () async {
      await settle();
      final before = builds['challans'];

      invalidateInfraProviders(
        container.read(_refProvider),
        payload(
          table: 'epass_challans',
          newRecord: {'id': 'challan-1', 'project_id': 'project-1'},
        ),
      );
      await settle();

      expect(builds['challans'], greaterThan(before!));
    });

    test('a challan insert refreshes that challan detail provider', () async {
      await settle();
      final before = builds['challanDetail'];

      invalidateInfraProviders(
        container.read(_refProvider),
        payload(
          table: 'epass_challans',
          newRecord: {'id': 'challan-1', 'project_id': 'project-1'},
        ),
      );
      await settle();

      expect(builds['challanDetail'], greaterThan(before!));
    });

    test(
      'a soft-delete arriving as an update still refreshes the list',
      () async {
        await settle();
        final before = builds['challans'];

        invalidateInfraProviders(
          container.read(_refProvider),
          payload(
            table: 'epass_challans',
            event: PostgresChangeEvent.update,
            newRecord: {
              'id': 'challan-1',
              'project_id': 'project-1',
              'deleted_at': '2026-05-12T10:00:00Z',
            },
          ),
        );
        await settle();

        expect(builds['challans'], greaterThan(before!));
      },
    );

    test('a delete payload with only oldRecord is handled', () async {
      await settle();
      final before = builds['challans'];

      invalidateInfraProviders(
        container.read(_refProvider),
        payload(
          table: 'epass_challans',
          event: PostgresChangeEvent.delete,
          oldRecord: {'id': 'challan-1', 'project_id': 'project-1'},
        ),
      );
      await settle();

      expect(builds['challans'], greaterThan(before!));
    });

    test(
      'a challan change does NOT churn unrelated project providers',
      () async {
        await settle();
        final projectsBefore = builds['projects'];
        final expensesBefore = builds['expenses'];

        invalidateInfraProviders(
          container.read(_refProvider),
          payload(
            table: 'epass_challans',
            newRecord: {'id': 'challan-1', 'project_id': 'project-1'},
          ),
        );
        await settle();

        expect(builds['projects'], projectsBefore);
        expect(builds['expenses'], expensesBefore);
      },
    );

    test('an expense change still refreshes the existing providers', () async {
      await settle();
      final expensesBefore = builds['expenses'];
      final projectsBefore = builds['projects'];

      invalidateInfraProviders(
        container.read(_refProvider),
        payload(
          table: 'project_expenses',
          newRecord: {'id': 'expense-1', 'project_id': 'project-1'},
        ),
      );
      await settle();

      expect(builds['expenses'], greaterThan(expensesBefore!));
      expect(builds['projects'], greaterThan(projectsBefore!));
    });

    test('an expense change does not touch the challan list', () async {
      await settle();
      final challansBefore = builds['challans'];

      invalidateInfraProviders(
        container.read(_refProvider),
        payload(
          table: 'project_expenses',
          newRecord: {'id': 'expense-1', 'project_id': 'project-1'},
        ),
      );
      await settle();

      expect(builds['challans'], challansBefore);
    });
  });
}

class _StubChallanRepository implements ChallanRepository {
  const _StubChallanRepository();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not used in these tests');
}
