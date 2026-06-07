import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/remote/supabase_ledger_api.dart';
import '../../data/repositories/infra_repository.dart';
import '../../data/repositories/material_repository.dart';

final infraRealtimeBridgeProvider = Provider<void>((ref) {
  final api = ref.watch(supabaseLedgerApiProvider);
  final workspace = ref.watch(infraWorkspaceProvider).value;
  if (api == null || workspace == null) return;

  final channel = api.subscribeToInfraWorkspace(
    organizationId: workspace.id,
    onChange: (payload) => _invalidateInfraProviders(ref, payload),
  );

  ref.onDispose(() => unawaited(api.unsubscribe(channel)));
});

void _invalidateInfraProviders(Ref ref, PostgresChangePayload payload) {
  ref.invalidate(infraWorkspaceProvider);
  ref.invalidate(organizationProfileProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(projectsProvider);
  ref.invalidate(investorsProvider);
  ref.invalidate(infraAuditLogsProvider);
  ref.invalidate(customerMembersProvider);
  invalidateMaterialProvidersFromRef(ref);

  final record = payload.newRecord.isNotEmpty
      ? payload.newRecord
      : payload.oldRecord;
  final projectId =
      record['project_id']?.toString() ??
      (payload.table == 'infra_projects' ? record['id']?.toString() : null);
  final fundId =
      record['government_fund_id']?.toString() ??
      (payload.table == 'government_funds' ? record['id']?.toString() : null);

  if (projectId != null && projectId.isNotEmpty) {
    ref.invalidate(projectFinancialSummaryProvider(projectId));
    ref.invalidate(projectInvestorsProvider(projectId));
    ref.invalidate(projectInvestmentsProvider(projectId));
    ref.invalidate(governmentFundsProvider(projectId));
    ref.invalidate(projectExpensesProvider(projectId));
    ref.invalidate(projectNotesProvider(projectId));
  }
  if (fundId != null && fundId.isNotEmpty) {
    ref.invalidate(fundReceiptsProvider(fundId));
  }
}
