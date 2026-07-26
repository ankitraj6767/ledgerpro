import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/epass_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_exceptions.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';

import 'fixtures/portal_result_fixtures.dart';

void main() {
  final adapter = EPassWebViewAdapter(ChallanPortal.bihar);

  ChallanCaptureRequest request({
    String challan = 'BR2026001234',
    String year = '2026-2027',
  }) => ChallanCaptureRequest(challanNumber: challan, financialYear: year);

  group('successful capture', () {
    test('marks a complete matching result as portal captured', () {
      final result = adapter.evaluate(
        request: request(),
        rawHtml: PortalFixtures.aspNetLabelIds,
      );

      expect(result.success, isTrue);
      expect(result.status, ChallanVerificationStatus.portalCaptured);
      expect(result.method, ChallanVerificationMethod.webviewHumanVerification);
      expect(result.payload!.challanNumber, 'BR2026001234');
      expect(result.errorMessage, isNull);
      // Never claims an official API verification.
      expect(
        result.status,
        isNot(ChallanVerificationStatus.officialApiVerified),
      );
    });

    test('accepts a differently formatted challan number', () {
      final result = adapter.evaluate(
        request: request(challan: 'br-2026-001234'),
        rawHtml: PortalFixtures.aspNetLabelIds,
      );

      expect(result.success, isTrue);
    });

    test('portal_captured label names the portal, not "verified"', () {
      expect(
        ChallanVerificationStatus.portalCaptured.label,
        'Captured from Bihar Government Portal',
      );
    });
  });

  group('rejected captures', () {
    test('un-searched page tells the user to press Search', () {
      final result = adapter.evaluate(
        request: request(),
        rawHtml: PortalFixtures.searchFormOnly,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.captchaNotCompleted.name);
      // This portal page has no CAPTCHA, so the guidance must lead with Search
      // and only mention verification conditionally.
      expect(result.errorMessage, contains('Search'));
      expect(result.errorMessage, contains('verification'));
    });

    test('no-record page reports challan not found', () {
      final result = adapter.evaluate(
        request: request(),
        rawHtml: PortalFixtures.noRecord,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.challanNotFound.name);
    });

    test('changed layout is reported, never saved', () {
      final result = adapter.evaluate(
        request: request(),
        rawHtml: PortalFixtures.layoutChangedPartial,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.portalLayoutChanged.name);
      expect(result.errorMessage, contains('Portal layout changed'));
      expect(result.errorMessage, contains('Nothing was saved'));
    });

    test('a different challan number is rejected as a mismatch', () {
      final result = adapter.evaluate(
        request: request(challan: 'BR2026009999'),
        rawHtml: PortalFixtures.mismatchedChallan,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.challanMismatch.name);
      expect(result.errorMessage, contains('BR2026000001'));
      expect(result.errorMessage, contains('BR2026009999'));
    });

    test('a result outside the selected financial year is rejected', () {
      // The fixture's challan date is 12/05/2026, which is FY 2026-2027.
      final result = adapter.evaluate(
        request: request(year: '2024-2025'),
        rawHtml: PortalFixtures.aspNetLabelIds,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.challanMismatch.name);
      expect(result.errorMessage, contains('financial year'));
    });

    test('a January date belongs to the previous April financial year', () {
      final html = PortalFixtures.aspNetLabelIds
          .replaceAll('12/05/2026 14:30', '15/01/2027 10:00')
          .replaceAll('13/05/2026 14:30', '16/01/2027 10:00');

      expect(
        adapter.evaluate(request: request(), rawHtml: html).success,
        isTrue,
        reason: 'Jan 2027 falls inside FY 2026-2027',
      );
      expect(
        adapter
            .evaluate(
              request: request(year: '2027-2028'),
              rawHtml: html,
            )
            .success,
        isFalse,
      );
    });

    test('a failed capture never reports portal_captured', () {
      final result = adapter.evaluate(
        request: request(),
        rawHtml: PortalFixtures.noRecord,
      );

      expect(result.status, ChallanVerificationStatus.manualUnverified);
    });
  });

  group('capture() plumbing', () {
    test('an unreadable page reports page-not-loaded', () async {
      final result = await adapter.capture(
        request: request(),
        readHtml: () async => null,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.pageNotLoaded.name);
    });

    test('a reader that throws never leaks the underlying error', () async {
      final result = await adapter.capture(
        request: request(),
        readHtml: () async => throw StateError('sensitive <html> content'),
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.pageNotLoaded.name);
      expect(result.errorMessage, isNot(contains('sensitive')));
      expect(result.errorMessage, isNot(contains('html')));
    });

    test('reads through the injected reader end to end', () async {
      final result = await adapter.capture(
        request: request(),
        readHtml: () async => PortalFixtures.aspNetLabelIds,
      );

      expect(result.success, isTrue);
      expect(result.payload!.vehicleNumber, 'BR 01 GH 4567');
    });
  });

  group('navigation policy', () {
    final policy = adapter.navigationPolicy;

    test('allows only https on the government host', () {
      expect(policy.allowsInApp(ChallanPortal.bihar.url), isTrue);
      expect(
        policy.allowsInApp('https://khanansoft.bihar.gov.in/portal/x.aspx'),
        isTrue,
      );
      expect(
        policy.allowsInApp('https://sub.khanansoft.bihar.gov.in/a'),
        isTrue,
      );
    });

    test('blocks plain http, other hosts and lookalike domains', () {
      expect(
        policy.allowsInApp('http://khanansoft.bihar.gov.in/portal'),
        isFalse,
      );
      expect(policy.allowsInApp('https://example.com'), isFalse);
      expect(policy.allowsInApp('https://bihar.gov.in'), isFalse);
      // Suffix-only lookalike must not pass.
      expect(
        policy.allowsInApp('https://khanansoft.bihar.gov.in.evil.com/x'),
        isFalse,
      );
      expect(policy.allowsInApp('javascript:alert(1)'), isFalse);
      expect(policy.allowsInApp('file:///etc/passwd'), isFalse);
      expect(policy.allowsInApp('not a url at all'), isFalse);
    });
  });
}
