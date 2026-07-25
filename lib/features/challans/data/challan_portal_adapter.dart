import 'package:flutter/foundation.dart';

import '../domain/challan_models.dart';

/// What the user asked the portal for. Carries no credentials of any kind.
@immutable
class ChallanCaptureRequest {
  const ChallanCaptureRequest({
    required this.challanNumber,
    required this.financialYear,
  });

  /// Exactly what the user typed (tidied, not stripped).
  final String challanNumber;
  final String financialYear;

  String get normalizedChallanNumber =>
      ChallanText.normalizeToken(challanNumber);
}

/// Pulls the currently rendered result markup from a live portal session.
///
/// Returning `null` means the page could not be read (not loaded yet, or the
/// platform has no WebView). Implementations must never return credentials,
/// cookies or CAPTCHA state — only the rendered result markup.
typedef PortalHtmlReader = Future<String?> Function();

/// Strategy for turning a government portal session into challan data.
///
/// Keeping this an interface is what lets an authorized government API replace
/// the WebView capture later without touching the UI, the repository or the
/// database contract.
abstract interface class ChallanVerificationAdapter {
  /// Stable identifier persisted to `epass_challans.source_portal`.
  String get sourcePortal;

  /// The portal entry point shown to the user and stored on the record.
  String get portalUrl;

  /// Attempts one capture. Implementations return a failed
  /// [ChallanCaptureResult] rather than throwing, so the UI can render an
  /// actionable message for every outcome.
  Future<ChallanCaptureResult> capture({
    required ChallanCaptureRequest request,
    required PortalHtmlReader readHtml,
  });
}

/// Which platforms can host the in-app government portal WebView.
///
/// `webview_flutter` is implemented by `webview_flutter_android` (Android) and
/// `webview_flutter_wkwebview` (iOS + macOS). Windows and Linux have no
/// implementation, so those builds fall back to the external browser and a
/// clearly-labelled manual entry. The dependency itself is pure Dart on
/// unsupported platforms, so desktop builds still compile.
class ChallanPortalSupport {
  const ChallanPortalSupport._();

  static bool supportsInAppWebView([TargetPlatform? platform]) {
    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => false,
    };
  }

  /// Explanation shown on platforms without an in-app WebView.
  static const unsupportedPlatformNotice =
      'In-app portal viewing is not available on this desktop platform. '
      'Open the portal in your browser to verify the challan, then add the '
      'details as a manual entry — it will be saved as "Manual (unverified)".';
}

/// Host allow-list for the in-app WebView.
class PortalNavigationPolicy {
  const PortalNavigationPolicy({required this.allowedHost});

  final String allowedHost;

  /// True when [url] may load inside the WebView.
  ///
  /// Only HTTPS on the government host (or a subdomain of it) is allowed.
  /// Everything else — including plain HTTP and unrelated sites — is handed to
  /// the OS browser instead.
  bool allowsInApp(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (uri.scheme.toLowerCase() != 'https') return false;
    final host = uri.host.toLowerCase();
    final allowed = allowedHost.toLowerCase();
    return host == allowed || host.endsWith('.$allowed');
  }
}
