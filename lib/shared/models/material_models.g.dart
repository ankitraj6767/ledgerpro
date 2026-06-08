// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tender _$TenderFromJson(Map<String, dynamic> json) => _Tender(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  name: json['name'] as String,
  code: json['code'] as String?,
  year: (json['year'] as num?)?.toInt(),
  status: json['status'] as String? ?? 'active',
  description: json['description'] as String?,
);

Map<String, dynamic> _$TenderToJson(_Tender instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'name': instance.name,
  'code': instance.code,
  'year': instance.year,
  'status': instance.status,
  'description': instance.description,
};

_District _$DistrictFromJson(Map<String, dynamic> json) => _District(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  name: json['name'] as String,
  state: json['state'] as String?,
);

Map<String, dynamic> _$DistrictToJson(_District instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'name': instance.name,
  'state': instance.state,
};

_Warehouse _$WarehouseFromJson(Map<String, dynamic> json) => _Warehouse(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  name: json['name'] as String,
  districtId: json['district_id'] as String?,
  address: json['address'] as String?,
  managerName: json['manager_name'] as String?,
  phone: json['phone'] as String?,
  isCentral: json['is_central'] as bool? ?? false,
);

Map<String, dynamic> _$WarehouseToJson(_Warehouse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'name': instance.name,
      'district_id': instance.districtId,
      'address': instance.address,
      'manager_name': instance.managerName,
      'phone': instance.phone,
      'is_central': instance.isCentral,
    };

_School _$SchoolFromJson(Map<String, dynamic> json) => _School(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  tenderId: json['tender_id'] as String,
  name: json['name'] as String,
  districtId: json['district_id'] as String?,
  code: json['code'] as String?,
  address: json['address'] as String?,
  status: json['status'] as String? ?? 'not_started',
  progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
  assignedManagerId: json['assigned_manager_id'] as String?,
  roomQuantity: (json['room_quantity'] as num?)?.toInt() ?? 0,
  gpsPhotoPaths:
      (json['gps_photo_paths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  gpsLatitude: (json['gps_latitude'] as num?)?.toDouble(),
  gpsLongitude: (json['gps_longitude'] as num?)?.toDouble(),
  gpsAccuracyMeters: (json['gps_accuracy_meters'] as num?)?.toDouble(),
  gpsCapturedAt: json['gps_captured_at'] == null
      ? null
      : DateTime.parse(json['gps_captured_at'] as String),
);

Map<String, dynamic> _$SchoolToJson(_School instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'tender_id': instance.tenderId,
  'name': instance.name,
  'district_id': instance.districtId,
  'code': instance.code,
  'address': instance.address,
  'status': instance.status,
  'progress_percent': instance.progressPercent,
  'assigned_manager_id': instance.assignedManagerId,
  'room_quantity': instance.roomQuantity,
  'gps_photo_paths': instance.gpsPhotoPaths,
  'gps_latitude': instance.gpsLatitude,
  'gps_longitude': instance.gpsLongitude,
  'gps_accuracy_meters': instance.gpsAccuracyMeters,
  'gps_captured_at': instance.gpsCapturedAt?.toIso8601String(),
};

_SiteManager _$SiteManagerFromJson(Map<String, dynamic> json) => _SiteManager(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  roleLabel: json['role_label'] as String? ?? 'Project Manager',
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$SiteManagerToJson(_SiteManager instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'role_label': instance.roleLabel,
      'active': instance.active,
    };

_MaterialItem _$MaterialItemFromJson(Map<String, dynamic> json) =>
    _MaterialItem(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      sku: json['sku'] as String?,
      category: json['category'] as String?,
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$MaterialItemToJson(_MaterialItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'name': instance.name,
      'unit': instance.unit,
      'sku': instance.sku,
      'category': instance.category,
      'low_stock_threshold': instance.lowStockThreshold,
    };

_WarehouseStockRow _$WarehouseStockRowFromJson(Map<String, dynamic> json) =>
    _WarehouseStockRow(
      materialId: json['material_id'] as String,
      materialName: json['material_name'] as String,
      unit: json['unit'] as String,
      totalReceived: (json['total_received'] as num?)?.toDouble() ?? 0,
      totalIssued: (json['total_issued'] as num?)?.toDouble() ?? 0,
      remainingStock: (json['remaining_stock'] as num?)?.toDouble() ?? 0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0,
      stockStatus: json['stock_status'] as String? ?? 'in_stock',
    );

Map<String, dynamic> _$WarehouseStockRowToJson(_WarehouseStockRow instance) =>
    <String, dynamic>{
      'material_id': instance.materialId,
      'material_name': instance.materialName,
      'unit': instance.unit,
      'total_received': instance.totalReceived,
      'total_issued': instance.totalIssued,
      'remaining_stock': instance.remainingStock,
      'threshold': instance.threshold,
      'stock_status': instance.stockStatus,
    };

_MaterialDashboardSummary _$MaterialDashboardSummaryFromJson(
  Map<String, dynamic> json,
) => _MaterialDashboardSummary(
  totalSchools: (json['total_schools'] as num?)?.toInt() ?? 0,
  runningSchools: (json['running_schools'] as num?)?.toInt() ?? 0,
  completedSchools: (json['completed_schools'] as num?)?.toInt() ?? 0,
  pendingSchools: (json['pending_schools'] as num?)?.toInt() ?? 0,
  totalItemsInWarehouse:
      (json['total_items_in_warehouse'] as num?)?.toInt() ?? 0,
  lowStockItems: (json['low_stock_items'] as num?)?.toInt() ?? 0,
  totalReceivedQuantity:
      (json['total_received_quantity'] as num?)?.toDouble() ?? 0,
  totalIssuedQuantity: (json['total_issued_quantity'] as num?)?.toDouble() ?? 0,
  totalRemainingQuantity:
      (json['total_remaining_quantity'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$MaterialDashboardSummaryToJson(
  _MaterialDashboardSummary instance,
) => <String, dynamic>{
  'total_schools': instance.totalSchools,
  'running_schools': instance.runningSchools,
  'completed_schools': instance.completedSchools,
  'pending_schools': instance.pendingSchools,
  'total_items_in_warehouse': instance.totalItemsInWarehouse,
  'low_stock_items': instance.lowStockItems,
  'total_received_quantity': instance.totalReceivedQuantity,
  'total_issued_quantity': instance.totalIssuedQuantity,
  'total_remaining_quantity': instance.totalRemainingQuantity,
};

_SchoolRequirementIssueRow _$SchoolRequirementIssueRowFromJson(
  Map<String, dynamic> json,
) => _SchoolRequirementIssueRow(
  schoolId: json['school_id'] as String,
  schoolName: json['school_name'] as String,
  totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
  requiredPercent: (json['required_percent'] as num?)?.toDouble() ?? 0,
  issuedPercent: (json['issued_percent'] as num?)?.toDouble() ?? 0,
  pendingPercent: (json['pending_percent'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? 'pending',
);

Map<String, dynamic> _$SchoolRequirementIssueRowToJson(
  _SchoolRequirementIssueRow instance,
) => <String, dynamic>{
  'school_id': instance.schoolId,
  'school_name': instance.schoolName,
  'total_items': instance.totalItems,
  'required_percent': instance.requiredPercent,
  'issued_percent': instance.issuedPercent,
  'pending_percent': instance.pendingPercent,
  'status': instance.status,
};

_RecentMaterialIssue _$RecentMaterialIssueFromJson(Map<String, dynamic> json) =>
    _RecentMaterialIssue(
      issueId: json['issue_id'] as String,
      managerName: json['manager_name'] as String,
      schoolName: json['school_name'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      summaryText: json['summary_text'] as String,
      materialCount: (json['material_count'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['total_quantity'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$RecentMaterialIssueToJson(
  _RecentMaterialIssue instance,
) => <String, dynamic>{
  'issue_id': instance.issueId,
  'manager_name': instance.managerName,
  'school_name': instance.schoolName,
  'issue_date': instance.issueDate.toIso8601String(),
  'summary_text': instance.summaryText,
  'material_count': instance.materialCount,
  'total_quantity': instance.totalQuantity,
};

_LowStockAlert _$LowStockAlertFromJson(Map<String, dynamic> json) =>
    _LowStockAlert(
      materialId: json['material_id'] as String,
      materialName: json['material_name'] as String,
      unit: json['unit'] as String,
      remainingStock: (json['remaining_stock'] as num?)?.toDouble() ?? 0,
      alertLevel: json['alert_level'] as String? ?? 'low',
    );

Map<String, dynamic> _$LowStockAlertToJson(_LowStockAlert instance) =>
    <String, dynamic>{
      'material_id': instance.materialId,
      'material_name': instance.materialName,
      'unit': instance.unit,
      'remaining_stock': instance.remainingStock,
      'alert_level': instance.alertLevel,
    };

_ManagerMaterialIssueRow _$ManagerMaterialIssueRowFromJson(
  Map<String, dynamic> json,
) => _ManagerMaterialIssueRow(
  managerId: json['manager_id'] as String?,
  managerName: json['manager_name'] as String,
  schoolName: json['school_name'] as String,
  materialId: json['material_id'] as String,
  materialName: json['material_name'] as String,
  unit: json['unit'] as String,
  issuedQuantity: (json['issued_quantity'] as num?)?.toDouble() ?? 0,
  totalItems: (json['total_items'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ManagerMaterialIssueRowToJson(
  _ManagerMaterialIssueRow instance,
) => <String, dynamic>{
  'manager_id': instance.managerId,
  'manager_name': instance.managerName,
  'school_name': instance.schoolName,
  'material_id': instance.materialId,
  'material_name': instance.materialName,
  'unit': instance.unit,
  'issued_quantity': instance.issuedQuantity,
  'total_items': instance.totalItems,
};

_MaterialReceipt _$MaterialReceiptFromJson(Map<String, dynamic> json) =>
    _MaterialReceipt(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      tenderId: json['tender_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      materialId: json['material_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      receivedDate: json['received_date'] == null
          ? null
          : DateTime.parse(json['received_date'] as String),
      supplierName: json['supplier_name'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MaterialReceiptToJson(_MaterialReceipt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'tender_id': instance.tenderId,
      'warehouse_id': instance.warehouseId,
      'material_id': instance.materialId,
      'quantity': instance.quantity,
      'received_date': instance.receivedDate?.toIso8601String(),
      'supplier_name': instance.supplierName,
      'invoice_number': instance.invoiceNumber,
      'notes': instance.notes,
    };

_MaterialIssue _$MaterialIssueFromJson(Map<String, dynamic> json) =>
    _MaterialIssue(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      tenderId: json['tender_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      schoolId: json['school_id'] as String,
      materialId: json['material_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      managerId: json['manager_id'] as String?,
      issueDate: json['issue_date'] == null
          ? null
          : DateTime.parse(json['issue_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MaterialIssueToJson(_MaterialIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'tender_id': instance.tenderId,
      'warehouse_id': instance.warehouseId,
      'school_id': instance.schoolId,
      'material_id': instance.materialId,
      'quantity': instance.quantity,
      'manager_id': instance.managerId,
      'issue_date': instance.issueDate?.toIso8601String(),
      'notes': instance.notes,
    };

_MaterialReturn _$MaterialReturnFromJson(Map<String, dynamic> json) =>
    _MaterialReturn(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      tenderId: json['tender_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      schoolId: json['school_id'] as String,
      materialId: json['material_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      managerId: json['manager_id'] as String?,
      returnDate: json['return_date'] == null
          ? null
          : DateTime.parse(json['return_date'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MaterialReturnToJson(_MaterialReturn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'tender_id': instance.tenderId,
      'warehouse_id': instance.warehouseId,
      'school_id': instance.schoolId,
      'material_id': instance.materialId,
      'quantity': instance.quantity,
      'manager_id': instance.managerId,
      'return_date': instance.returnDate?.toIso8601String(),
      'reason': instance.reason,
      'notes': instance.notes,
    };
