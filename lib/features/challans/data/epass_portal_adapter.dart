import '../domain/challan_exceptions.dart';
import '../domain/challan_models.dart';
import '../domain/challan_portal.dart';
import '../domain/challan_status.dart';
import 'challan_dom_parser.dart';
import 'challan_portal_adapter.dart';

/// Captures challans from a state e-Pass portal through a human-driven WebView.
///
/// One implementation serves every supported portal ([ChallanPortal]); all
/// portal-specific knowledge lives in the portal enum and the parser's per-portal
/// id map. Currently: Bihar "Khanan Soft" and the Jharkhand Minerals Portal.
///
/// CAPTCHA and login are completed by the person using the app. This adapter
/// only ever *reads* what the portal already rendered after the user pressed the
/// portal's own Search button — it never solves, submits or forwards any
/// human-verification challenge.
class EPassWebViewAdapter implements ChallanVerificationAdapter {
  const EPassWebViewAdapter(this.portal, {this.parserOverride});

  final ChallanPortal portal;

  /// Injectable so tests can exercise the adapter with a stub parser.
  final ChallanDomParser? parserOverride;

  /// Parser bound to this portal's control-id map.
  ChallanDomParser get parser =>
      parserOverride ?? ChallanDomParser(portal: portal);

  PortalNavigationPolicy get navigationPolicy =>
      PortalNavigationPolicy(allowedHost: portal.host);

  String get host => portal.host;

  @override
  String get sourcePortal => portal.dbValue;

  @override
  String get portalUrl => portal.url;

  @override
  Future<ChallanCaptureResult> capture({
    required ChallanCaptureRequest request,
    required PortalHtmlReader readHtml,
  }) async {
    final String? rawHtml;
    try {
      rawHtml = await readHtml();
    } catch (_) {
      // Deliberately does not include the underlying error: it can embed page
      // content, and raw portal HTML must never reach a log or the UI.
      return _failure(ChallanException.pageNotLoaded);
    }

    if (rawHtml == null || rawHtml.trim().length < 32) {
      return _failure(ChallanException.pageNotLoaded);
    }

    return evaluate(request: request, rawHtml: rawHtml);
  }

  /// Pure evaluation of already-fetched markup.
  ///
  /// Exposed separately so the whole verification pipeline can be tested with
  /// static HTML fixtures — no live government portal, no WebView.
  ChallanCaptureResult evaluate({
    required ChallanCaptureRequest request,
    required String rawHtml,
    DateTime? capturedAt,
  }) {
    final domParser = parser;

    if (domParser.reportsNoRecord(rawHtml)) {
      return _failure(ChallanException.challanNotFound);
    }

    final payload = domParser.parse(rawHtml, capturedAt: capturedAt);

    // Nothing recognizable yet: on both portals every detail field reads "NA"
    // until a search succeeds, so this means the user has not searched (or has
    // not completed the portal's CAPTCHA, where one is shown).
    if (payload.isEmpty) {
      return _failure(
        domParser.hasResultSection(rawHtml)
            ? ChallanException.portalLayoutChanged
            : ChallanException.captchaNotCompleted,
      );
    }

    // A partially-readable result means the markup moved. Never save partial
    // data as a portal capture.
    final missing = payload.missingMandatoryFields;
    if (missing.isNotEmpty) {
      if (payload.dataFieldCount == 0) {
        return _failure(ChallanException.captchaNotCompleted);
      }
      // Losing the challan number, or most of the mandatory set, is structural.
      if (payload.challanNumber == null || missing.length >= 3) {
        return _failure(ChallanException.portalLayoutChanged, payload: payload);
      }
      // A single stray field is reported precisely so the user knows what broke.
      return _failure(
        ChallanException.missingRequiredField(missing),
        payload: payload,
      );
    }

    // The returned challan must be the one that was asked for.
    final returned = ChallanText.normalizeToken(payload.challanNumber ?? '');
    if (returned != request.normalizedChallanNumber) {
      return _failure(
        ChallanException.challanMismatch(
          expected: request.challanNumber.trim(),
          returned: payload.challanNumber!.trim(),
        ),
        payload: payload,
      );
    }

    // Financial year is only checked when the page actually shows a date.
    if (!_financialYearConsistent(payload, request.financialYear)) {
      return _failure(
        const ChallanException(
          ChallanErrorKind.challanMismatch,
          'The portal result does not belong to the selected financial year.',
          recoveryHint:
              'Choose the financial year that matches this challan and capture again.',
        ),
        payload: payload,
      );
    }

    return ChallanCaptureResult(
      success: true,
      payload: payload,
      portalUrl: portal.url,
      status: ChallanVerificationStatus.portalCaptured,
      method: ChallanVerificationMethod.webviewHumanVerification,
    );
  }

  /// Checks the challan date against the Indian financial year window.
  ///
  /// Returns true when the date is absent or the year string is unparseable —
  /// a missing cross-check must not block an otherwise valid capture. Note the
  /// financial year is LedgerPro's own bookkeeping field: the Jharkhand portal
  /// has no financial-year selector at all.
  bool _financialYearConsistent(
    CapturedPortalPayload payload,
    String financialYear,
  ) {
    final date = payload.challanDate;
    if (date == null) return true;
    final match = RegExp(
      r'(\d{4})\s*[-/]\s*(\d{2,4})',
    ).firstMatch(financialYear);
    if (match == null) return true;
    final startYear = int.parse(match.group(1)!);

    // Compare in IST, matching how the portal presents the date.
    final ist = date.toUtc().add(const Duration(hours: 5, minutes: 30));
    final start = DateTime.utc(startYear, 4, 1);
    final end = DateTime.utc(startYear + 1, 4, 1);
    final dayOnly = DateTime.utc(ist.year, ist.month, ist.day);
    return !dayOnly.isBefore(start) && dayOnly.isBefore(end);
  }

  ChallanCaptureResult _failure(
    ChallanException error, {
    CapturedPortalPayload? payload,
  }) {
    return ChallanCaptureResult(
      success: false,
      payload: payload,
      errorKind: error.kind.name,
      errorMessage: [
        error.message,
        if (error.recoveryHint != null) error.recoveryHint,
      ].join(' '),
      portalUrl: portal.url,
      status: ChallanVerificationStatus.manualUnverified,
      method: ChallanVerificationMethod.webviewHumanVerification,
    );
  }
}

/// Placeholder for a future authorized government API integration.
///
/// When a state publishes an authenticated e-Pass verification API, implement it
/// as another [ChallanVerificationAdapter] returning
/// [ChallanVerificationStatus.officialApiVerified] and point
/// `challanVerificationAdapterProvider` at it for that portal. Only such an
/// adapter may ever produce that status; the database additionally rejects
/// `official_api` writes until that work lands.
///
/// Nothing else in the feature needs to change: the flow controller, repository,
/// RPC contract and UI all speak [ChallanCaptureResult].
// ignore: unused_element
const _futureOfficialApiAdapterNote = 'EPassOfficialApiAdapter';
