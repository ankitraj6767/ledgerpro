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

enum OrgMemberRole { owner, manager, accountant, siteStaff, viewer, customer }

extension OrgMemberRoleMapping on OrgMemberRole {
  static OrgMemberRole fromDb(String? value) => switch (value) {
    'owner' => OrgMemberRole.owner,
    'manager' => OrgMemberRole.manager,
    'accountant' => OrgMemberRole.accountant,
    'site_staff' => OrgMemberRole.siteStaff,
    'customer' => OrgMemberRole.customer,
    _ => OrgMemberRole.viewer,
  };

  String get dbValue => switch (this) {
    OrgMemberRole.owner => 'owner',
    OrgMemberRole.manager => 'manager',
    OrgMemberRole.accountant => 'accountant',
    OrgMemberRole.siteStaff => 'site_staff',
    OrgMemberRole.viewer => 'viewer',
    OrgMemberRole.customer => 'customer',
  };

  String get label => switch (this) {
    OrgMemberRole.owner => 'Owner',
    OrgMemberRole.manager => 'Manager',
    OrgMemberRole.accountant => 'Accountant',
    OrgMemberRole.siteStaff => 'Site Staff',
    OrgMemberRole.viewer => 'Viewer',
    OrgMemberRole.customer => 'Customer',
  };
}

class OrgPermissions {
  const OrgPermissions(this.role, {this.currentUserId});

  final OrgMemberRole? role;
  final String? currentUserId;

  bool get canReadOrg => role != null;
  bool get isCustomer => role == OrgMemberRole.customer;

  bool get canManageUsers =>
      role == OrgMemberRole.owner || role == OrgMemberRole.manager;

  bool get canEditSettings => canManageUsers;
  bool get canViewAuditLogs => canManageUsers;

  bool get canManageProjects =>
      role == OrgMemberRole.owner ||
      role == OrgMemberRole.manager ||
      role == OrgMemberRole.accountant;

  bool get canManageFunds => canManageProjects;
  bool get canManageInvestments => canManageProjects;
  bool get canUpdateProgress =>
      canManageProjects || role == OrgMemberRole.siteStaff;
  bool get canAddNotes => canManageProjects || role == OrgMemberRole.siteStaff;
  bool get canEditNotes => canAddNotes;
  bool get canDeleteNotes => canManageProjects;

  bool get canAddExpense =>
      canManageProjects ||
      role == OrgMemberRole.siteStaff ||
      role == OrgMemberRole.customer;

  bool canEditExpense(ProjectExpense expense) {
    if (canManageProjects || role == OrgMemberRole.siteStaff) return true;
    return role == OrgMemberRole.customer &&
        currentUserId != null &&
        expense.createdBy == currentUserId;
  }

  bool get canDeleteExpense => canManageProjects;

  // --- E-Pass challans -------------------------------------------------------
  // UI gating mirrors the `epass_challans` RLS policies, but RLS and the RPCs
  // remain the final authority: hiding a button never grants or denies access.

  /// Everyone with org access can read challans. Customers are additionally
  /// narrowed to their assigned projects by RLS.
  bool get canViewChallans => canReadOrg;

  /// Owner, manager, accountant and site staff can add challans.
  /// Viewers and customers cannot.
  bool get canAddChallan =>
      canManageProjects || role == OrgMemberRole.siteStaff;

  /// Deleting a challan is restricted to owner and manager. Deleting frees the
  /// challan number, so the same challan can be added again afterwards.
  bool get canDeleteChallan => canManageUsers;

  /// Legacy name retained so existing callers keep compiling.
  @Deprecated('Use canDeleteChallan instead')
  bool get canArchiveChallan => canDeleteChallan;

  bool get canExportChallans => canManageProjects;
}

/// A category and its optional nested subcategories as shown by the expense
/// picker.
class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    this.subcategories = const <String>[],
  });

  final String name;
  final List<String> subcategories;

  bool get hasSubcategories => subcategories.isNotEmpty;
}

/// A concrete value selected from the expense category tree.
class ExpenseCategorySelection {
  const ExpenseCategorySelection({required this.category, this.subcategory});

  final String category;
  final String? subcategory;

  String get displayLabel {
    final child = subcategory?.trim();
    return child == null || child.isEmpty ? category : '$category / $child';
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseCategorySelection &&
        other.category == category &&
        other.subcategory == subcategory;
  }

  @override
  int get hashCode => Object.hash(category, subcategory);
}

/// Dynamic expense categories learned from the values already used in a
/// project. Categories and subcategories remain free text; this class only
/// groups saved values to make them easier to select again.
class ExpenseCategories {
  const ExpenseCategories._();

  /// Builds a category tree from saved parent/child values without imposing
  /// an enum. The first spelling encountered is retained while duplicate
  /// values are merged case-insensitively.
  static List<ExpenseCategory> fromSelections(
    Iterable<ExpenseCategorySelection> selections,
  ) {
    final grouped = <String, _ExpenseCategoryAccumulator>{};
    for (final selection in selections) {
      final categoryName = selection.category.trim();
      if (categoryName.isEmpty) continue;

      final categoryKey = categoryName.toLowerCase();
      final category = grouped.putIfAbsent(
        categoryKey,
        () => _ExpenseCategoryAccumulator(categoryName),
      );
      final subcategoryName = selection.subcategory?.trim();
      if (subcategoryName != null && subcategoryName.isNotEmpty) {
        category.subcategories.putIfAbsent(
          subcategoryName.toLowerCase(),
          () => subcategoryName,
        );
      }
    }

    return grouped.values
        .map(
          (category) => ExpenseCategory(
            name: category.name,
            subcategories: category.subcategories.values.toList(
              growable: false,
            ),
          ),
        )
        .toList(growable: false);
  }

  static bool matches(ExpenseCategory category, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return category.name.toLowerCase().contains(normalized) ||
        category.subcategories.any(
          (subcategory) => subcategory.toLowerCase().contains(normalized),
        );
  }

  /// Existing project categories in first-seen order. Matching is
  /// case-insensitive so values such as "fuel" and "Fuel" are offered only
  /// once while preserving the first saved spelling.
  static List<String> suggestions(Iterable<String> existing) {
    final unique = <String, String>{};
    for (final category in existing) {
      final trimmed = category.trim();
      if (trimmed.isNotEmpty) {
        unique.putIfAbsent(trimmed.toLowerCase(), () => trimmed);
      }
    }
    return unique.values.toList(growable: false);
  }

  static Iterable<String> matching(Iterable<String> options, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const <String>[];
    return options.where(
      (category) => category.toLowerCase().contains(normalized),
    );
  }
}

class _ExpenseCategoryAccumulator {
  _ExpenseCategoryAccumulator(this.name);

  final String name;
  final Map<String, String> subcategories = <String, String>{};
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
    @Default(0) int totalInvestmentReturnedPaise,
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

extension InfraProjectFinancialProgress on InfraProject {
  int get netInvestmentPaise =>
      (totalInvestmentPaise - totalInvestmentReturnedPaise).clamp(0, 1 << 62);

  /// Percentage of the estimated project cost funded by investments and
  /// received government funds. Derived from live totals, never entered
  /// manually.
  int get financialProgressPercent {
    if (totalEstimatedCostPaise <= 0) return 0;
    final fundedPaise = netInvestmentPaise + totalGovtReceivedPaise;
    if (fundedPaise <= 0) return 0;
    return ((fundedPaise * 100) / totalEstimatedCostPaise).round().clamp(
      0,
      100,
    );
  }
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
    String? subcategory,
    String? vendorName,
    @Default(0) int amountPaise,
    DateTime? expenseDate,
    @Default('cash') String paymentMode,
    String? billNumber,
    String? billImagePath,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _ProjectExpense;

  factory ProjectExpense.fromJson(Map<String, dynamic> json) =>
      _$ProjectExpenseFromJson(json);
}

extension ProjectExpenseCategoryDisplay on ProjectExpense {
  /// Human-readable category value while keeping parent and child separately
  /// persisted for filtering and reporting.
  String get categoryLabel {
    final parent = category.trim();
    final child = subcategory?.trim();
    if (parent.isEmpty) {
      return child == null || child.isEmpty ? 'General Expense' : child;
    }
    return child == null || child.isEmpty ? parent : '$parent / $child';
  }
}

/// A presentation group for the Expenses tab.
///
/// This groups the existing expense transactions by their free-text parent
/// category. It deliberately keeps every transaction in [expenses] so that
/// expanding a category does not lose duplicate subcategories or any of the
/// existing edit, delete, selection, and PDF actions.
class ProjectExpenseCategoryGroup {
  const ProjectExpenseCategoryGroup({
    required this.category,
    required this.categoryKey,
    required this.expenses,
  });

  final String category;
  final String categoryKey;
  final List<ProjectExpense> expenses;

  bool get hasSubcategories => expenses.any(
    (expense) => expense.subcategory?.trim().isNotEmpty ?? false,
  );

  int get totalAmountPaise =>
      expenses.fold<int>(0, (total, expense) => total + expense.amountPaise);

  /// Groups by category without imposing an enum or changing the order of
  /// the incoming list. The first spelling is retained for display and
  /// duplicate category values are merged case-insensitively.
  static List<ProjectExpenseCategoryGroup> fromExpenses(
    Iterable<ProjectExpense> expenses,
  ) {
    final grouped = <String, _ProjectExpenseCategoryGroupAccumulator>{};

    for (final expense in expenses) {
      final category = expense.category.trim();
      final displayCategory = category.isEmpty ? 'General Expense' : category;
      final categoryKey = displayCategory.toLowerCase();
      final group = grouped.putIfAbsent(
        categoryKey,
        () => _ProjectExpenseCategoryGroupAccumulator(
          category: displayCategory,
          categoryKey: categoryKey,
        ),
      );
      group.expenses.add(expense);
    }

    return grouped.values
        .map(
          (group) => ProjectExpenseCategoryGroup(
            category: group.category,
            categoryKey: group.categoryKey,
            expenses: List<ProjectExpense>.unmodifiable(group.expenses),
          ),
        )
        .toList(growable: false);
  }
}

class _ProjectExpenseCategoryGroupAccumulator {
  _ProjectExpenseCategoryGroupAccumulator({
    required this.category,
    required this.categoryKey,
  });

  final String category;
  final String categoryKey;
  final List<ProjectExpense> expenses = <ProjectExpense>[];
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

class InfraWorkspaceSession {
  const InfraWorkspaceSession({required this.organization, required this.role});

  final Organization organization;
  final OrgMemberRole role;

  String get id => organization.id;
  String get name => organization.name;
}

class CustomerMember {
  const CustomerMember({
    required this.memberId,
    required this.userId,
    required this.role,
    this.fullName,
    this.email,
    this.phone,
    this.notes,
    this.createdAt,
  });

  final String memberId;
  final String userId;
  final OrgMemberRole role;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? notes;
  final DateTime? createdAt;
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

extension ProjectFinancialSummaryMath on ProjectFinancialSummary {
  int get cashInPaise => totalInvestmentPaise + totalGovtReceivedPaise;

  int get calculatedAvailableBalancePaise => cashInPaise - totalExpensePaise;
}

@freezed
abstract class InvestmentReturn with _$InvestmentReturn {
  const factory InvestmentReturn({
    required String id,
    required String projectId,
    required String investorId,
    @Default(0) int amountPaise,
    DateTime? returnDate,
    @Default('bank') String paymentMode,
    String? referenceNumber,
    String? notes,
    String? investorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _InvestmentReturn;

  factory InvestmentReturn.fromJson(Map<String, dynamic> json) =>
      _$InvestmentReturnFromJson(json);
}
