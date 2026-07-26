import 'challan_portal.dart';

/// How a challan record's data was obtained.
///
/// The status deliberately never collapses to a generic "verified": the UI must
/// always tell the user *how* the data was verified, because data captured from
/// a user-driven WebView session is not the same as data signed off by an
/// authorized government API.
enum ChallanVerificationStatus {
  /// Extracted from the government portal's rendered result page after the user
  /// completed CAPTCHA / login themselves.
  portalCaptured,

  /// Typed or corrected by a human. Carries no portal guarantee.
  manualUnverified,

  /// Reserved for a future authorized government API integration. The current
  /// client never writes this value.
  officialApiVerified,

  /// Portal explicitly reported the challan as invalid.
  invalid,

  /// Challan validity window has passed.
  expired,
}

/// The mechanism used to obtain the data.
enum ChallanVerificationMethod {
  /// In-app WebView where the human completed the portal's verification.
  webviewHumanVerification,

  /// Manual data entry by the user.
  manualEntry,

  /// Reserved for a future authorized government API.
  officialApi,
}

extension ChallanVerificationStatusMapping on ChallanVerificationStatus {
  static ChallanVerificationStatus fromDb(String? value) => switch (value) {
    'portal_captured' => ChallanVerificationStatus.portalCaptured,
    'official_api_verified' => ChallanVerificationStatus.officialApiVerified,
    'invalid' => ChallanVerificationStatus.invalid,
    'expired' => ChallanVerificationStatus.expired,
    _ => ChallanVerificationStatus.manualUnverified,
  };

  String get dbValue => switch (this) {
    ChallanVerificationStatus.portalCaptured => 'portal_captured',
    ChallanVerificationStatus.manualUnverified => 'manual_unverified',
    ChallanVerificationStatus.officialApiVerified => 'official_api_verified',
    ChallanVerificationStatus.invalid => 'invalid',
    ChallanVerificationStatus.expired => 'expired',
  };

  /// User-facing label. Portal captures are explicitly described as *captured
  /// from* the portal — never as officially verified.
  String get label => switch (this) {
    ChallanVerificationStatus.portalCaptured =>
      'Captured from Bihar Government Portal',
    ChallanVerificationStatus.manualUnverified => 'Manual (unverified)',
    ChallanVerificationStatus.officialApiVerified => 'Official API Verified',
    ChallanVerificationStatus.invalid => 'Invalid',
    ChallanVerificationStatus.expired => 'Expired',
  };

  /// Portal-aware label, e.g. "Captured from Jharkhand Government Portal".
  ///
  /// Prefer this over [label] wherever the record's portal is known, so a
  /// Jharkhand capture is never described as a Bihar one.
  String labelFor(ChallanPortal portal) => switch (this) {
    ChallanVerificationStatus.portalCaptured => portal.capturedStatusLabel,
    _ => label,
  };

  /// Compact label for list badges where horizontal space is tight.
  String get shortLabel => switch (this) {
    ChallanVerificationStatus.portalCaptured => 'Portal captured',
    ChallanVerificationStatus.manualUnverified => 'Manual',
    ChallanVerificationStatus.officialApiVerified => 'Official API',
    ChallanVerificationStatus.invalid => 'Invalid',
    ChallanVerificationStatus.expired => 'Expired',
  };
}

extension ChallanVerificationMethodMapping on ChallanVerificationMethod {
  static ChallanVerificationMethod fromDb(String? value) => switch (value) {
    'webview_human_verification' =>
      ChallanVerificationMethod.webviewHumanVerification,
    'official_api' => ChallanVerificationMethod.officialApi,
    _ => ChallanVerificationMethod.manualEntry,
  };

  String get dbValue => switch (this) {
    ChallanVerificationMethod.webviewHumanVerification =>
      'webview_human_verification',
    ChallanVerificationMethod.manualEntry => 'manual_entry',
    ChallanVerificationMethod.officialApi => 'official_api',
  };

  String get label => switch (this) {
    ChallanVerificationMethod.webviewHumanVerification =>
      'Portal (human verified)',
    ChallanVerificationMethod.manualEntry => 'Manual entry',
    ChallanVerificationMethod.officialApi => 'Official API',
  };
}
