import 'package:freezed_annotation/freezed_annotation.dart';

import 'challan_status.dart';
import 'material_type.dart';

part 'challan_models.freezed.dart';
part 'challan_models.g.dart';

/// Text normalization shared by the parser, the flow controller and the
/// duplicate pre-check. The server re-normalizes independently; these helpers
/// exist so the client shows the *same* answer the server will reach.
class ChallanText {
  const ChallanText._();

  /// Trims and upper-cases Latin letters while preserving everything the user
  /// actually typed (including Devanagari and separators).
  static String tidyChallanNumber(String raw) => raw.trim().toUpperCase();

  /// Comparison key: uppercase letters and digits only.
  static String normalizeToken(String raw) =>
      raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  /// Collapses runs of whitespace and returns null for blank values.
  static String? cleanOrNull(String? raw) {
    if (raw == null) return null;
    final collapsed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed.isEmpty ? null : collapsed;
  }
}

/// Everything read off the government result page for one challan.
///
/// Fields are nullable because the parser must be able to report a partial
/// capture; mandatory-field validation happens in [CapturedPortalPayload.
/// missingMandatoryFields] rather than by throwing during parsing.
@freezed
abstract class CapturedPortalPayload with _$CapturedPortalPayload {
  const CapturedPortalPayload._();

  const factory CapturedPortalPayload({
    String? challanNumber,
    String? uidNumber,
    DateTime? challanDate,
    DateTime? validUntil,
    String? consignorName,
    String? consigneeName,
    String? generatedFrom,
    String? sourceLocation,
    String? destination,
    String? vehicleType,
    String? vehicleNumber,
    String? mineralName,

    /// Parsed for validation and display only.
    double? quantity,

    /// The exact decimal text as printed by the portal. This is what gets sent
    /// to Postgres `numeric(14,3)` so no binary-float rounding is introduced on
    /// the write path.
    String? quantityText,

    /// Null when the portal did not print a unit. Never assume MT here — the
    /// assumption (and the fact that it *is* an assumption) is applied at save
    /// time instead.
    String? quantityUnit,
    int? royaltyAmountPaise,

    /// Raw label/value pairs exactly as normalized off the page, including
    /// fields this app version does not model yet. Persisted to
    /// `portal_payload` so a future release can backfill without re-capturing.
    @Default(<String, String>{}) Map<String, String> rawFields,

    /// SHA-256 of the normalized payload. Lets support confirm two devices read
    /// the same page without ever storing the page itself.
    String? responseHash,
    DateTime? capturedAt,
  }) = _CapturedPortalPayload;

  factory CapturedPortalPayload.fromJson(Map<String, dynamic> json) =>
      _$CapturedPortalPayloadFromJson(json);

  static const mandatoryFieldLabels = <String>[
    'challan number',
    'challan date',
    'vehicle number',
    'mineral name',
    'quantity',
  ];

  /// Human-readable names of the mandatory fields that are absent.
  List<String> get missingMandatoryFields => [
    if (ChallanText.cleanOrNull(challanNumber) == null) 'challan number',
    if (challanDate == null) 'challan date',
    if (ChallanText.cleanOrNull(vehicleNumber) == null) 'vehicle number',
    if (ChallanText.cleanOrNull(mineralName) == null) 'mineral name',
    if (quantity == null || quantity! <= 0) 'quantity',
  ];

  bool get hasAllMandatoryFields => missingMandatoryFields.isEmpty;

  /// True when the page produced no recognizable challan fields at all, which
  /// means the user has not searched yet (or the layout changed entirely).
  bool get isEmpty => rawFields.isEmpty && challanNumber == null;
}

/// Outcome of one capture attempt against a portal adapter.
@freezed
abstract class ChallanCaptureResult with _$ChallanCaptureResult {
  const ChallanCaptureResult._();

  const factory ChallanCaptureResult({
    required bool success,
    CapturedPortalPayload? payload,

    /// Populated when [success] is false. Uses the module's error taxonomy.
    String? errorKind,
    String? errorMessage,
    String? portalUrl,
    required ChallanVerificationStatus status,
    required ChallanVerificationMethod method,
  }) = _ChallanCaptureResult;

  factory ChallanCaptureResult.fromJson(Map<String, dynamic> json) =>
      _$ChallanCaptureResultFromJson(json);
}

/// The draft assembled across the five steps and handed to the repository.
@freezed
abstract class EPassChallanDraft with _$EPassChallanDraft {
  const EPassChallanDraft._();

  const factory EPassChallanDraft({
    required String projectId,
    required String financialYear,

    /// Exactly what the user typed, tidied but not stripped.
    required String challanNumber,
    ChallanMaterialType? selectedMaterialType,
    required CapturedPortalPayload payload,
    @Default(ChallanVerificationStatus.portalCaptured)
    ChallanVerificationStatus verificationStatus,
    @Default(ChallanVerificationMethod.webviewHumanVerification)
    ChallanVerificationMethod verificationMethod,
    String? portalUrl,
    @Default('bihar_khanan_soft') String sourcePortal,
  }) = _EPassChallanDraft;

  factory EPassChallanDraft.fromJson(Map<String, dynamic> json) =>
      _$EPassChallanDraftFromJson(json);

  String get normalizedChallanNumber =>
      ChallanText.normalizeToken(challanNumber);

  /// True when the user's material choice disagrees with the portal's mineral.
  /// Both values are always persisted; the app never silently overwrites one.
  bool get hasMaterialMismatch {
    final selected = selectedMaterialType;
    if (selected == null) return false;
    return !selected.matchesPortalMineral(payload.mineralName);
  }
}

/// A saved challan row.
@freezed
abstract class EPassChallan with _$EPassChallan {
  const EPassChallan._();

  const factory EPassChallan({
    required String id,
    required String organizationId,
    required String projectId,
    @Default('bihar_khanan_soft') String sourcePortal,
    String? portalUrl,
    required String financialYear,
    required String challanNumber,
    required String normalizedChallanNumber,
    String? uidNumber,
    DateTime? challanDate,
    DateTime? validUntil,
    ChallanMaterialType? selectedMaterialType,
    required String portalMineralName,
    @Default(0) double quantity,
    @Default('MT') String quantityUnit,
    String? vehicleType,
    required String vehicleNumber,
    required String normalizedVehicleNumber,
    String? consignorName,
    String? consigneeName,
    String? sourceLocation,
    String? destination,
    String? generatedFrom,
    int? royaltyAmountPaise,
    @Default(<String, dynamic>{}) Map<String, dynamic> portalPayload,
    String? portalResponseHash,
    @Default(ChallanVerificationStatus.manualUnverified)
    ChallanVerificationStatus verificationStatus,
    @Default(ChallanVerificationMethod.manualEntry)
    ChallanVerificationMethod verificationMethod,
    DateTime? capturedAt,
    DateTime? verifiedAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,

    /// Joined for display only; not a column on `epass_challans`.
    String? projectName,
  }) = _EPassChallan;

  factory EPassChallan.fromJson(Map<String, dynamic> json) =>
      _$EPassChallanFromJson(json);

  bool get isPortalCaptured =>
      verificationStatus == ChallanVerificationStatus.portalCaptured;

  /// Quantity rendered without trailing zeros, e.g. `12.5 MT`, `30 MT`.
  String get quantityLabel {
    final text = quantity
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$text $quantityUnit';
  }

  bool get hasMaterialMismatch {
    final selected = selectedMaterialType;
    if (selected == null) return false;
    return !selected.matchesPortalMineral(portalMineralName);
  }
}

/// Filters applied to the recent-challan list.
@freezed
abstract class ChallanFilter with _$ChallanFilter {
  const ChallanFilter._();

  const factory ChallanFilter({
    @Default('') String query,
    String? projectId,
    ChallanMaterialType? materialType,
    ChallanVerificationStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _ChallanFilter;

  factory ChallanFilter.fromJson(Map<String, dynamic> json) =>
      _$ChallanFilterFromJson(json);

  bool get isActive =>
      query.trim().isNotEmpty ||
      projectId != null ||
      materialType != null ||
      status != null ||
      fromDate != null ||
      toDate != null;

  int get activeCount => [
    query.trim().isNotEmpty,
    projectId != null,
    materialType != null,
    status != null,
    fromDate != null || toDate != null,
  ].where((active) => active).length;
}
