import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cache/challan_cache.dart';
import '../../../core/network/network_monitor.dart';
import '../../../data/repositories/infra_repository.dart';
import '../data/challan_portal_adapter.dart';
import '../data/challan_repository.dart';
import '../data/epass_portal_adapter.dart';
import '../domain/challan_models.dart';
import '../domain/challan_portal.dart';
import '../domain/challan_status.dart';
import '../domain/material_type.dart';
import 'challan_flow_controller.dart';
import 'challan_flow_state.dart';

final challanRepositoryProvider = Provider<ChallanRepository>((ref) {
  return ChallanRepository(Supabase.instance.client);
});

/// Portal capture strategy, resolved per state government portal.
///
/// Swap an entry for an authorized government API adapter when one becomes
/// available — nothing else in the feature changes.
final challanVerificationAdapterProvider =
    Provider.family<ChallanVerificationAdapter, ChallanPortal>((ref, portal) {
      return EPassWebViewAdapter(portal);
    });

/// Connectivity as a plain bool for the challan UI.
///
/// Defaults to online while the first connectivity result is still pending, so
/// the portal button is not briefly disabled on a cold start.
final networkOnlineProvider = Provider<bool>((ref) {
  return ref.watch(networkMonitorProvider).value ?? true;
});

/// Filters applied to the recent-challan list.
final challanFiltersProvider =
    NotifierProvider<ChallanFiltersController, ChallanFilter>(
      ChallanFiltersController.new,
    );

/// Holds the list filters.
///
/// Freezed `copyWith` cannot clear a nullable field, so each setter rebuilds the
/// filter explicitly. That keeps "clear this filter" and "leave it alone"
/// unambiguous.
class ChallanFiltersController extends Notifier<ChallanFilter> {
  @override
  ChallanFilter build() => const ChallanFilter();

  void setQuery(String value) => state = _copy(query: value);

  void setProject(String? projectId) => state = _copy(projectId: projectId);

  void setMaterial(ChallanMaterialType? material) =>
      state = _copy(materialType: material);

  void setStatus(ChallanVerificationStatus? status) =>
      state = _copy(status: status);

  void setDateRange({DateTime? from, DateTime? to}) =>
      state = _copy(fromDate: from, toDate: to);

  void clear() => state = const ChallanFilter();

  /// Rebuilds the filter, defaulting every unspecified field to its current
  /// value. Pass an explicit `null` to clear a field.
  ChallanFilter _copy({
    String? query,
    Object? projectId = _unset,
    Object? materialType = _unset,
    Object? status = _unset,
    Object? fromDate = _unset,
    Object? toDate = _unset,
  }) {
    return ChallanFilter(
      query: query ?? state.query,
      projectId: projectId == _unset ? state.projectId : projectId as String?,
      materialType: materialType == _unset
          ? state.materialType
          : materialType as ChallanMaterialType?,
      status: status == _unset
          ? state.status
          : status as ChallanVerificationStatus?,
      fromDate: fromDate == _unset ? state.fromDate : fromDate as DateTime?,
      toDate: toDate == _unset ? state.toDate : toDate as DateTime?,
    );
  }
}

/// Sentinel distinguishing "argument omitted" from "explicitly null".
const Object _unset = Object();

/// The organization's challans, filtered server-side wherever RLS-safe.
final challansProvider = FutureProvider<List<EPassChallan>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  final filter = ref.watch(challanFiltersProvider);
  final challans = await ref
      .watch(challanRepositoryProvider)
      .fetchChallans(organizationId: org.id, filter: filter);
  final userId = _currentUserId();
  if (!filter.isActive && userId != null) {
    final cache = ref.read(challanCacheProvider);
    final save = cache.save(
      userId: userId,
      organizationId: org.id,
      challans: challans,
    );
    // `save` updates the in-memory snapshot before its first await. Rebuild
    // cache consumers immediately, without making the network result wait for
    // disk I/O.
    ref.invalidate(cachedChallansProvider);
    unawaited(save);
  }
  return challans;
});

/// Last-known unfiltered challans, scoped to the live user and organization.
/// The list UI uses this only while the server refresh is in flight.
final cachedChallansProvider = Provider<List<EPassChallan>?>((ref) {
  final snapshot = ref.watch(challanCacheProvider).value;
  final userId = _currentUserId();
  final workspace = ref.watch(infraWorkspaceProvider).value;
  if (snapshot == null || userId == null || workspace == null) return null;
  if (snapshot.userId != userId || snapshot.organizationId != workspace.id) {
    return null;
  }
  return snapshot.challans;
});

String? _currentUserId() {
  try {
    return Supabase.instance.client.auth.currentUser?.id;
  } catch (_) {
    // Tests and the first frame can run before Supabase initialization.
    return null;
  }
}

final challanByIdProvider = FutureProvider.family<EPassChallan?, String>((
  ref,
  challanId,
) {
  return ref.watch(challanRepositoryProvider).fetchChallanById(challanId);
});

/// Controller for the five-step entry journey.
final challanFlowControllerProvider =
    NotifierProvider<ChallanFlowController, ChallanFlowState>(
      ChallanFlowController.new,
    );
