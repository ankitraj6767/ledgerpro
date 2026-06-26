// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'infra_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InfraProject _$InfraProjectFromJson(Map<String, dynamic> json) =>
    _InfraProject(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      category: json['category'] as String?,
      locationCity: json['locationCity'] as String?,
      locationState: json['locationState'] as String?,
      address: json['address'] as String?,
      status:
          $enumDecodeNullable(_$InfraProjectStatusEnumMap, json['status']) ??
          InfraProjectStatus.planning,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      expectedEndDate: json['expectedEndDate'] == null
          ? null
          : DateTime.parse(json['expectedEndDate'] as String),
      actualEndDate: json['actualEndDate'] == null
          ? null
          : DateTime.parse(json['actualEndDate'] as String),
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
      totalEstimatedCostPaise:
          (json['totalEstimatedCostPaise'] as num?)?.toInt() ?? 0,
      totalInvestmentPaise:
          (json['totalInvestmentPaise'] as num?)?.toInt() ?? 0,
      totalGovtSanctionedPaise:
          (json['totalGovtSanctionedPaise'] as num?)?.toInt() ?? 0,
      totalGovtReceivedPaise:
          (json['totalGovtReceivedPaise'] as num?)?.toInt() ?? 0,
      totalExpensePaise: (json['totalExpensePaise'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$InfraProjectToJson(_InfraProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'name': instance.name,
      'code': instance.code,
      'category': instance.category,
      'locationCity': instance.locationCity,
      'locationState': instance.locationState,
      'address': instance.address,
      'status': _$InfraProjectStatusEnumMap[instance.status]!,
      'startDate': instance.startDate?.toIso8601String(),
      'expectedEndDate': instance.expectedEndDate?.toIso8601String(),
      'actualEndDate': instance.actualEndDate?.toIso8601String(),
      'progressPercent': instance.progressPercent,
      'totalEstimatedCostPaise': instance.totalEstimatedCostPaise,
      'totalInvestmentPaise': instance.totalInvestmentPaise,
      'totalGovtSanctionedPaise': instance.totalGovtSanctionedPaise,
      'totalGovtReceivedPaise': instance.totalGovtReceivedPaise,
      'totalExpensePaise': instance.totalExpensePaise,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$InfraProjectStatusEnumMap = {
  InfraProjectStatus.planning: 'planning',
  InfraProjectStatus.active: 'active',
  InfraProjectStatus.onHold: 'onHold',
  InfraProjectStatus.completed: 'completed',
  InfraProjectStatus.cancelled: 'cancelled',
};

_Investor _$InvestorFromJson(Map<String, dynamic> json) => _Investor(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  pan: json['pan'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$InvestorToJson(_Investor instance) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'pan': instance.pan,
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_ProjectInvestment _$ProjectInvestmentFromJson(Map<String, dynamic> json) =>
    _ProjectInvestment(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      investorId: json['investorId'] as String,
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      investmentDate: json['investmentDate'] == null
          ? null
          : DateTime.parse(json['investmentDate'] as String),
      paymentMode: json['paymentMode'] as String? ?? 'bank',
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      investorName: json['investorName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$ProjectInvestmentToJson(_ProjectInvestment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'investorId': instance.investorId,
      'amountPaise': instance.amountPaise,
      'investmentDate': instance.investmentDate?.toIso8601String(),
      'paymentMode': instance.paymentMode,
      'referenceNumber': instance.referenceNumber,
      'notes': instance.notes,
      'investorName': instance.investorName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_GovernmentFund _$GovernmentFundFromJson(Map<String, dynamic> json) =>
    _GovernmentFund(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      departmentName: json['departmentName'] as String,
      schemeName: json['schemeName'] as String?,
      sanctionOrderNumber: json['sanctionOrderNumber'] as String?,
      amountSanctionedPaise:
          (json['amountSanctionedPaise'] as num?)?.toInt() ?? 0,
      amountReceivedPaise: (json['amountReceivedPaise'] as num?)?.toInt() ?? 0,
      sanctionDate: json['sanctionDate'] == null
          ? null
          : DateTime.parse(json['sanctionDate'] as String),
      lastReceivedDate: json['lastReceivedDate'] == null
          ? null
          : DateTime.parse(json['lastReceivedDate'] as String),
      status:
          $enumDecodeNullable(_$GovtFundStatusEnumMap, json['status']) ??
          GovtFundStatus.sanctioned,
      documentPath: json['documentPath'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$GovernmentFundToJson(_GovernmentFund instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'departmentName': instance.departmentName,
      'schemeName': instance.schemeName,
      'sanctionOrderNumber': instance.sanctionOrderNumber,
      'amountSanctionedPaise': instance.amountSanctionedPaise,
      'amountReceivedPaise': instance.amountReceivedPaise,
      'sanctionDate': instance.sanctionDate?.toIso8601String(),
      'lastReceivedDate': instance.lastReceivedDate?.toIso8601String(),
      'status': _$GovtFundStatusEnumMap[instance.status]!,
      'documentPath': instance.documentPath,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$GovtFundStatusEnumMap = {
  GovtFundStatus.sanctioned: 'sanctioned',
  GovtFundStatus.partiallyReceived: 'partiallyReceived',
  GovtFundStatus.fullyReceived: 'fullyReceived',
  GovtFundStatus.delayed: 'delayed',
  GovtFundStatus.cancelled: 'cancelled',
};

_GovernmentFundReceipt _$GovernmentFundReceiptFromJson(
  Map<String, dynamic> json,
) => _GovernmentFundReceipt(
  id: json['id'] as String,
  governmentFundId: json['governmentFundId'] as String,
  projectId: json['projectId'] as String,
  amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
  receivedDate: json['receivedDate'] == null
      ? null
      : DateTime.parse(json['receivedDate'] as String),
  paymentMode: json['paymentMode'] as String? ?? 'bank',
  referenceNumber: json['referenceNumber'] as String?,
  documentPath: json['documentPath'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$GovernmentFundReceiptToJson(
  _GovernmentFundReceipt instance,
) => <String, dynamic>{
  'id': instance.id,
  'governmentFundId': instance.governmentFundId,
  'projectId': instance.projectId,
  'amountPaise': instance.amountPaise,
  'receivedDate': instance.receivedDate?.toIso8601String(),
  'paymentMode': instance.paymentMode,
  'referenceNumber': instance.referenceNumber,
  'documentPath': instance.documentPath,
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_ProjectExpense _$ProjectExpenseFromJson(Map<String, dynamic> json) =>
    _ProjectExpense(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      category: json['category'] as String? ?? 'Miscellaneous',
      vendorName: json['vendorName'] as String?,
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      expenseDate: json['expenseDate'] == null
          ? null
          : DateTime.parse(json['expenseDate'] as String),
      paymentMode: json['paymentMode'] as String? ?? 'cash',
      billNumber: json['billNumber'] as String?,
      billImagePath: json['billImagePath'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$ProjectExpenseToJson(_ProjectExpense instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'category': instance.category,
      'vendorName': instance.vendorName,
      'amountPaise': instance.amountPaise,
      'expenseDate': instance.expenseDate?.toIso8601String(),
      'paymentMode': instance.paymentMode,
      'billNumber': instance.billNumber,
      'billImagePath': instance.billImagePath,
      'notes': instance.notes,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_ProjectDocument _$ProjectDocumentFromJson(Map<String, dynamic> json) =>
    _ProjectDocument(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      documentType: json['documentType'] as String? ?? 'other',
      storagePath: json['storagePath'] as String,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      uploadedBy: json['uploadedBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$ProjectDocumentToJson(_ProjectDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'title': instance.title,
      'documentType': instance.documentType,
      'storagePath': instance.storagePath,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'uploadedBy': instance.uploadedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_ProjectNote _$ProjectNoteFromJson(Map<String, dynamic> json) => _ProjectNote(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  note: json['note'] as String,
  createdBy: json['createdBy'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$ProjectNoteToJson(_ProjectNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'note': instance.note,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_Organization _$OrganizationFromJson(Map<String, dynamic> json) =>
    _Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoPath: json['logoPath'] as String?,
    );

Map<String, dynamic> _$OrganizationToJson(_Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerName': instance.ownerName,
      'phone': instance.phone,
      'address': instance.address,
      'logoPath': instance.logoPath,
    };

_InfraDashboardSummary _$InfraDashboardSummaryFromJson(
  Map<String, dynamic> json,
) => _InfraDashboardSummary(
  totalProjects: (json['totalProjects'] as num?)?.toInt() ?? 0,
  activeProjects: (json['activeProjects'] as num?)?.toInt() ?? 0,
  completedProjects: (json['completedProjects'] as num?)?.toInt() ?? 0,
  delayedProjects: (json['delayedProjects'] as num?)?.toInt() ?? 0,
  totalInvestmentPaise: (json['totalInvestmentPaise'] as num?)?.toInt() ?? 0,
  totalGovtSanctionedPaise:
      (json['totalGovtSanctionedPaise'] as num?)?.toInt() ?? 0,
  totalGovtReceivedPaise:
      (json['totalGovtReceivedPaise'] as num?)?.toInt() ?? 0,
  totalExpensePaise: (json['totalExpensePaise'] as num?)?.toInt() ?? 0,
  pendingGovtFundsPaise: (json['pendingGovtFundsPaise'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InfraDashboardSummaryToJson(
  _InfraDashboardSummary instance,
) => <String, dynamic>{
  'totalProjects': instance.totalProjects,
  'activeProjects': instance.activeProjects,
  'completedProjects': instance.completedProjects,
  'delayedProjects': instance.delayedProjects,
  'totalInvestmentPaise': instance.totalInvestmentPaise,
  'totalGovtSanctionedPaise': instance.totalGovtSanctionedPaise,
  'totalGovtReceivedPaise': instance.totalGovtReceivedPaise,
  'totalExpensePaise': instance.totalExpensePaise,
  'pendingGovtFundsPaise': instance.pendingGovtFundsPaise,
};

_ProjectFinancialSummary _$ProjectFinancialSummaryFromJson(
  Map<String, dynamic> json,
) => _ProjectFinancialSummary(
  totalInvestmentPaise: (json['totalInvestmentPaise'] as num?)?.toInt() ?? 0,
  totalGovtSanctionedPaise:
      (json['totalGovtSanctionedPaise'] as num?)?.toInt() ?? 0,
  totalGovtReceivedPaise:
      (json['totalGovtReceivedPaise'] as num?)?.toInt() ?? 0,
  pendingGovtPaise: (json['pendingGovtPaise'] as num?)?.toInt() ?? 0,
  totalExpensePaise: (json['totalExpensePaise'] as num?)?.toInt() ?? 0,
  availableBalancePaise: (json['availableBalancePaise'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProjectFinancialSummaryToJson(
  _ProjectFinancialSummary instance,
) => <String, dynamic>{
  'totalInvestmentPaise': instance.totalInvestmentPaise,
  'totalGovtSanctionedPaise': instance.totalGovtSanctionedPaise,
  'totalGovtReceivedPaise': instance.totalGovtReceivedPaise,
  'pendingGovtPaise': instance.pendingGovtPaise,
  'totalExpensePaise': instance.totalExpensePaise,
  'availableBalancePaise': instance.availableBalancePaise,
};

_InvestmentReturn _$InvestmentReturnFromJson(Map<String, dynamic> json) =>
    _InvestmentReturn(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      investorId: json['investorId'] as String,
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      returnDate: json['returnDate'] == null
          ? null
          : DateTime.parse(json['returnDate'] as String),
      paymentMode: json['paymentMode'] as String? ?? 'bank',
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      investorName: json['investorName'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InvestmentReturnToJson(_InvestmentReturn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'investorId': instance.investorId,
      'amountPaise': instance.amountPaise,
      'returnDate': instance.returnDate?.toIso8601String(),
      'paymentMode': instance.paymentMode,
      'referenceNumber': instance.referenceNumber,
      'notes': instance.notes,
      'investorName': instance.investorName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
