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
/// `webview_flutter` is implemented by `webview_flutter_android` (Android),
/// `webview_flutter_wkwebview` (iOS + macOS) and `webview_win_floating`
/// (Windows, backed by the Microsoft Edge WebView2 runtime). Because every one
/// of those is a `webview_flutter` platform implementation, the portal screen,
/// the JavaScript extraction and the capture pipeline are identical on all four
/// — Windows captures a challan exactly the way Android does.
///
/// Linux still has no implementation here, so those builds fall back to the
/// external browser plus a clearly-labelled manual entry. The dependency is pure
/// Dart on unsupported platforms, so every build still compiles.
class ChallanPortalSupport {
  const ChallanPortalSupport._();

  static bool supportsInAppWebView([TargetPlatform? platform]) {
    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.linux || TargetPlatform.fuchsia => false,
    };
  }

  /// True where the WebView is a *native floating window* layered on top of the
  /// Flutter surface rather than a composited platform view.
  ///
  /// This is how WebView2 is hosted on Windows, and it has two consequences the
  /// portal screen has to respect:
  ///   * Flutter cannot paint anything above the WebView's rectangle, so
  ///     progress bars and menus must live outside it.
  ///   * A JavaScript result crosses a COM boundary as a JSON string, so large
  ///     page markup is read in slices instead of one hop.
  static bool usesFloatingWebView([TargetPlatform? platform]) {
    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.windows => true,
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => false,
    };
  }

  /// Explanation shown on platforms without an in-app WebView.
  static const unsupportedPlatformNotice =
      'In-app portal viewing is not available on this desktop platform. '
      'Open the portal in your browser to verify the challan, then add the '
      'details as a manual entry — it will be saved as "Manual (unverified)".';

  /// Shown when the platform has a WebView implementation but the OS-level
  /// engine could not start. On Windows that is almost always a missing
  /// Microsoft Edge WebView2 runtime.
  static const webViewEngineErrorNotice =
      'The in-app browser engine could not start on this computer. On Windows '
      'LedgerPro needs the Microsoft Edge WebView2 Runtime, which ships with '
      'Windows 11 and can be installed free on Windows 10. Install it and '
      'reopen the portal, or verify this challan in your browser and add it as '
      'a manual entry.';
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
