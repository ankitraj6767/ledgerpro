import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_dom_parser.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/data/epass_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_exceptions.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';

import 'fixtures/portal_result_fixtures.dart';

/// Jharkhand Minerals Portal support, verified against markup captured from the
/// live page. The Jharkhand page differs from Bihar's in four ways that matter:
/// it shows a CAPTCHA, it has no financial-year selector, it uses a Bootstrap
/// grid instead of tables, and it renames several controls.
void main() {
  final jharkhand = EPassWebViewAdapter(ChallanPortal.jharkhand);
  final bihar = EPassWebViewAdapter(ChallanPortal.bihar);

  const request = ChallanCaptureRequest(
    challanNumber: 'JH/2026/0012345',
    financialYear: '2026-2027',
  );

  group('portal descriptor', () {
    test('exposes the correct URL and host', () {
      expect(
        ChallanPortal.jharkhand.url,
        'https://mineralsportal.jharkhand.gov.in/portal/epass/ViewPassDetailsNew.aspx',
      );
      expect(ChallanPortal.jharkhand.host, 'mineralsportal.jharkhand.gov.in');
      expect(
        ChallanPortal.bihar.url,
        'https://khanansoft.bihar.gov.in/portal/ePass/ViewPassDetailsNew.aspx',
      );
      expect(ChallanPortal.bihar.host, 'khanansoft.bihar.gov.in');
    });

    test('records the real per-portal differences', () {
      // Jharkhand shows a CAPTCHA; Bihar's page currently does not.
      expect(ChallanPortal.jharkhand.requiresCaptcha, isTrue);
      expect(ChallanPortal.bihar.requiresCaptcha, isFalse);
      // Jharkhand has no financial-year dropdown to prefill.
      expect(ChallanPortal.jharkhand.hasFinancialYearSelector, isFalse);
      expect(ChallanPortal.bihar.hasFinancialYearSelector, isTrue);
    });

    test('source_portal values are distinct and stable', () {
      expect(ChallanPortal.bihar.dbValue, 'bihar_khanan_soft');
      expect(ChallanPortal.jharkhand.dbValue, 'jharkhand_minerals_portal');

      for (final portal in ChallanPortal.values) {
        expect(ChallanPortalMapping.fromDb(portal.dbValue), portal);
      }
      // Rows saved before multi-portal support resolve to Bihar.
      expect(ChallanPortalMapping.fromDb(null), ChallanPortal.bihar);
      expect(
        ChallanPortalMapping.fromDb('something_else'),
        ChallanPortal.bihar,
      );
    });

    test('capture wording names the right state', () {
      expect(
        ChallanPortal.bihar.capturedStatusLabel,
        'Captured from Bihar Government Portal',
      );
      expect(
        ChallanPortal.jharkhand.capturedStatusLabel,
        'Captured from Jharkhand Government Portal',
      );
      expect(
        ChallanVerificationStatus.portalCaptured.labelFor(
          ChallanPortal.jharkhand,
        ),
        'Captured from Jharkhand Government Portal',
      );
      // Non-capture statuses are portal-independent.
      expect(
        ChallanVerificationStatus.manualUnverified.labelFor(
          ChallanPortal.jharkhand,
        ),
        'Manual (unverified)',
      );
    });
  });

  group('un-searched Jharkhand page', () {
    test('every "NA" value is treated as absent', () {
      const parser = ChallanDomParser(portal: ChallanPortal.jharkhand);
      final payload = parser.parse(PortalFixtures.jharkhandUnsearched);

      expect(payload.dataFieldCount, 0);
      expect(payload.isEmpty, isTrue);
      expect(payload.challanNumber, isNull);
      expect(payload.quantity, isNull);
    });

    test('tells the user to search rather than reporting missing fields', () {
      final result = jharkhand.evaluate(
        request: request,
        rawHtml: PortalFixtures.jharkhandUnsearched,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.captchaNotCompleted.name);
      expect(result.errorMessage, isNot(contains('missing')));
    });

    test('the CAPTCHA controls are never read as data', () {
      const parser = ChallanDomParser(portal: ChallanPortal.jharkhand);
      final payload = parser.parse(PortalFixtures.jharkhandUnsearched);

      final values = payload.rawFields.values.join(' ').toLowerCase();
      expect(values.contains('captcha'), isFalse);
      expect(values.contains('rnxq89'), isFalse);
    });
  });

  group('successful Jharkhand capture', () {
    test('reads the Bootstrap-grid layout correctly', () {
      const parser = ChallanDomParser(portal: ChallanPortal.jharkhand);
      final payload = parser.parse(PortalFixtures.jharkhandFilled);

      expect(payload.challanNumber, 'JH/2026/0012345');
      // "Permit No." maps onto the uid_number column.
      expect(payload.uidNumber, 'PMT-JH-778');
      expect(payload.vehicleNumber, 'JH05BC7788');
      expect(payload.mineralName, 'Stone Chips');
      expect(payload.quantity, 14.5);
      expect(payload.quantityText, '14.500');
      expect(payload.quantityUnit, 'MT');
      expect(payload.sourceLocation, 'Ranchi Quarry 5');
      expect(payload.destination, 'Bokaro Site');
      expect(payload.generatedFrom, 'Lessee');
      expect(payload.validUntil, isNotNull);
      expect(payload.hasAllMandatoryFields, isTrue);
    });

    test('the Consigner quirk is filed as consignor, not consignee', () {
      const parser = ChallanDomParser(portal: ChallanPortal.jharkhand);
      final payload = parser.parse(PortalFixtures.jharkhandFilled);

      // The portal renders "Consigner Name" into a span named
      // lblconsigneename. It must land on consignorName.
      expect(payload.consignorName, 'JHARKHAND STONE WORKS');
      expect(payload.consigneeName, isNull);
    });

    test('the adapter accepts it as a portal capture', () {
      final result = jharkhand.evaluate(
        request: request,
        rawHtml: PortalFixtures.jharkhandFilled,
      );

      expect(result.success, isTrue);
      expect(result.status, ChallanVerificationStatus.portalCaptured);
      expect(result.portalUrl, ChallanPortal.jharkhand.url);
    });

    test('a mismatched pass number is still rejected', () {
      final result = jharkhand.evaluate(
        request: const ChallanCaptureRequest(
          challanNumber: 'JH/2026/9999999',
          financialYear: '2026-2027',
        ),
        rawHtml: PortalFixtures.jharkhandFilled,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.challanMismatch.name);
    });

    test('the slash-formatted pass number normalizes for duplicate checks', () {
      final result = jharkhand.evaluate(
        request: const ChallanCaptureRequest(
          // Same pass, typed without separators.
          challanNumber: 'jh20260012345',
          financialYear: '2026-2027',
        ),
        rawHtml: PortalFixtures.jharkhandFilled,
      );

      expect(result.success, isTrue);
    });
  });

  group('per-portal id maps do not leak into each other', () {
    test('Bihar markup still parses correctly with the Bihar profile', () {
      final result = bihar.evaluate(
        request: const ChallanCaptureRequest(
          challanNumber: '2413812606031238531',
          financialYear: '2026-2027',
        ),
        rawHtml: PortalFixtures.realPortalFilled,
      );

      expect(result.success, isTrue);
      // Bihar genuinely has both parties.
      expect(result.payload!.consignorName, 'GANGA BALU SUPPLIERS');
      expect(result.payload!.consigneeName, 'NAVDREAM INFRA');
    });

    test('Bihar keeps its own unit and vehicle-type controls', () {
      const parser = ChallanDomParser(portal: ChallanPortal.bihar);
      final payload = parser.parse(PortalFixtures.realPortalFilled);

      expect(payload.quantityUnit, 'MT');
      expect(payload.vehicleType, 'Truck');
    });

    test('the parser defaults to the Bihar profile', () {
      const parser = ChallanDomParser();
      expect(parser.portal, ChallanPortal.bihar);
    });
  });

  group('navigation policy is per portal', () {
    test('each adapter only allows its own host', () {
      expect(
        jharkhand.navigationPolicy.allowsInApp(ChallanPortal.jharkhand.url),
        isTrue,
      );
      // Cross-portal navigation is not allowed inside a given session.
      expect(
        jharkhand.navigationPolicy.allowsInApp(ChallanPortal.bihar.url),
        isFalse,
      );
      expect(
        bihar.navigationPolicy.allowsInApp(ChallanPortal.jharkhand.url),
        isFalse,
      );
    });

    test('Jharkhand blocks http and look-alike domains', () {
      final policy = jharkhand.navigationPolicy;

      expect(
        policy.allowsInApp(
          'https://sub.mineralsportal.jharkhand.gov.in/portal/x',
        ),
        isTrue,
      );
      expect(
        policy.allowsInApp('http://mineralsportal.jharkhand.gov.in/portal'),
        isFalse,
      );
      expect(
        policy.allowsInApp(
          'https://mineralsportal.jharkhand.gov.in.evil.com/x',
        ),
        isFalse,
      );
      expect(policy.allowsInApp('https://jharkhand.gov.in'), isFalse);
    });
  });
}
