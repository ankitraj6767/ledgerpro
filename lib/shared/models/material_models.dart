// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_models.freezed.dart';
part 'material_models.g.dart';

@freezed
abstract class Tender with _$Tender {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Tender({
    required String id,
    required String organizationId,
    required String name,
    String? code,
    int? year,
    @Default('active') String status,
    String? description,
  }) = _Tender;

  factory Tender.fromJson(Map<String, dynamic> json) => _$TenderFromJson(json);
}

@freezed
abstract class District with _$District {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory District({
    required String id,
    required String organizationId,
    required String name,
    String? state,
  }) = _District;

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);
}

@freezed
abstract class Warehouse with _$Warehouse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Warehouse({
    required String id,
    required String organizationId,
    required String name,
    String? districtId,
    String? address,
    String? managerName,
    String? phone,
    @Default(false) bool isCentral,
  }) = _Warehouse;

  factory Warehouse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseFromJson(json);
}

@freezed
abstract class School with _$School {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory School({
    required String id,
    required String organizationId,
    required String tenderId,
    required String name,
    String? districtId,
    String? code,
    String? address,
    @Default('not_started') String status,
    @Default(0) int progressPercent,
    String? assignedManagerId,
    @Default(0) int roomQuantity,
    @Default(<String>[]) List<String> gpsPhotoPaths,
    double? gpsLatitude,
    double? gpsLongitude,
    double? gpsAccuracyMeters,
    DateTime? gpsCapturedAt,
  }) = _School;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}

@freezed
abstract class SiteManager with _$SiteManager {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SiteManager({
    required String id,
    required String organizationId,
    required String fullName,
    String? phone,
    String? email,
    @Default('Project Manager') String roleLabel,
    @Default(true) bool active,
  }) = _SiteManager;

  factory SiteManager.fromJson(Map<String, dynamic> json) =>
      _$SiteManagerFromJson(json);
}

@freezed
abstract class MaterialItem with _$MaterialItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MaterialItem({
    required String id,
    required String organizationId,
    required String name,
    required String unit,
    String? sku,
    String? category,
    @Default(0) double lowStockThreshold,
  }) = _MaterialItem;

  factory MaterialItem.fromJson(Map<String, dynamic> json) =>
      _$MaterialItemFromJson(json);
}

@freezed
abstract class WarehouseStockRow with _$WarehouseStockRow {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WarehouseStockRow({
    required String materialId,
    required String materialName,
    required String unit,
    @Default(0) double totalReceived,
    @Default(0) double totalIssued,
    @Default(0) double remainingStock,
    @Default(0) double threshold,
    @Default('in_stock') String stockStatus,
  }) = _WarehouseStockRow;

  factory WarehouseStockRow.fromJson(Map<String, dynamic> json) =>
      _$WarehouseStockRowFromJson(json);
}

@freezed
abstract class MaterialDashboardSummary with _$MaterialDashboardSummary {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MaterialDashboardSummary({
    @Default(0) int totalSchools,
    @Default(0) int runningSchools,
    @Default(0) int completedSchools,
    @Default(0) int pendingSchools,
    @Default(0) int totalItemsInWarehouse,
    @Default(0) int lowStockItems,
    @Default(0) double totalReceivedQuantity,
    @Default(0) double totalIssuedQuantity,
    @Default(0) double totalRemainingQuantity,
  }) = _MaterialDashboardSummary;

  factory MaterialDashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$MaterialDashboardSummaryFromJson(json);
}

@freezed
abstract class SchoolRequirementIssueRow with _$SchoolRequirementIssueRow {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SchoolRequirementIssueRow({
    required String schoolId,
    required String schoolName,
    @Default(0) int totalItems,
    @Default(0) double requiredPercent,
    @Default(0) double issuedPercent,
    @Default(0) double pendingPercent,
    @Default('pending') String status,
  }) = _SchoolRequirementIssueRow;

  factory SchoolRequirementIssueRow.fromJson(Map<String, dynamic> json) =>
      _$SchoolRequirementIssueRowFromJson(json);
}

@freezed
abstract class RecentMaterialIssue with _$RecentMaterialIssue {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RecentMaterialIssue({
    required String issueId,
    required String managerName,
    required String schoolName,
    required DateTime issueDate,
    required String summaryText,
    @Default(0) int materialCount,
    @Default(0) double totalQuantity,
  }) = _RecentMaterialIssue;

  factory RecentMaterialIssue.fromJson(Map<String, dynamic> json) =>
      _$RecentMaterialIssueFromJson(json);
}

@freezed
abstract class LowStockAlert with _$LowStockAlert {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LowStockAlert({
    required String materialId,
    required String materialName,
    required String unit,
    @Default(0) double remainingStock,
    @Default('low') String alertLevel,
  }) = _LowStockAlert;

  factory LowStockAlert.fromJson(Map<String, dynamic> json) =>
      _$LowStockAlertFromJson(json);
}

@freezed
abstract class ManagerMaterialIssueRow with _$ManagerMaterialIssueRow {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ManagerMaterialIssueRow({
    String? managerId,
    required String managerName,
    required String schoolName,
    required String materialId,
    required String materialName,
    required String unit,
    @Default(0) double issuedQuantity,
    @Default(0) double totalItems,
  }) = _ManagerMaterialIssueRow;

  factory ManagerMaterialIssueRow.fromJson(Map<String, dynamic> json) =>
      _$ManagerMaterialIssueRowFromJson(json);
}

@freezed
abstract class MaterialReceipt with _$MaterialReceipt {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MaterialReceipt({
    required String id,
    required String organizationId,
    required String tenderId,
    required String warehouseId,
    required String materialId,
    required double quantity,
    DateTime? receivedDate,
    String? supplierName,
    String? invoiceNumber,
    String? notes,
  }) = _MaterialReceipt;

  factory MaterialReceipt.fromJson(Map<String, dynamic> json) =>
      _$MaterialReceiptFromJson(json);
}

@freezed
abstract class MaterialIssue with _$MaterialIssue {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MaterialIssue({
    required String id,
    required String organizationId,
    required String tenderId,
    required String warehouseId,
    required String schoolId,
    required String materialId,
    required double quantity,
    String? managerId,
    DateTime? issueDate,
    String? notes,
  }) = _MaterialIssue;

  factory MaterialIssue.fromJson(Map<String, dynamic> json) =>
      _$MaterialIssueFromJson(json);
}

@freezed
abstract class MaterialReturn with _$MaterialReturn {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MaterialReturn({
    required String id,
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
  }) = _MaterialReturn;

  factory MaterialReturn.fromJson(Map<String, dynamic> json) =>
      _$MaterialReturnFromJson(json);
}

String formatQuantity(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}
