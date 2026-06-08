import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/material_models.dart';
import 'infra_repository.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(Supabase.instance.client);
});

class SelectedTenderNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

class SelectedDistrictNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

class SelectedWarehouseNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedTenderProvider =
    NotifierProvider<SelectedTenderNotifier, String?>(
      SelectedTenderNotifier.new,
    );
final selectedDistrictProvider =
    NotifierProvider<SelectedDistrictNotifier, String?>(
      SelectedDistrictNotifier.new,
    );
final selectedWarehouseProvider =
    NotifierProvider<SelectedWarehouseNotifier, String?>(
      SelectedWarehouseNotifier.new,
    );

final tendersProvider = FutureProvider<List<Tender>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(materialRepositoryProvider).fetchTenders(org.id);
});

final districtsProvider = FutureProvider<List<District>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(materialRepositoryProvider).fetchDistricts(org.id);
});

final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  final districtId = ref.watch(selectedDistrictProvider);
  return ref
      .watch(materialRepositoryProvider)
      .fetchWarehouses(org.id, districtId: districtId);
});

final allWarehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(materialRepositoryProvider).fetchWarehouses(org.id);
});

final materialItemsProvider = FutureProvider<List<MaterialItem>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(materialRepositoryProvider).fetchMaterialItems(org.id);
});

final schoolsProvider = FutureProvider<List<School>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  final tenderId = ref.watch(selectedTenderProvider);
  final districtId = ref.watch(selectedDistrictProvider);
  return ref
      .watch(materialRepositoryProvider)
      .fetchSchools(org.id, tenderId: tenderId, districtId: districtId);
});

final allSchoolsProvider = FutureProvider<List<School>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(materialRepositoryProvider).fetchSchools(org.id);
});

final siteManagersProvider = FutureProvider<List<SiteManager>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref.watch(materialRepositoryProvider).fetchSiteManagers(org.id);
});

final effectiveTenderIdProvider = Provider<String?>((ref) {
  return ref.watch(selectedTenderProvider) ??
      ref.watch(tendersProvider).value?.firstOrNull?.id;
});

final effectiveWarehouseIdProvider = Provider<String?>((ref) {
  return ref.watch(selectedWarehouseProvider) ??
      ref.watch(warehousesProvider).value?.firstOrNull?.id;
});

final materialDashboardSummaryProvider =
    FutureProvider<MaterialDashboardSummary>((ref) async {
      final org = await ref.watch(infraWorkspaceProvider.future);
      return ref
          .watch(materialRepositoryProvider)
          .dashboardSummary(
            organizationId: org.id,
            tenderId: ref.watch(effectiveTenderIdProvider),
            districtId: ref.watch(selectedDistrictProvider),
            warehouseId: ref.watch(effectiveWarehouseIdProvider),
          );
    });

final warehouseStockSummaryProvider = FutureProvider<List<WarehouseStockRow>>((
  ref,
) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  final warehouseId = ref.watch(effectiveWarehouseIdProvider);
  if (warehouseId == null) return const [];
  return ref
      .watch(materialRepositoryProvider)
      .warehouseStockSummary(
        organizationId: org.id,
        warehouseId: warehouseId,
        tenderId: ref.watch(effectiveTenderIdProvider),
      );
});

final schoolRequirementIssueProvider =
    FutureProvider<List<SchoolRequirementIssueRow>>((ref) async {
      final org = await ref.watch(infraWorkspaceProvider.future);
      final tenderId = ref.watch(effectiveTenderIdProvider);
      if (tenderId == null) return const [];
      return ref
          .watch(materialRepositoryProvider)
          .schoolRequirementVsIssue(
            organizationId: org.id,
            tenderId: tenderId,
            districtId: ref.watch(selectedDistrictProvider),
          );
    });

final recentMaterialIssuesProvider = FutureProvider<List<RecentMaterialIssue>>((
  ref,
) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref
      .watch(materialRepositoryProvider)
      .recentMaterialIssues(
        organizationId: org.id,
        tenderId: ref.watch(effectiveTenderIdProvider),
        districtId: ref.watch(selectedDistrictProvider),
      );
});

final lowStockAlertsProvider = FutureProvider<List<LowStockAlert>>((ref) async {
  final org = await ref.watch(infraWorkspaceProvider.future);
  return ref
      .watch(materialRepositoryProvider)
      .lowStockAlerts(
        organizationId: org.id,
        warehouseId: ref.watch(effectiveWarehouseIdProvider),
      );
});

final managerMaterialIssueSummaryProvider =
    FutureProvider<List<ManagerMaterialIssueRow>>((ref) async {
      final org = await ref.watch(infraWorkspaceProvider.future);
      final tenderId = ref.watch(effectiveTenderIdProvider);
      if (tenderId == null) return const [];
      return ref
          .watch(materialRepositoryProvider)
          .managerMaterialIssueSummary(
            organizationId: org.id,
            tenderId: tenderId,
            districtId: ref.watch(selectedDistrictProvider),
          );
    });

final materialSetupStatusProvider = Provider<MaterialSetupStatus>((ref) {
  return MaterialSetupStatus(
    tenders: ref.watch(tendersProvider).value?.length ?? 0,
    districts: ref.watch(districtsProvider).value?.length ?? 0,
    warehouses: ref.watch(allWarehousesProvider).value?.length ?? 0,
    managers: ref.watch(siteManagersProvider).value?.length ?? 0,
    schools: ref.watch(allSchoolsProvider).value?.length ?? 0,
    materials: ref.watch(materialItemsProvider).value?.length ?? 0,
  );
});

void invalidateMaterialProviders(WidgetRef ref) {
  ref.invalidate(tendersProvider);
  ref.invalidate(districtsProvider);
  ref.invalidate(warehousesProvider);
  ref.invalidate(allWarehousesProvider);
  ref.invalidate(materialItemsProvider);
  ref.invalidate(schoolsProvider);
  ref.invalidate(allSchoolsProvider);
  ref.invalidate(siteManagersProvider);
  ref.invalidate(materialDashboardSummaryProvider);
  ref.invalidate(warehouseStockSummaryProvider);
  ref.invalidate(schoolRequirementIssueProvider);
  ref.invalidate(recentMaterialIssuesProvider);
  ref.invalidate(lowStockAlertsProvider);
  ref.invalidate(managerMaterialIssueSummaryProvider);
}

void invalidateMaterialProvidersFromRef(Ref ref) {
  ref.invalidate(tendersProvider);
  ref.invalidate(districtsProvider);
  ref.invalidate(warehousesProvider);
  ref.invalidate(allWarehousesProvider);
  ref.invalidate(materialItemsProvider);
  ref.invalidate(schoolsProvider);
  ref.invalidate(allSchoolsProvider);
  ref.invalidate(siteManagersProvider);
  ref.invalidate(materialDashboardSummaryProvider);
  ref.invalidate(warehouseStockSummaryProvider);
  ref.invalidate(schoolRequirementIssueProvider);
  ref.invalidate(recentMaterialIssuesProvider);
  ref.invalidate(lowStockAlertsProvider);
  ref.invalidate(managerMaterialIssueSummaryProvider);
}

String? validatePositiveQuantity(String? input) {
  final value = double.tryParse(input?.trim() ?? '');
  if (value == null || value <= 0) return 'Enter a quantity greater than zero';
  return null;
}

String? validateIssueQuantity(String? input, double available) {
  final positiveError = validatePositiveQuantity(input);
  if (positiveError != null) return positiveError;
  final value = double.parse(input!.trim());
  if (value > available) {
    return 'Only ${formatQuantity(available)} available';
  }
  return null;
}

class MaterialRepository {
  const MaterialRepository(this._client);
  final SupabaseClient _client;

  static const _schoolEvidenceBucket = 'project-documents';

  Future<List<Tender>> fetchTenders(String organizationId) async {
    final rows = await _client
        .from('tenders')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null)
        .order('year', ascending: false)
        .order('name');
    return rows.map((row) => Tender.fromJson(row)).toList();
  }

  Future<List<District>> fetchDistricts(String organizationId) async {
    final rows = await _client
        .from('districts')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null)
        .order('name');
    return rows.map((row) => District.fromJson(row)).toList();
  }

  Future<List<Warehouse>> fetchWarehouses(
    String organizationId, {
    String? districtId,
  }) async {
    var query = _client
        .from('warehouses')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null);
    if (districtId != null) query = query.eq('district_id', districtId);
    final rows = await query
        .order('is_central', ascending: false)
        .order('name');
    return rows.map((row) => Warehouse.fromJson(row)).toList();
  }

  Future<List<School>> fetchSchools(
    String organizationId, {
    String? tenderId,
    String? districtId,
  }) async {
    var query = _client
        .from('schools')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null);
    if (tenderId != null) query = query.eq('tender_id', tenderId);
    if (districtId != null) query = query.eq('district_id', districtId);
    final rows = await query.order('name');
    return rows.map((row) => School.fromJson(row)).toList();
  }

  Future<List<SiteManager>> fetchSiteManagers(String organizationId) async {
    final rows = await _client
        .from('site_managers')
        .select()
        .eq('organization_id', organizationId)
        .eq('active', true)
        .isFilter('deleted_at', null)
        .order('full_name');
    return rows.map((row) => SiteManager.fromJson(row)).toList();
  }

  Future<List<MaterialItem>> fetchMaterialItems(String organizationId) async {
    final rows = await _client
        .from('material_items')
        .select()
        .eq('organization_id', organizationId)
        .isFilter('deleted_at', null)
        .order('name');
    return rows.map((row) => MaterialItem.fromJson(row)).toList();
  }

  Future<MaterialDashboardSummary> dashboardSummary({
    required String organizationId,
    String? tenderId,
    String? districtId,
    String? warehouseId,
  }) async {
    final row = await _client
        .rpc(
          'material_dashboard_summary',
          params: {
            'p_organization_id': organizationId,
            'p_tender_id': tenderId,
            'p_district_id': districtId,
            'p_warehouse_id': warehouseId,
          },
        )
        .single();
    return MaterialDashboardSummary.fromJson(row);
  }

  Future<List<WarehouseStockRow>> warehouseStockSummary({
    required String organizationId,
    required String warehouseId,
    String? tenderId,
  }) async {
    final rows = await _client.rpc(
      'warehouse_stock_summary',
      params: {
        'p_organization_id': organizationId,
        'p_warehouse_id': warehouseId,
        'p_tender_id': tenderId,
      },
    );
    return _rows(rows).map(WarehouseStockRow.fromJson).toList();
  }

  Future<List<SchoolRequirementIssueRow>> schoolRequirementVsIssue({
    required String organizationId,
    required String tenderId,
    String? districtId,
  }) async {
    final rows = await _client.rpc(
      'school_requirement_vs_issue',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_district_id': districtId,
      },
    );
    return _rows(rows).map(SchoolRequirementIssueRow.fromJson).toList();
  }

  Future<List<RecentMaterialIssue>> recentMaterialIssues({
    required String organizationId,
    String? tenderId,
    String? districtId,
    int limit = 10,
  }) async {
    final rows = await _client.rpc(
      'recent_material_issues',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_district_id': districtId,
        'p_limit': limit,
      },
    );
    return _rows(rows).map(RecentMaterialIssue.fromJson).toList();
  }

  Future<List<LowStockAlert>> lowStockAlerts({
    required String organizationId,
    String? warehouseId,
  }) async {
    final rows = await _client.rpc(
      'low_stock_alerts',
      params: {
        'p_organization_id': organizationId,
        'p_warehouse_id': warehouseId,
      },
    );
    return _rows(rows).map(LowStockAlert.fromJson).toList();
  }

  Future<List<ManagerMaterialIssueRow>> managerMaterialIssueSummary({
    required String organizationId,
    required String tenderId,
    String? districtId,
  }) async {
    final rows = await _client.rpc(
      'manager_material_issue_summary',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_district_id': districtId,
      },
    );
    return _rows(rows).map(ManagerMaterialIssueRow.fromJson).toList();
  }

  Future<void> receiveMaterial({
    required String organizationId,
    required String tenderId,
    required String warehouseId,
    required String materialId,
    required double quantity,
    String? supplierName,
    String? invoiceNumber,
    DateTime? receivedDate,
    String? notes,
  }) async {
    await _client.rpc(
      'receive_material',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_warehouse_id': warehouseId,
        'p_material_id': materialId,
        'p_quantity': quantity,
        'p_supplier_name': supplierName,
        'p_invoice_number': invoiceNumber,
        'p_received_date': _date(receivedDate),
        'p_notes': notes,
      },
    );
  }

  Future<void> issueMaterialToSchool({
    required String organizationId,
    required String tenderId,
    required String warehouseId,
    required String schoolId,
    required String materialId,
    required double quantity,
    String? managerId,
    DateTime? issueDate,
    String? notes,
  }) async {
    await _client.rpc(
      'issue_material_to_school',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_warehouse_id': warehouseId,
        'p_school_id': schoolId,
        'p_manager_id': managerId,
        'p_material_id': materialId,
        'p_quantity': quantity,
        'p_issue_date': _date(issueDate),
        'p_notes': notes,
      },
    );
  }

  Future<void> returnMaterialFromSchool({
    required String organizationId,
    required String tenderId,
    required String warehouseId,
    required String schoolId,
    required String materialId,
    required double quantity,
    String? managerId,
    DateTime? returnDate,
    String? reason,
    String? notes,
  }) async {
    await _client.rpc(
      'return_material_from_school',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_warehouse_id': warehouseId,
        'p_school_id': schoolId,
        'p_manager_id': managerId,
        'p_material_id': materialId,
        'p_quantity': quantity,
        'p_return_date': _date(returnDate),
        'p_reason': reason,
        'p_notes': notes,
      },
    );
  }

  Future<String> addMaterialItem({
    required String organizationId,
    required String name,
    required String unit,
    String? sku,
    String? category,
    double lowStockThreshold = 0,
  }) async {
    final result = await _client.rpc(
      'create_material_item',
      params: {
        'p_organization_id': organizationId,
        'p_name': name.trim(),
        'p_unit': unit.trim(),
        'p_sku': sku?.trim(),
        'p_category': category?.trim(),
        'p_low_stock_threshold': lowStockThreshold,
      },
    );
    return result.toString();
  }

  Future<String> createTender({
    required String organizationId,
    required String name,
    String? code,
    int? year,
    String? description,
  }) async {
    final result = await _client.rpc(
      'create_material_tender',
      params: {
        'p_organization_id': organizationId,
        'p_name': name.trim(),
        'p_code': code?.trim(),
        'p_year': year,
        'p_description': description?.trim(),
      },
    );
    return result.toString();
  }

  Future<void> updateTender({
    required String organizationId,
    required String tenderId,
    required String name,
    String? code,
    int? year,
    String status = 'active',
    String? description,
  }) async {
    await _client.rpc(
      'update_material_tender',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_name': name.trim(),
        'p_code': code?.trim(),
        'p_year': year,
        'p_status': status.trim(),
        'p_description': description?.trim(),
      },
    );
  }

  Future<void> deleteTender({
    required String organizationId,
    required String tenderId,
  }) async {
    await _client.rpc(
      'delete_material_tender',
      params: {'p_organization_id': organizationId, 'p_tender_id': tenderId},
    );
  }

  Future<String> createDistrict({
    required String organizationId,
    required String name,
    String? state,
  }) async {
    final result = await _client.rpc(
      'create_material_district',
      params: {
        'p_organization_id': organizationId,
        'p_name': name.trim(),
        'p_state': state?.trim(),
      },
    );
    return result.toString();
  }

  Future<void> updateDistrict({
    required String organizationId,
    required String districtId,
    required String name,
    String? state,
  }) async {
    await _client.rpc(
      'update_material_district',
      params: {
        'p_organization_id': organizationId,
        'p_district_id': districtId,
        'p_name': name.trim(),
        'p_state': state?.trim(),
      },
    );
  }

  Future<void> deleteDistrict({
    required String organizationId,
    required String districtId,
  }) async {
    await _client.rpc(
      'delete_material_district',
      params: {
        'p_organization_id': organizationId,
        'p_district_id': districtId,
      },
    );
  }

  Future<String> createManager({
    required String organizationId,
    required String fullName,
    String? phone,
    String? email,
    String roleLabel = 'Project Manager',
  }) async {
    final result = await _client.rpc(
      'create_material_manager',
      params: {
        'p_organization_id': organizationId,
        'p_full_name': fullName.trim(),
        'p_phone': phone?.trim(),
        'p_email': email?.trim(),
        'p_role_label': roleLabel.trim(),
      },
    );
    return result.toString();
  }

  Future<void> updateManager({
    required String organizationId,
    required String managerId,
    required String fullName,
    String? phone,
    String? email,
    String roleLabel = 'Project Manager',
    bool active = true,
  }) async {
    await _client.rpc(
      'update_material_manager',
      params: {
        'p_organization_id': organizationId,
        'p_manager_id': managerId,
        'p_full_name': fullName.trim(),
        'p_phone': phone?.trim(),
        'p_email': email?.trim(),
        'p_role_label': roleLabel.trim(),
        'p_active': active,
      },
    );
  }

  Future<void> deleteManager({
    required String organizationId,
    required String managerId,
  }) async {
    await _client.rpc(
      'delete_material_manager',
      params: {'p_organization_id': organizationId, 'p_manager_id': managerId},
    );
  }

  Future<String> createWarehouse({
    required String organizationId,
    required String name,
    String? districtId,
    String? address,
    String? managerName,
    String? phone,
    bool isCentral = false,
  }) async {
    final result = await _client.rpc(
      'create_material_warehouse',
      params: {
        'p_organization_id': organizationId,
        'p_district_id': districtId,
        'p_name': name.trim(),
        'p_address': address?.trim(),
        'p_manager_name': managerName?.trim(),
        'p_phone': phone?.trim(),
        'p_is_central': isCentral,
      },
    );
    return result.toString();
  }

  Future<void> updateWarehouse({
    required String organizationId,
    required String warehouseId,
    required String name,
    String? districtId,
    String? address,
    String? managerName,
    String? phone,
    bool isCentral = false,
  }) async {
    await _client.rpc(
      'update_material_warehouse',
      params: {
        'p_organization_id': organizationId,
        'p_warehouse_id': warehouseId,
        'p_district_id': districtId,
        'p_name': name.trim(),
        'p_address': address?.trim(),
        'p_manager_name': managerName?.trim(),
        'p_phone': phone?.trim(),
        'p_is_central': isCentral,
      },
    );
  }

  Future<void> deleteWarehouse({
    required String organizationId,
    required String warehouseId,
  }) async {
    await _client.rpc(
      'delete_material_warehouse',
      params: {
        'p_organization_id': organizationId,
        'p_warehouse_id': warehouseId,
      },
    );
  }

  Future<String> createSchool({
    required String organizationId,
    required String tenderId,
    required String districtId,
    required String name,
    String? code,
    String? address,
    String? assignedManagerId,
    int roomQuantity = 0,
  }) async {
    final result = await _client.rpc(
      'create_material_school',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_district_id': districtId,
        'p_name': name.trim(),
        'p_code': code?.trim(),
        'p_address': address?.trim(),
        'p_assigned_manager_id': assignedManagerId,
        'p_room_quantity': roomQuantity,
      },
    );
    return result.toString();
  }

  Future<void> updateSchool({
    required String organizationId,
    required String schoolId,
    required String tenderId,
    String? districtId,
    required String name,
    String? code,
    String? address,
    String status = 'not_started',
    int progressPercent = 0,
    String? assignedManagerId,
    int roomQuantity = 0,
  }) async {
    await _client.rpc(
      'update_material_school',
      params: {
        'p_organization_id': organizationId,
        'p_school_id': schoolId,
        'p_tender_id': tenderId,
        'p_district_id': districtId,
        'p_name': name.trim(),
        'p_code': code?.trim(),
        'p_address': address?.trim(),
        'p_status': status.trim(),
        'p_progress_percent': progressPercent,
        'p_assigned_manager_id': assignedManagerId,
        'p_room_quantity': roomQuantity,
      },
    );
  }

  Future<String> uploadSchoolEvidencePhoto({
    required String organizationId,
    required String schoolId,
    required Uint8List bytes,
    required DateTime capturedAt,
    required String fileName,
  }) async {
    final safeName = _safeFileName(fileName);
    final storagePath =
        '$organizationId/material-schools/$schoolId/${capturedAt.microsecondsSinceEpoch}-$safeName';
    await _client.storage
        .from(_schoolEvidenceBucket)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    return storagePath;
  }

  Future<void> addSchoolEvidence({
    required String organizationId,
    required String schoolId,
    int? roomQuantity,
    List<String> photoPaths = const [],
    double? gpsLatitude,
    double? gpsLongitude,
    double? gpsAccuracyMeters,
    DateTime? gpsCapturedAt,
  }) async {
    await _client.rpc(
      'add_material_school_evidence',
      params: {
        'p_organization_id': organizationId,
        'p_school_id': schoolId,
        'p_room_quantity': roomQuantity,
        'p_photo_paths': photoPaths,
        'p_gps_latitude': gpsLatitude,
        'p_gps_longitude': gpsLongitude,
        'p_gps_accuracy_meters': gpsAccuracyMeters,
        'p_gps_captured_at': gpsCapturedAt?.toUtc().toIso8601String(),
      },
    );
  }

  Future<void> deleteSchool({
    required String organizationId,
    required String schoolId,
  }) async {
    await _client.rpc(
      'delete_material_school',
      params: {'p_organization_id': organizationId, 'p_school_id': schoolId},
    );
  }

  Future<void> updateMaterialItem({
    required String organizationId,
    required String materialId,
    required String name,
    required String unit,
    String? sku,
    String? category,
    double lowStockThreshold = 0,
  }) async {
    await _client.rpc(
      'update_material_item',
      params: {
        'p_organization_id': organizationId,
        'p_material_id': materialId,
        'p_name': name.trim(),
        'p_unit': unit.trim(),
        'p_sku': sku?.trim(),
        'p_category': category?.trim(),
        'p_low_stock_threshold': lowStockThreshold,
      },
    );
  }

  Future<void> deleteMaterialItem({
    required String organizationId,
    required String materialId,
  }) async {
    await _client.rpc(
      'delete_material_item',
      params: {
        'p_organization_id': organizationId,
        'p_material_id': materialId,
      },
    );
  }

  Future<void> updateSchoolProgress({
    required String organizationId,
    required String schoolId,
    required int progressPercent,
    String? status,
  }) async {
    await _client.rpc(
      'update_material_school_progress',
      params: {
        'p_organization_id': organizationId,
        'p_school_id': schoolId,
        'p_progress_percent': progressPercent,
        'p_status': status,
      },
    );
  }

  Future<void> upsertSchoolRequirement({
    required String organizationId,
    required String tenderId,
    required String schoolId,
    required String materialId,
    required double requiredQuantity,
  }) async {
    await _client.rpc(
      'set_school_material_requirement',
      params: {
        'p_organization_id': organizationId,
        'p_tender_id': tenderId,
        'p_school_id': schoolId,
        'p_material_id': materialId,
        'p_required_quantity': requiredQuantity,
      },
    );
  }

  static List<Map<String, dynamic>> _rows(Object? value) {
    return ((value as List?) ?? const [])
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static String _date(DateTime? value) =>
      (value ?? DateTime.now()).toIso8601String().split('T').first;

  static String _safeFileName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.isEmpty) return 'school-evidence.jpg';
    final lower = cleaned.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return cleaned;
    return '$cleaned.jpg';
  }
}

class MaterialSetupStatus {
  const MaterialSetupStatus({
    required this.tenders,
    required this.districts,
    required this.warehouses,
    required this.managers,
    required this.schools,
    required this.materials,
  });

  final int tenders;
  final int districts;
  final int warehouses;
  final int managers;
  final int schools;
  final int materials;

  int get completedSteps => [
    tenders,
    districts,
    warehouses,
    managers,
    schools,
    materials,
  ].where((count) => count > 0).length;

  bool get isReadyForReceive => tenders > 0 && warehouses > 0 && materials > 0;
  bool get isReadyForIssue => isReadyForReceive && schools > 0 && managers > 0;
  bool get isComplete => completedSteps == 6;
}
