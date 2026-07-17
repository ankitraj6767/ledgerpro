import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/infra_repository.dart';

/// Pull-to-refresh helpers.
///
/// Each method invalidates the relevant Riverpod providers so their data is
/// re-fetched from Supabase, then awaits the new futures so a [RefreshIndicator]
/// keeps spinning until fresh server data has actually arrived. This is what
/// lets a change made on another device show up immediately on pull-to-refresh
/// instead of only after a full app restart.
///
/// The awaits are wrapped so the refresh gesture itself never throws: any load
/// error still surfaces through the provider's own `AsyncError` state (and the
/// existing error/retry UI), exactly as it does on first load.
extension PullToRefreshX on WidgetRef {
  /// Refreshes the workspace-wide data shown on the dashboard, projects list,
  /// expenses, reports and profile screens.
  Future<void> refreshWorkspace() async {
    // Invalidating the root workspace cascades to every provider that depends
    // on it; awaiting the leaves below waits for the whole chain to reload.
    invalidate(infraWorkspaceProvider);
    await _awaitAll([
      read(dashboardSummaryProvider.future),
      read(projectsProvider.future),
      read(organizationProfileProvider.future),
    ]);
  }

  /// Refreshes everything tied to a single project (used by the project detail
  /// tabs, notes and reports screens).
  Future<void> refreshProject(String projectId) async {
    invalidate(projectsProvider);
    invalidate(dashboardSummaryProvider);
    invalidate(projectFinancialSummaryProvider(projectId));
    invalidate(projectInvestmentsProvider(projectId));
    invalidate(investmentReturnsProvider(projectId));
    invalidate(projectInvestorsProvider(projectId));
    invalidate(governmentFundsProvider(projectId));
    invalidate(projectExpensesProvider(projectId));
    invalidate(projectNotesProvider(projectId));
    await _awaitAll([
      read(projectsProvider.future),
      read(projectFinancialSummaryProvider(projectId).future),
      read(projectInvestmentsProvider(projectId).future),
      read(investmentReturnsProvider(projectId).future),
      read(projectInvestorsProvider(projectId).future),
      read(governmentFundsProvider(projectId).future),
      read(projectExpensesProvider(projectId).future),
      read(projectNotesProvider(projectId).future),
    ]);
  }

  /// Awaits an already-triggered re-fetch, swallowing load errors so the
  /// refresh gesture never throws. Invalidate the provider first, e.g.:
  /// `onRefresh: () { ref.invalidate(p); return ref.awaitRefresh(ref.read(p.future)); }`
  Future<void> awaitRefresh(Future<Object?> future) => _awaitAll([future]);
}

Future<void> _awaitAll(List<Future<Object?>> futures) async {
  try {
    await Future.wait(futures);
  } catch (_) {
    // Load errors surface via each provider's AsyncError state; the refresh
    // gesture must never throw.
  }
}
