import 'package:freezed_annotation/freezed_annotation.dart';

part 'infra_models.freezed.dart';
part 'infra_models.g.dart';

enum InfraProjectStatus { planning, active, onHold, completed, cancelled }

enum GovtFundStatus {
  sanctioned,
  partiallyReceived,
  fullyReceived,
  delayed,
  cancelled,
}

enum OrgMemberRole { owner, manager, accountant, siteStaff, viewer }

/// Canonical expense categories for infrastructure projects.
class ExpenseCategories {
  const ExpenseCategories._();
  static const values = <String>[
    'Material',
    'Labor',
    'Machine Rent',
    'Transport',
    'Government Fees',
    'Contractor',
    'Site Office',
    'Fuel',
    'Miscellaneous',
  ];
}

@freezed
abstract class InfraProject with _$InfraProject {
  const factory InfraProject({
    required String id,
    required String organizationId,
    required String name,
    String? code,
    String? category,
    String? locationCity,
    String? locationState,
    String? address,
    @Default(InfraProjectStatus.planning) InfraProjectStatus status,
    DateTime? startDate,
    DateTime? expectedEndDate,
    DateTime? actualEndDate,
    @Default(0) int progressPercent,
    @Default(0) int totalEstimatedCostPaise,
    @Default(0) int totalInvestmentPaise,
    @Default(0) int totalGovtSanctionedPaise,
    @Default(0) int totalGovtReceivedPaise,
    @Default(0) int totalExpensePaise,
    String? description,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _InfraProject;

  factory InfraProject.fromJson(Map<String, dynamic> json) =>
      _$InfraProjectFromJson(json);
}

@freezed
abstract class Investor with _$Investor {
  const factory Investor({
    required String id,
    required String organizationId,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? pan,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _Investor;

  factory Investor.fromJson(Map<String, dynamic> json) =>
      _$InvestorFromJson(json);
}

@freezed
abstract class ProjectInvestment with _$ProjectInvestment {
  const factory ProjectInvestment({
    required String id,
    required String projectId,
    required String investorId,
    @Default(0) int amountPaise,
    DateTime? investmentDate,
    @Default('bank') String paymentMode,
    String? referenceNumber,
    String? notes,
    String? investorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _ProjectInvestment;

  factory ProjectInvestment.fromJson(Map<String, dynamic> json) =>
      _$ProjectInvestmentFromJson(json);
}

@freezed
abstract class GovernmentFund with _$GovernmentFund {
  const factory GovernmentFund({
    required String id,
    required String projectId,
    required String departmentName,
    String? schemeName,
    String? sanctionOrderNumber,
    @Default(0) int amountSanctionedPaise,
    @Default(0) int amountReceivedPaise,
    DateTime? sanctionDate,
    DateTime? lastReceivedDate,
    @Default(GovtFundStatus.sanctioned) GovtFundStatus status,
    String? documentPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _GovernmentFund;

  factory GovernmentFund.fromJson(Map<String, dynamic> json) =>
      _$GovernmentFundFromJson(json);

  const GovernmentFund._();

  int get pendingAmountPaise =>
      (amountSanctionedPaise - amountReceivedPaise).clamp(0, 1 << 62);
}

@freezed
abstract class GovernmentFundReceipt with _$GovernmentFundReceipt {
  const factory GovernmentFundReceipt({
    required String id,
    required String governmentFundId,
    required String projectId,
    @Default(0) int amountPaise,
    DateTime? receivedDate,
    @Default('bank') String paymentMode,
    String? referenceNumber,
    String? documentPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _GovernmentFundReceipt;

  factory GovernmentFundReceipt.fromJson(Map<String, dynamic> json) =>
      _$GovernmentFundReceiptFromJson(json);
}

@freezed
abstract class ProjectExpense with _$ProjectExpense {
  const factory ProjectExpense({
    required String id,
    required String projectId,
    @Default('Miscellaneous') String category,
    String? vendorName,
    @Default(0) int amountPaise,
    DateTime? expenseDate,
    @Default('cash') String paymentMode,
    String? billNumber,
    String? billImagePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _ProjectExpense;

  factory ProjectExpense.fromJson(Map<String, dynamic> json) =>
      _$ProjectExpenseFromJson(json);
}

@freezed
abstract class ProjectDocument with _$ProjectDocument {
  const factory ProjectDocument({
    required String id,
    required String projectId,
    required String title,
    @Default('other') String documentType,
    required String storagePath,
    String? mimeType,
    int? sizeBytes,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) = _ProjectDocument;

  factory ProjectDocument.fromJson(Map<String, dynamic> json) =>
      _$ProjectDocumentFromJson(json);
}

@freezed
abstract class ProjectNote with _$ProjectNote {
  const factory ProjectNote({
    required String id,
    required String projectId,
    required String note,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _ProjectNote;

  factory ProjectNote.fromJson(Map<String, dynamic> json) =>
      _$ProjectNoteFromJson(json);
}

@freezed
abstract class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    String? ownerName,
    String? phone,
    String? address,
    String? logoPath,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

@freezed
abstract class InfraDashboardSummary with _$InfraDashboardSummary {
  const factory InfraDashboardSummary({
    @Default(0) int totalProjects,
    @Default(0) int activeProjects,
    @Default(0) int completedProjects,
    @Default(0) int delayedProjects,
    @Default(0) int totalInvestmentPaise,
    @Default(0) int totalGovtSanctionedPaise,
    @Default(0) int totalGovtReceivedPaise,
    @Default(0) int totalExpensePaise,
    @Default(0) int pendingGovtFundsPaise,
  }) = _InfraDashboardSummary;

  factory InfraDashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$InfraDashboardSummaryFromJson(json);
}

@freezed
abstract class ProjectFinancialSummary with _$ProjectFinancialSummary {
  const factory ProjectFinancialSummary({
    @Default(0) int totalInvestmentPaise,
    @Default(0) int totalGovtSanctionedPaise,
    @Default(0) int totalGovtReceivedPaise,
    @Default(0) int pendingGovtPaise,
    @Default(0) int totalExpensePaise,
    @Default(0) int availableBalancePaise,
  }) = _ProjectFinancialSummary;

  factory ProjectFinancialSummary.fromJson(Map<String, dynamic> json) =>
      _$ProjectFinancialSummaryFromJson(json);
}
