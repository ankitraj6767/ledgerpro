// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Party _$PartyFromJson(Map<String, dynamic> json) => _Party(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  bookId: json['bookId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  type:
      $enumDecodeNullable(_$PartyTypeEnumMap, json['type']) ??
      PartyType.customer,
  balancePaise: (json['balancePaise'] as num?)?.toInt() ?? 0,
  creditLimitPaise: (json['creditLimitPaise'] as num?)?.toInt() ?? 0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  alternatePhone: json['alternatePhone'] as String?,
  address: json['address'] as String?,
  gstin: json['gstin'] as String?,
  upiId: json['upiId'] as String?,
  notes: json['notes'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
      SyncStatus.synced,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$PartyToJson(_Party instance) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'bookId': instance.bookId,
  'name': instance.name,
  'phone': instance.phone,
  'type': _$PartyTypeEnumMap[instance.type]!,
  'balancePaise': instance.balancePaise,
  'creditLimitPaise': instance.creditLimitPaise,
  'tags': instance.tags,
  'alternatePhone': instance.alternatePhone,
  'address': instance.address,
  'gstin': instance.gstin,
  'upiId': instance.upiId,
  'notes': instance.notes,
  'profileImageUrl': instance.profileImageUrl,
  'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
  'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

const _$PartyTypeEnumMap = {
  PartyType.customer: 'customer',
  PartyType.supplier: 'supplier',
  PartyType.both: 'both',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.failed: 'failed',
};

_LedgerTransaction _$LedgerTransactionFromJson(Map<String, dynamic> json) =>
    _LedgerTransaction(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      bookId: json['bookId'] as String,
      partyId: json['partyId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amountPaise: (json['amountPaise'] as num).toInt(),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      paymentMode:
          $enumDecodeNullable(_$PaymentModeEnumMap, json['paymentMode']) ??
          PaymentMode.cash,
      note: json['note'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      reminderDate: json['reminderDate'] == null
          ? null
          : DateTime.parse(json['reminderDate'] as String),
      attachmentPath: json['attachmentPath'] as String?,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      reversalOfTransactionId: json['reversalOfTransactionId'] as String?,
      isReversal: json['isReversal'] as bool? ?? false,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.pending,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$LedgerTransactionToJson(_LedgerTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'bookId': instance.bookId,
      'partyId': instance.partyId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amountPaise': instance.amountPaise,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'paymentMode': _$PaymentModeEnumMap[instance.paymentMode]!,
      'note': instance.note,
      'dueDate': instance.dueDate?.toIso8601String(),
      'reminderDate': instance.reminderDate?.toIso8601String(),
      'attachmentPath': instance.attachmentPath,
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
      'reversalOfTransactionId': instance.reversalOfTransactionId,
      'isReversal': instance.isReversal,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.youGave: 'youGave',
  TransactionType.youGot: 'youGot',
  TransactionType.sale: 'sale',
  TransactionType.purchase: 'purchase',
  TransactionType.expense: 'expense',
  TransactionType.refund: 'refund',
  TransactionType.adjustment: 'adjustment',
  TransactionType.discountWriteOff: 'discountWriteOff',
  TransactionType.openingBalance: 'openingBalance',
};

const _$PaymentModeEnumMap = {
  PaymentMode.cash: 'cash',
  PaymentMode.upi: 'upi',
  PaymentMode.bank: 'bank',
  PaymentMode.card: 'card',
  PaymentMode.cheque: 'cheque',
  PaymentMode.wallet: 'wallet',
  PaymentMode.other: 'other',
};

_BusinessProfile _$BusinessProfileFromJson(Map<String, dynamic> json) =>
    _BusinessProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['ownerName'] as String?,
      phone: json['phone'] as String?,
      upiId: json['upiId'] as String?,
      gstin: json['gstin'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$BusinessProfileToJson(_BusinessProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerName': instance.ownerName,
      'phone': instance.phone,
      'upiId': instance.upiId,
      'gstin': instance.gstin,
      'address': instance.address,
    };

_BusinessSummary _$BusinessSummaryFromJson(Map<String, dynamic> json) =>
    _BusinessSummary(
      totalReceivablePaise: (json['totalReceivablePaise'] as num).toInt(),
      totalPayablePaise: (json['totalPayablePaise'] as num).toInt(),
      todayCollectionPaise: (json['todayCollectionPaise'] as num).toInt(),
      todayCreditGivenPaise: (json['todayCreditGivenPaise'] as num).toInt(),
      overdueParties: (json['overdueParties'] as num).toInt(),
      activeParties: (json['activeParties'] as num).toInt(),
      lowStockItems: (json['lowStockItems'] as num).toInt(),
      pendingSyncItems: (json['pendingSyncItems'] as num).toInt(),
    );

Map<String, dynamic> _$BusinessSummaryToJson(_BusinessSummary instance) =>
    <String, dynamic>{
      'totalReceivablePaise': instance.totalReceivablePaise,
      'totalPayablePaise': instance.totalPayablePaise,
      'todayCollectionPaise': instance.todayCollectionPaise,
      'todayCreditGivenPaise': instance.todayCreditGivenPaise,
      'overdueParties': instance.overdueParties,
      'activeParties': instance.activeParties,
      'lowStockItems': instance.lowStockItems,
      'pendingSyncItems': instance.pendingSyncItems,
    };

_ReminderTemplate _$ReminderTemplateFromJson(Map<String, dynamic> json) =>
    _ReminderTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      languageCode: json['languageCode'] as String,
      body: json['body'] as String,
      firmTone: json['firmTone'] as bool? ?? false,
    );

Map<String, dynamic> _$ReminderTemplateToJson(_ReminderTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'languageCode': instance.languageCode,
      'body': instance.body,
      'firmTone': instance.firmTone,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  name: json['name'] as String,
  unit: json['unit'] as String,
  salePricePaise: (json['salePricePaise'] as num?)?.toInt() ?? 0,
  purchasePricePaise: (json['purchasePricePaise'] as num?)?.toInt() ?? 0,
  stockOnHand: (json['stockOnHand'] as num?)?.toInt() ?? 0,
  lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 0,
  sku: json['sku'] as String?,
  barcode: json['barcode'] as String?,
  category: json['category'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'name': instance.name,
  'unit': instance.unit,
  'salePricePaise': instance.salePricePaise,
  'purchasePricePaise': instance.purchasePricePaise,
  'stockOnHand': instance.stockOnHand,
  'lowStockThreshold': instance.lowStockThreshold,
  'sku': instance.sku,
  'barcode': instance.barcode,
  'category': instance.category,
  'imageUrl': instance.imageUrl,
};

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  bookId: json['bookId'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  partyId: json['partyId'] as String,
  date: DateTime.parse(json['date'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  subtotalPaise: (json['subtotalPaise'] as num?)?.toInt() ?? 0,
  gstPaise: (json['gstPaise'] as num?)?.toInt() ?? 0,
  totalPaise: (json['totalPaise'] as num?)?.toInt() ?? 0,
  paidPaise: (json['paidPaise'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
      InvoiceStatus.draft,
  notes: json['notes'] as String?,
  terms: json['terms'] as String?,
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'bookId': instance.bookId,
  'invoiceNumber': instance.invoiceNumber,
  'partyId': instance.partyId,
  'date': instance.date.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
  'subtotalPaise': instance.subtotalPaise,
  'gstPaise': instance.gstPaise,
  'totalPaise': instance.totalPaise,
  'paidPaise': instance.paidPaise,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'terms': instance.terms,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.partiallyPaid: 'partiallyPaid',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
};
