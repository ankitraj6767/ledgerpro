import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/infra_repository.dart';
import '../data/challan_portal_adapter.dart';
import '../domain/challan_exceptions.dart';
import '../domain/challan_models.dart';
import '../domain/challan_portal.dart';
import '../domain/challan_status.dart';
import '../domain/material_type.dart';
import 'challan_flow_state.dart';
import 'challan_providers.dart';

/// Orchestrates the five-step challan journey.
///
/// All step transitions, validation, capture evaluation, duplicate pre-checking
/// and saving live here so the widgets stay presentational.
class ChallanFlowController extends Notifier<ChallanFlowState> {
  @override
  ChallanFlowState build() {
    return ChallanFlowState(financialYear: FinancialYear.current());
  }

  // ---------------------------------------------------------------------------
  // Step 1 — selection
  // ---------------------------------------------------------------------------

  /// Switches the state government portal.
  ///
  /// Any capture already collected belongs to the previous portal, so it is
  /// discarded rather than being saved against the wrong `source_portal`.
  void selectPortal(ChallanPortal portal) {
    if (state.portal == portal) return;
    state = state.copyWith(
      portal: portal,
      captureResult: null,
      duplicateOf: null,
      savedChallan: null,
      materialMismatchAcknowledged: false,
      manualFallback: false,
      errorMessage: null,
      step: ChallanFlowStep.selection,
    );
  }

  void selectProject(String? projectId) {
    state = state.copyWith(projectId: projectId, errorMessage: null);
  }

  void selectMaterial(ChallanMaterialType? material) {
    state = state.copyWith(
      materialType: material,
      // A new material choice invalidates a previous mismatch acknowledgement.
      materialMismatchAcknowledged: false,
      errorMessage: null,
    );
  }

  void selectFinancialYear(String financialYear) {
    state = state.copyWith(financialYear: financialYear, errorMessage: null);
  }

  /// Stores the tidied challan number. The value entered into the government
  /// portal is this same string — normalization is only ever a comparison key.
  void setChallanNumber(String raw) {
    state = state.copyWith(
      challanNumber: ChallanText.tidyChallanNumber(raw),
      errorMessage: null,
      duplicateOf: null,
    );
  }

  void setOffline(bool offline) {
    if (state.isOffline == offline) return;
    state = state.copyWith(isOffline: offline);
  }

  /// Validates step 1 and moves to the portal step.
  ///
  /// Runs a duplicate pre-check first so the user is not sent through a CAPTCHA
  /// for a challan that is already saved. Returns false when blocked.
  Future<bool> continueFromSelection() async {
    if (!state.canContinueFromSelection) {
      state = state.copyWith(
        errorMessage: state.projectId == null || state.projectId!.isEmpty
            ? 'Select a project to continue.'
            : 'Enter a valid challan number to continue.',
      );
      return false;
    }

    final duplicate = await _findDuplicate();
    if (duplicate != null) {
      state = state.copyWith(
        duplicateOf: duplicate,
        isCheckingDuplicate: false,
      );
      return false;
    }

    state = state.copyWith(
      step: ChallanFlowStep.portal,
      errorMessage: null,
      duplicateOf: null,
    );
    return true;
  }

  /// Best-effort duplicate pre-check. Network failures never block the flow:
  /// the server-side unique index is the authority.
  Future<EPassChallan?> _findDuplicate() async {
    if (state.isOffline) return null;
    state = state.copyWith(isCheckingDuplicate: true);
    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      final existing = await ref
          .read(challanRepositoryProvider)
          .challanExists(
            organizationId: org.id,
            financialYear: state.financialYear,
            challanNumber: state.challanNumber,
            sourcePortal: state.portal.dbValue,
          );
      return existing;
    } catch (_) {
      return null;
    } finally {
      if (state.isCheckingDuplicate) {
        state = state.copyWith(isCheckingDuplicate: false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Step 2/3 — portal + capture
  // ---------------------------------------------------------------------------

  /// Evaluates what the portal currently shows.
  ///
  /// [readHtml] is supplied by the portal screen and returns the rendered result
  /// markup from the live WebView session. This method never touches CAPTCHA,
  /// credentials or the portal's submit button.
  Future<bool> captureFromPortal(PortalHtmlReader readHtml) async {
    if (state.isCapturing) return false;
    state = state.copyWith(
      isCapturing: true,
      errorMessage: null,
      step: ChallanFlowStep.verification,
    );

    final adapter = ref.read(challanVerificationAdapterProvider(state.portal));
    final result = await adapter.capture(
      request: ChallanCaptureRequest(
        challanNumber: state.challanNumber,
        financialYear: state.financialYear,
      ),
      readHtml: readHtml,
    );

    if (!result.success) {
      state = state.copyWith(
        isCapturing: false,
        captureResult: result,
        errorMessage: result.errorMessage,
        step: ChallanFlowStep.verification,
      );
      return false;
    }

    state = state.copyWith(
      isCapturing: false,
      captureResult: result,
      errorMessage: null,
      step: ChallanFlowStep.preview,
      materialMismatchAcknowledged: false,
      manualFallback: false,
    );

    // Re-check duplicates now that the portal confirmed the challan number.
    final duplicate = await _findDuplicate();
    if (duplicate != null) {
      state = state.copyWith(duplicateOf: duplicate);
    }
    return true;
  }

  void backToPortal() {
    state = state.copyWith(step: ChallanFlowStep.portal, errorMessage: null);
  }

  void backToSelection() {
    state = state.copyWith(
      step: ChallanFlowStep.selection,
      errorMessage: null,
      captureResult: null,
      duplicateOf: null,
    );
  }

  /// Clears the capture so the user can search the portal again.
  void retryCapture() {
    state = state.copyWith(
      step: ChallanFlowStep.portal,
      captureResult: null,
      errorMessage: null,
      materialMismatchAcknowledged: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Step 4 — preview
  // ---------------------------------------------------------------------------

  /// Confirms saving even though the selected material and the portal's mineral
  /// disagree. Both values are still stored; nothing is overwritten.
  void acknowledgeMaterialMismatch() {
    state = state.copyWith(materialMismatchAcknowledged: true);
  }

  /// Switches to a manual entry.
  ///
  /// Portal-captured fields are read-only by design: if the user needs to
  /// correct anything, the record must be downgraded to `manual_unverified`
  /// while the originally-extracted payload is still preserved in
  /// `portal_payload`.
  void switchToManualEntry() {
    state = state.copyWith(manualFallback: true, errorMessage: null);
  }

  // ---------------------------------------------------------------------------
  // Step 5 — save
  // ---------------------------------------------------------------------------

  /// Saves the challan through the atomic RPC. Returns the saved row, or null
  /// when the save was rejected (the reason is in `state.errorMessage` or
  /// `state.duplicateOf`).
  Future<EPassChallan?> save() async {
    if (state.isSaving) return null;
    if (!state.hasCapture && !state.manualFallback) {
      state = state.copyWith(
        errorMessage: 'Capture the challan details before saving.',
      );
      return null;
    }
    if (state.needsMaterialConfirmation) {
      state = state.copyWith(
        errorMessage:
            'Confirm the material difference before saving this challan.',
      );
      return null;
    }

    final adapter = ref.read(challanVerificationAdapterProvider(state.portal));
    final draft = state.toDraft(portalUrl: adapter.portalUrl);
    if (draft == null) {
      state = state.copyWith(errorMessage: ChallanException.unknown.message);
      return null;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      step: ChallanFlowStep.save,
    );

    final repository = ref.read(challanRepositoryProvider);
    try {
      final saved = state.manualFallback
          ? await repository.createManualChallan(draft)
          : await repository.createCapturedChallan(draft);

      state = state.copyWith(
        isSaving: false,
        savedChallan: saved,
        errorMessage: null,
      );
      // Realtime also invalidates this, but refreshing immediately keeps the
      // list correct even when Realtime is unavailable.
      ref.invalidate(challansProvider);
      return saved;
    } on ChallanException catch (error) {
      await _handleSaveFailure(error, draft);
      return null;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        step: ChallanFlowStep.preview,
        errorMessage: ChallanException.saveFailedAfterCapture(
          ChallanException.unknown.message,
        ).message,
      );
      return null;
    }
  }

  Future<void> _handleSaveFailure(
    ChallanException error,
    EPassChallanDraft draft,
  ) async {
    if (error.kind == ChallanErrorKind.duplicateChallan) {
      final repository = ref.read(challanRepositoryProvider);
      unawaited(
        repository.recordDuplicateBlocked(
          projectId: draft.projectId,
          challanNumber: draft.challanNumber,
        ),
      );
      EPassChallan? existing;
      try {
        final org = await ref.read(infraWorkspaceProvider.future);
        existing = await repository.challanExists(
          organizationId: org.id,
          financialYear: draft.financialYear,
          challanNumber: draft.challanNumber,
          sourcePortal: draft.sourcePortal,
        );
      } catch (_) {
        existing = null;
      }
      state = state.copyWith(
        isSaving: false,
        step: ChallanFlowStep.preview,
        duplicateOf: existing,
        errorMessage: 'This challan is already saved',
      );
      return;
    }

    state = state.copyWith(
      isSaving: false,
      step: ChallanFlowStep.preview,
      errorMessage: [
        error.message,
        if (error.recoveryHint != null) error.recoveryHint,
      ].join(' '),
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void dismissError() => state = state.copyWith(errorMessage: null);

  void dismissDuplicate() => state = state.copyWith(duplicateOf: null);

  /// Resets to step 1, keeping the project, material and financial year so the
  /// user can add several challans in a row without re-picking them.
  void startAnother() {
    state = ChallanFlowState(
      portal: state.portal,
      projectId: state.projectId,
      materialType: state.materialType,
      financialYear: state.financialYear.isEmpty
          ? FinancialYear.current()
          : state.financialYear,
      isOffline: state.isOffline,
    );
  }

  /// Full reset.
  void reset() {
    state = ChallanFlowState(
      portal: state.portal,
      financialYear: FinancialYear.current(),
      isOffline: state.isOffline,
    );
  }

  /// Marks the manual-entry payload for the offline / unsupported-platform path.
  ///
  /// Never produces `portal_captured`: a manual draft is always
  /// `manual_unverified`.
  void setManualPayload(CapturedPortalPayload payload) {
    state = state.copyWith(
      manualFallback: true,
      captureResult: ChallanCaptureResult(
        success: true,
        payload: payload,
        status: ChallanVerificationStatus.manualUnverified,
        method: ChallanVerificationMethod.manualEntry,
      ),
      step: ChallanFlowStep.preview,
      errorMessage: null,
    );
  }
}
