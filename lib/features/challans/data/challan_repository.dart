import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/challan_exceptions.dart';
import '../domain/challan_models.dart';
import '../domain/challan_status.dart';
import '../domain/material_type.dart';

/// Supabase access for `epass_challans`.
///
/// Reads go through PostgREST so RLS is the access authority; writes go through
/// security-definer RPCs so normalization, the duplicate check, the audit log
/// and the insert all happen atomically on the server. The client-side
/// duplicate pre-check exists only to give immediate feedback.
class ChallanRepository {
  const ChallanRepository(this._client);

  final SupabaseClient _client;

  static const table = 'epass_challans';

  /// Columns selected for list and detail reads. `project_name` is joined from
  /// `infra_projects` for display.
  static const _columns = '*, infra_projects!inner(name)';

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  Future<List<EPassChallan>> fetchChallans({
    required String organizationId,
    ChallanFilter filter = const ChallanFilter(),
    int limit = 200,
  }) async {
    return _guard(() async {
      var query = _client
          .from(table)
          .select(_columns)
          .eq('organization_id', organizationId)
          .isFilter('deleted_at', null);

      if (filter.projectId != null) {
        query = query.eq('project_id', filter.projectId!);
      }
      if (filter.status != null) {
        query = query.eq('verification_status', filter.status!.dbValue);
      }
      if (filter.materialType != null) {
        query = query.eq(
          'selected_material_type',
          filter.materialType!.dbValue,
        );
      }
      if (filter.fromDate != null) {
        query = query.gte('challan_date', filter.fromDate!.toIso8601String());
      }
      if (filter.toDate != null) {
        // Inclusive of the whole end day.
        final endOfDay = DateTime(
          filter.toDate!.year,
          filter.toDate!.month,
          filter.toDate!.day,
          // ignore: require_trailing_commas
          23,
          59,
          59,
        );
        query = query.lte('challan_date', endOfDay.toIso8601String());
      }

      final search = ChallanText.normalizeToken(filter.query);
      if (search.isNotEmpty) {
        query = query.or(
          'normalized_challan_number.ilike.%$search%,'
          'normalized_vehicle_number.ilike.%$search%',
        );
      }

      final rows = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return rows
          .map<EPassChallan>(
            (r) => challanFromRow(Map<String, dynamic>.from(r)),
          )
          .toList();
    });
  }

  Future<EPassChallan?> fetchChallanById(String challanId) async {
    return _guard(() async {
      final row = await _client
          .from(table)
          .select(_columns)
          .eq('id', challanId)
          .maybeSingle();
      if (row == null) return null;
      return challanFromRow(Map<String, dynamic>.from(row));
    });
  }

  /// Search by challan or vehicle number within an organization.
  Future<List<EPassChallan>> searchChallans({
    required String organizationId,
    required String query,
    int limit = 50,
  }) {
    return fetchChallans(
      organizationId: organizationId,
      filter: ChallanFilter(query: query),
      limit: limit,
    );
  }

  /// Client-side duplicate pre-check. Returns the existing row when the same
  /// challan is already saved in this organization.
  ///
  /// Only a UX affordance: the unique index and the RPC remain the authority,
  /// and RLS guarantees nothing from another organization is ever returned.
  /// Soft-deleted rows count as duplicates, matching the unique index.
  Future<EPassChallan?> challanExists({
    required String organizationId,
    required String financialYear,
    required String challanNumber,
    String sourcePortal = 'bihar_khanan_soft',
  }) async {
    final normalized = ChallanText.normalizeToken(challanNumber);
    if (normalized.isEmpty) return null;
    return _guard(() async {
      final row = await _client
          .from(table)
          .select(_columns)
          .eq('organization_id', organizationId)
          .eq('source_portal', sourcePortal)
          .eq('financial_year', financialYear.trim())
          .eq('normalized_challan_number', normalized)
          .limit(1)
          .maybeSingle();
      if (row == null) return null;
      return challanFromRow(Map<String, dynamic>.from(row));
    });
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  /// Saves a challan captured from the government portal.
  Future<EPassChallan> createCapturedChallan(EPassChallanDraft draft) {
    assert(
      draft.verificationStatus == ChallanVerificationStatus.portalCaptured,
      'createCapturedChallan must only be used for portal captures',
    );
    return _create(draft);
  }

  /// Saves a manually-entered challan. Always `manual_unverified`, so corrected
  /// data can never masquerade as a portal capture.
  Future<EPassChallan> createManualChallan(EPassChallanDraft draft) {
    return _create(
      draft.copyWith(
        verificationStatus: ChallanVerificationStatus.manualUnverified,
        verificationMethod: ChallanVerificationMethod.manualEntry,
      ),
    );
  }

  Future<EPassChallan> _create(EPassChallanDraft draft) async {
    final payload = draft.payload;

    // Portal-supplied fields this app version does not model are preserved so a
    // later release can backfill them without re-capturing.
    final portalPayload = <String, dynamic>{
      'fields': payload.rawFields,
      if (payload.quantityUnit == null) 'quantity_unit_source': 'assumed_mt',
      'captured_at': payload.capturedAt?.toUtc().toIso8601String(),
    };

    return _guard(() async {
      final row = await _client.rpc(
        'create_epass_challan',
        params: {
          'p_project_id': draft.projectId,
          'p_financial_year': draft.financialYear,
          'p_challan_number': draft.challanNumber,
          'p_portal_mineral_name': payload.mineralName ?? '',
          // Sent as the exact decimal string the portal printed so Postgres
          // numeric(14,3) receives it without a binary-float round trip.
          'p_quantity': payload.quantityText ?? payload.quantity?.toString(),
          'p_vehicle_number': payload.vehicleNumber ?? '',
          'p_verification_status': draft.verificationStatus.dbValue,
          'p_verification_method': draft.verificationMethod.dbValue,
          'p_selected_material_type': draft.selectedMaterialType?.dbValue,
          'p_quantity_unit': payload.quantityUnit ?? 'MT',
          'p_uid_number': payload.uidNumber,
          'p_challan_date': payload.challanDate?.toUtc().toIso8601String(),
          'p_valid_until': payload.validUntil?.toUtc().toIso8601String(),
          'p_vehicle_type': payload.vehicleType,
          'p_consignor_name': payload.consignorName,
          'p_consignee_name': payload.consigneeName,
          'p_source_location': payload.sourceLocation,
          'p_destination': payload.destination,
          'p_generated_from': payload.generatedFrom,
          'p_royalty_amount_paise': payload.royaltyAmountPaise,
          'p_portal_payload': portalPayload,
          'p_portal_response_hash': payload.responseHash,
          'p_portal_url': draft.portalUrl,
          'p_source_portal': draft.sourcePortal,
          'p_captured_at': payload.capturedAt?.toUtc().toIso8601String(),
        },
      );
      return challanFromRow(Map<String, dynamic>.from(row as Map));
    });
  }

  /// Soft-deletes a challan (owner/manager only, enforced server-side).
  Future<void> archiveChallan(String challanId) {
    return _guard(
      () => _client.rpc(
        'archive_epass_challan',
        params: {'p_challan_id': challanId},
      ),
    );
  }

  /// Records that a duplicate save was blocked. Best-effort: a failure here must
  /// never mask the duplicate error the user needs to see.
  Future<void> recordDuplicateBlocked({
    required String projectId,
    required String challanNumber,
  }) async {
    try {
      await _client.rpc(
        'record_challan_duplicate_block',
        params: {'p_project_id': projectId, 'p_challan_number': challanNumber},
      );
    } catch (_) {
      // Audit-only; intentionally swallowed.
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  /// Translates Supabase failures into the module's actionable error taxonomy.
  ///
  /// A unique-constraint violation becomes an explicit duplicate error rather
  /// than a generic server error.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw mapPostgrestError(error);
    } on AuthException catch (_) {
      throw ChallanException.sessionExpired;
    }
  }

  static ChallanException mapPostgrestError(PostgrestException error) {
    final message = error.message.toLowerCase();

    if (error.code == '23505' ||
        message.contains('duplicate_challan') ||
        message.contains('epass_challans_unique_challan_idx') ||
        message.contains('duplicate key value')) {
      return ChallanException.duplicate('');
    }
    if (message.contains('not permitted') ||
        message.contains('permission denied') ||
        message.contains('row-level security') ||
        error.code == '42501') {
      return ChallanException.permissionDenied;
    }
    if (message.contains('project no longer exists')) {
      return ChallanException.projectMissing;
    }
    if (message.contains('sign in again') ||
        message.contains('jwt') ||
        error.code == 'PGRST301') {
      return ChallanException.sessionExpired;
    }
    if (message.contains('timeout') || message.contains('timed out')) {
      return ChallanException.supabaseTimeout;
    }
    if (message.contains('official_api verification')) {
      return const ChallanException(
        ChallanErrorKind.permissionDenied,
        'Official API verification is not available yet.',
      );
    }
    // Never surface raw Postgres text to the user.
    return ChallanException.unknown;
  }

  // ---------------------------------------------------------------------------
  // Row mapping (explicit snake_case -> Dart)
  // ---------------------------------------------------------------------------

  static EPassChallan challanFromRow(Map<String, dynamic> r) {
    final joined = r['infra_projects'];
    final projectName = joined is Map
        ? joined['name']?.toString()
        : (joined is List && joined.isNotEmpty && joined.first is Map
              ? (joined.first as Map)['name']?.toString()
              : null);

    return EPassChallan(
      id: r['id'] as String,
      organizationId: r['organization_id']?.toString() ?? '',
      projectId: r['project_id']?.toString() ?? '',
      sourcePortal: r['source_portal']?.toString() ?? 'bihar_khanan_soft',
      portalUrl: r['portal_url']?.toString(),
      financialYear: r['financial_year']?.toString() ?? '',
      challanNumber: r['challan_number']?.toString() ?? '',
      normalizedChallanNumber: r['normalized_challan_number']?.toString() ?? '',
      uidNumber: r['uid_number']?.toString(),
      challanDate: _date(r['challan_date']),
      validUntil: _date(r['valid_until']),
      selectedMaterialType: ChallanMaterialTypeMapping.fromDb(
        r['selected_material_type']?.toString(),
      ),
      portalMineralName: r['portal_mineral_name']?.toString() ?? '',
      quantity: _decimal(r['quantity']),
      quantityUnit: r['quantity_unit']?.toString() ?? 'MT',
      vehicleType: r['vehicle_type']?.toString(),
      vehicleNumber: r['vehicle_number']?.toString() ?? '',
      normalizedVehicleNumber: r['normalized_vehicle_number']?.toString() ?? '',
      consignorName: r['consignor_name']?.toString(),
      consigneeName: r['consignee_name']?.toString(),
      sourceLocation: r['source_location']?.toString(),
      destination: r['destination']?.toString(),
      generatedFrom: r['generated_from']?.toString(),
      royaltyAmountPaise: (r['royalty_amount_paise'] as num?)?.toInt(),
      portalPayload: r['portal_payload'] is Map
          ? Map<String, dynamic>.from(r['portal_payload'] as Map)
          : const <String, dynamic>{},
      portalResponseHash: r['portal_response_hash']?.toString(),
      verificationStatus: ChallanVerificationStatusMapping.fromDb(
        r['verification_status']?.toString(),
      ),
      verificationMethod: ChallanVerificationMethodMapping.fromDb(
        r['verification_method']?.toString(),
      ),
      capturedAt: _date(r['captured_at']),
      verifiedAt: _date(r['verified_at']),
      createdBy: r['created_by']?.toString(),
      createdAt: _date(r['created_at']),
      updatedAt: _date(r['updated_at']),
      deletedAt: _date(r['deleted_at']),
      projectName: projectName,
    );
  }

  static DateTime? _date(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  /// Postgres `numeric` arrives as a string to preserve precision.
  static double _decimal(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
