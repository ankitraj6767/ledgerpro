import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/remote/supabase_ledger_api.dart';
import '../../data/repositories/infra_repository.dart';

final infraRealtimeBridgeProvider = Provider<void>((ref) {
  final api = ref.watch(supabaseLedgerApiProvider);
  final workspace = ref.watch(infraWorkspaceProvider).value;
  if (api == null || workspace == null) return;

  // Realtime channels reconnect and can replay buffered payloads on network
  // flaps (common on Windows desktop when Wi-Fi drops/resumes). A payload
  // already in flight can invoke this callback after the provider has been
  // disposed, so guard against touching a disposed ref which would otherwise
  // throw and escalate into an unhandled error.
  var disposed = false;

  final channel = api.subscribeToInfraWorkspace(
    organizationId: workspace.id,
    onChange: (payload) {
      if (disposed) return;
      try {
        _invalidateInfraProviders(ref, payload);
      } catch (error, stack) {
        // Provider was torn down (or invalidation raced a rebuild); ignore.
        debugPrint('infraRealtimeBridge invalidate skipped: $error\n$stack');
      }
    },
  );

  ref.onDispose(() {
    disposed = true;
    unawaited(api.unsubscribe(channel));
  });
});

void _invalidateInfraProviders(Ref ref, PostgresChangePayload payload) {
  ref.invalidate(infraWorkspaceProvider);
  ref.invalidate(organizationProfileProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(projectsProvider);
  ref.invalidate(investorsProvider);
  ref.invalidate(infraAuditLogsProvider);
  ref.invalidate(customerMembersProvider);

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
