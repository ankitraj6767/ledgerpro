/// Machine-readable reasons a challan flow can fail.
///
/// Every case maps to an actionable, user-safe message. Raw HTML, stack traces
/// and portal internals are never surfaced through these.
enum ChallanErrorKind {
  noInternet,
  portalUnavailable,
  portalTimeout,
  pageNotLoaded,
  captchaNotCompleted,
  challanNotFound,
  challanMismatch,
  missingRequiredField,
  portalLayoutChanged,
  duplicateChallan,
  permissionDenied,
  projectMissing,
  supabaseTimeout,
  sessionExpired,
  saveFailedAfterCapture,
  platformUnsupported,
  unknown,
}

/// Base failure for the challan module.
///
/// [message] is always safe to render directly to an end user.
class ChallanException implements Exception {
  const ChallanException(this.kind, this.message, {this.recoveryHint});

  final ChallanErrorKind kind;
  final String message;

  /// Optional extra sentence telling the user what to do next.
  final String? recoveryHint;

  @override
  String toString() => 'ChallanException(${kind.name}): $message';

  // --- Named constructors keep messages consistent across the whole feature ---

  static const noInternet = ChallanException(
    ChallanErrorKind.noInternet,
    'No internet connection.',
    recoveryHint:
        'Government portal verification needs internet. Reconnect and try again.',
  );

  static const portalUnavailable = ChallanException(
    ChallanErrorKind.portalUnavailable,
    'The Bihar Government portal could not be reached.',
    recoveryHint: 'The portal may be down for maintenance. Try again shortly.',
  );

  static const portalTimeout = ChallanException(
    ChallanErrorKind.portalTimeout,
    'The government portal took too long to respond.',
    recoveryHint: 'Refresh the portal and search again.',
  );

  static const pageNotLoaded = ChallanException(
    ChallanErrorKind.pageNotLoaded,
    'The portal page has not finished loading.',
    recoveryHint: 'Wait for the page to load fully, then capture again.',
  );

  static const captchaNotCompleted = ChallanException(
    ChallanErrorKind.captchaNotCompleted,
    'No challan result found on the page yet.',
    recoveryHint:
        'Complete the CAPTCHA on the portal and press its Search button, then capture.',
  );

  static const challanNotFound = ChallanException(
    ChallanErrorKind.challanNotFound,
    'The portal reported no record for this challan number.',
    recoveryHint: 'Check the challan number and financial year, then retry.',
  );

  static const portalLayoutChanged = ChallanException(
    ChallanErrorKind.portalLayoutChanged,
    'Portal layout changed, so the challan details could not be read reliably.',
    recoveryHint:
        'Nothing was saved. Report this so the parser can be updated, or add the entry manually.',
  );

  static const platformUnsupported = ChallanException(
    ChallanErrorKind.platformUnsupported,
    'In-app portal viewing is not available on this platform.',
    recoveryHint:
        'Open the portal in your browser, then add the challan as a manual entry.',
  );

  static const sessionExpired = ChallanException(
    ChallanErrorKind.sessionExpired,
    'Your LedgerPro session expired.',
    recoveryHint: 'Sign in again to save this challan.',
  );

  static const permissionDenied = ChallanException(
    ChallanErrorKind.permissionDenied,
    'You do not have permission to add challans.',
    recoveryHint: 'Ask an owner or manager to grant access.',
  );

  static const projectMissing = ChallanException(
    ChallanErrorKind.projectMissing,
    'The selected project no longer exists.',
    recoveryHint: 'Pick a different project and capture again.',
  );

  static const supabaseTimeout = ChallanException(
    ChallanErrorKind.supabaseTimeout,
    'Saving timed out.',
    recoveryHint: 'Check your connection and retry — nothing was saved.',
  );

  static ChallanException challanMismatch({
    required String expected,
    required String returned,
  }) => ChallanException(
    ChallanErrorKind.challanMismatch,
    'The portal returned challan $returned, but you entered $expected.',
    recoveryHint:
        'Search the portal for the correct challan number before capturing.',
  );

  static ChallanException missingRequiredField(
    List<String> fields,
  ) => ChallanException(
    ChallanErrorKind.missingRequiredField,
    fields.length == 1
        ? 'The portal result is missing ${fields.first}.'
        : 'The portal result is missing: ${fields.join(', ')}.',
    recoveryHint:
        'Nothing was saved. Search the portal again, or add the entry manually.',
  );

  static ChallanException duplicate(String challanNumber) => ChallanException(
    ChallanErrorKind.duplicateChallan,
    'This challan is already saved',
    recoveryHint: 'Challan $challanNumber already exists in this organization.',
  );

  static ChallanException saveFailedAfterCapture(String reason) =>
      ChallanException(
        ChallanErrorKind.saveFailedAfterCapture,
        'The challan was captured but could not be saved. $reason',
        recoveryHint:
            'Your captured details are still on screen — press Save to retry.',
      );

  static const unknown = ChallanException(
    ChallanErrorKind.unknown,
    'Something went wrong while processing the challan.',
    recoveryHint: 'Please try again.',
  );
}
