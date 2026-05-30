import 'package:freezed_annotation/freezed_annotation.dart';

part 'ledger_models.freezed.dart';
part 'ledger_models.g.dart';

enum PartyType { customer, supplier, both }

enum TransactionType {
  youGave,
  youGot,
  sale,
  purchase,
  expense,
  refund,
  adjustment,
  discountWriteOff,
  openingBalance,
}

enum PaymentMode { cash, upi, bank, card, cheque, wallet, other }

enum SyncStatus { synced, pending, failed }

enum MemberRole { owner, manager, accountant, staff }

enum PaymentStatus {
  pending,
  manuallyConfirmed,
  gatewayConfirmed,
  failed,
  cancelled,
}

enum InvoiceStatus { draft, sent, partiallyPaid, paid, overdue, cancelled }

@freezed
abstract class Party with _$Party {
  const factory Party({
    required String id,
    required String businessId,
    required String bookId,
    required String name,
    required String phone,
    @Default(PartyType.customer) PartyType type,
    @Default(0) int balancePaise,
    @Default(0) int creditLimitPaise,
    @Default(<String>[]) List<String> tags,
    String? alternatePhone,
    String? address,
    String? gstin,
    String? upiId,
    String? notes,
    String? profileImageUrl,
    DateTime? lastActivityAt,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? deletedAt,
  }) = _Party;

  factory Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);
}

@freezed
abstract class LedgerTransaction with _$LedgerTransaction {
  const factory LedgerTransaction({
    required String id,
    required String businessId,
    required String bookId,
    required String partyId,
    required TransactionType type,
    required int amountPaise,
    required DateTime occurredAt,
    @Default(PaymentMode.cash) PaymentMode paymentMode,
    String? note,
    DateTime? dueDate,
    DateTime? reminderDate,
    String? attachmentPath,
    String? createdBy,
    String? updatedBy,
    String? reversalOfTransactionId,
    @Default(false) bool isReversal,
    @Default(SyncStatus.pending) SyncStatus syncStatus,
    DateTime? deletedAt,
  }) = _LedgerTransaction;

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) =>
      _$LedgerTransactionFromJson(json);
}

@freezed
abstract class BusinessProfile with _$BusinessProfile {
  const factory BusinessProfile({
    required String id,
    required String name,
    String? ownerName,
    String? phone,
    String? upiId,
    String? gstin,
    String? address,
  }) = _BusinessProfile;

  factory BusinessProfile.fromJson(Map<String, dynamic> json) =>
      _$BusinessProfileFromJson(json);
}

@freezed
abstract class BusinessSummary with _$BusinessSummary {
  const factory BusinessSummary({
    required int totalReceivablePaise,
    required int totalPayablePaise,
    required int todayCollectionPaise,
    required int todayCreditGivenPaise,
    required int overdueParties,
    required int activeParties,
    required int lowStockItems,
    required int pendingSyncItems,
  }) = _BusinessSummary;

  factory BusinessSummary.fromJson(Map<String, dynamic> json) =>
      _$BusinessSummaryFromJson(json);
}

@freezed
abstract class ReminderTemplate with _$ReminderTemplate {
  const factory ReminderTemplate({
    required String id,
    required String name,
    required String languageCode,
    required String body,
    @Default(false) bool firmTone,
  }) = _ReminderTemplate;

  factory ReminderTemplate.fromJson(Map<String, dynamic> json) =>
      _$ReminderTemplateFromJson(json);
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String businessId,
    required String name,
    required String unit,
    @Default(0) int salePricePaise,
    @Default(0) int purchasePricePaise,
    @Default(0) int stockOnHand,
    @Default(0) int lowStockThreshold,
    String? sku,
    String? barcode,
    String? category,
    String? imageUrl,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String businessId,
    required String bookId,
    required String invoiceNumber,
    required String partyId,
    required DateTime date,
    DateTime? dueDate,
    @Default(0) int subtotalPaise,
    @Default(0) int gstPaise,
    @Default(0) int totalPaise,
    @Default(0) int paidPaise,
    @Default(InvoiceStatus.draft) InvoiceStatus status,
    String? notes,
    String? terms,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
