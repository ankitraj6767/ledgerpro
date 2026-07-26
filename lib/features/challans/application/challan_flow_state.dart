import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/challan_models.dart';
import '../domain/challan_portal.dart';
import '../domain/challan_status.dart';
import '../domain/material_type.dart';

part 'challan_flow_state.freezed.dart';

/// The five steps of the challan entry journey.
enum ChallanFlowStep {
  /// 1. Project, material, financial year and challan number.
  selection,

  /// 2. Government portal opens; the user completes CAPTCHA / login.
  portal,

  /// 3. Capture and validate the portal's rendered result.
  verification,

  /// 4. Read-only preview of the captured fields.
  preview,

  /// 5. Save through the atomic Supabase RPC.
  save;

  String get title => switch (this) {
    ChallanFlowStep.selection => 'Project & Material',
    ChallanFlowStep.portal => 'Government Portal',
    ChallanFlowStep.verification => 'Challan Verification',
    ChallanFlowStep.preview => 'Auto Fetch & Preview',
    ChallanFlowStep.save => 'Save Entry',
  };

  /// Compact label for the mobile step indicator.
  String get shortTitle => switch (this) {
    ChallanFlowStep.selection => 'Select',
    ChallanFlowStep.portal => 'Portal',
    ChallanFlowStep.verification => 'Verify',
    ChallanFlowStep.preview => 'Preview',
    ChallanFlowStep.save => 'Save',
  };

  int get stepNumber => index + 1;
}

@freezed
abstract class ChallanFlowState with _$ChallanFlowState {
  const ChallanFlowState._();

  const factory ChallanFlowState({
    @Default(ChallanFlowStep.selection) ChallanFlowStep step,

    /// Which state government portal this entry is being captured from.
    @Default(ChallanPortal.bihar) ChallanPortal portal,
    String? projectId,
    ChallanMaterialType? materialType,
    @Default('') String financialYear,

    /// Exactly what the user typed, tidied but not stripped.
    @Default('') String challanNumber,

    /// Result of the most recent capture attempt.
    ChallanCaptureResult? captureResult,

    /// Set when the same challan already exists in this organization.
    EPassChallan? duplicateOf,

    /// The saved row once step 5 succeeds.
    EPassChallan? savedChallan,
    @Default(false) bool isCapturing,
    @Default(false) bool isSaving,
    @Default(false) bool isCheckingDuplicate,

    /// User explicitly confirmed saving despite a material mismatch.
    @Default(false) bool materialMismatchAcknowledged,

    /// User chose to save corrected data as a manual entry instead.
    @Default(false) bool manualFallback,

    /// Actionable, user-safe error for the current step.
    String? errorMessage,
    @Default(false) bool isOffline,
  }) = _ChallanFlowState;

  CapturedPortalPayload? get payload => captureResult?.payload;

  bool get hasCapture => captureResult?.success == true && payload != null;

  /// Step 1 is complete only when a project is chosen and a challan number that
  /// normalizes to something meaningful has been entered.
  bool get canContinueFromSelection =>
      projectId != null &&
      projectId!.isNotEmpty &&
      financialYear.trim().isNotEmpty &&
      ChallanText.normalizeToken(challanNumber).isNotEmpty;

  String get normalizedChallanNumber =>
      ChallanText.normalizeToken(challanNumber);

  /// True when the user's material choice disagrees with the portal's mineral.
  bool get hasMaterialMismatch {
    final selected = materialType;
    final mineral = payload?.mineralName;
    if (selected == null || mineral == null) return false;
    return !selected.matchesPortalMineral(mineral);
  }

  /// Blocks the save button until an unacknowledged mismatch is confirmed.
  bool get needsMaterialConfirmation =>
      hasMaterialMismatch && !materialMismatchAcknowledged;

  bool get isBusy => isCapturing || isSaving || isCheckingDuplicate;

  /// Builds the draft handed to the repository. Null until a capture exists.
  EPassChallanDraft? toDraft({String? portalUrl}) {
    final captured = payload;
    if (captured == null || projectId == null) return null;
    return EPassChallanDraft(
      projectId: projectId!,
      financialYear: financialYear.trim(),
      challanNumber: challanNumber.trim(),
      selectedMaterialType: materialType,
      payload: captured,
      verificationStatus:
          captureResult?.status ?? ChallanVerificationStatus.manualUnverified,
      verificationMethod:
          captureResult?.method ?? ChallanVerificationMethod.manualEntry,
      portalUrl: portalUrl ?? portal.url,
      sourcePortal: portal.dbValue,
    );
  }
}
