import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_dom_parser.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/data/epass_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';

import 'fixtures/portal_result_fixtures.dart';

/// MP e-Khanij (`Verify_eTP.aspx`) support.
///
/// MP differs from both existing portals in three ways that this suite pins
/// down: the number field only exists after a search-mode radio is chosen, the
/// input is `txtetp` (sharing no token with Bihar's `txtChallanNo`), and the
/// result arrives as a horizontal GridView instead of label/value rows.
void main() {
  final mp = EPassWebViewAdapter(ChallanPortal.madhyaPradesh);
  const parser = ChallanDomParser(portal: ChallanPortal.madhyaPradesh);

  const request = ChallanCaptureRequest(
    challanNumber: '1234567890',
    financialYear: '2026-2027',
  );

  group('portal contract', () {
    test('exposes the live URL and host', () {
      expect(
        ChallanPortal.madhyaPradesh.url,
        'https://ekhanij.mp.gov.in/appPrevious/Verify_eTP.aspx',
      );
      expect(ChallanPortal.madhyaPradesh.host, 'ekhanij.mp.gov.in');
    });

    test('records the real per-portal differences', () {
      // The page shows a CAPTCHA and has no financial-year dropdown.
      expect(ChallanPortal.madhyaPradesh.requiresCaptcha, isTrue);
      expect(ChallanPortal.madhyaPradesh.hasFinancialYearSelector, isFalse);
      // Its submit button says Verify, not Search.
      expect(ChallanPortal.madhyaPradesh.searchButtonLabel, 'Verify');
      // Nothing is pre-rendered as "NA" the way Bihar's page is.
      expect(ChallanPortal.madhyaPradesh.showsPlaceholdersBeforeSearch, isFalse);
      expect(ChallanPortal.bihar.showsPlaceholdersBeforeSearch, isTrue);
    });

    test('declares the search mode that must be selected first', () {
      final mode = ChallanPortal.madhyaPradesh.searchMode!;
      expect(mode.idToken, 'rbsearchtype');
      expect(mode.value, '1');

      // The portals that show their number field immediately declare none.
      expect(ChallanPortal.bihar.searchMode, isNull);
      expect(ChallanPortal.jharkhand.searchMode, isNull);
    });

    test('source_portal stays unique and stable across every portal', () {
      expect(ChallanPortal.madhyaPradesh.dbValue, 'mp_ekhanij_etp');
      expect(
        ChallanPortal.values.map((portal) => portal.dbValue).toSet(),
        hasLength(ChallanPortal.values.length),
      );
      expect(
        ChallanPortalMapping.fromDb('mp_ekhanij_etp'),
        ChallanPortal.madhyaPradesh,
      );
      // Pre-existing rows and unknown values still resolve to Bihar.
      expect(ChallanPortalMapping.fromDb(null), ChallanPortal.bihar);
      expect(ChallanPortal.fallback, ChallanPortal.bihar);
    });

    test('capture wording names Madhya Pradesh', () {
      expect(
        ChallanPortal.madhyaPradesh.capturedStatusLabel,
        'Captured from Madhya Pradesh Government Portal',
      );
      expect(
        ChallanVerificationStatus.portalCaptured.labelFor(
          ChallanPortal.madhyaPradesh,
        ),
        contains('Madhya Pradesh'),
      );
    });

    test('navigation stays on the MP host only', () {
      const policy = PortalNavigationPolicy(allowedHost: 'ekhanij.mp.gov.in');

      expect(policy.allowsInApp(ChallanPortal.madhyaPradesh.url), isTrue);
      expect(
        policy.allowsInApp('https://sub.ekhanij.mp.gov.in/appPrevious/x.aspx'),
        isTrue,
      );
      // Plain HTTP, other MP departments and look-alike hosts are all rejected.
      expect(
        policy.allowsInApp('http://ekhanij.mp.gov.in/appPrevious/Verify_eTP.aspx'),
        isFalse,
      );
      expect(policy.allowsInApp('https://mp.gov.in/'), isFalse);
      expect(policy.allowsInApp('https://ekhanij.mp.gov.in.evil.test/'), isFalse);
      expect(policy.allowsInApp(ChallanPortal.bihar.url), isFalse);
    });
  });

  group('form contract (verified against the live page)', () {
    test('the prefill token matches the real eTP input and nothing else', () {
      final tokens = ChallanPortal.madhyaPradesh.challanInputTokens;
      expect(tokens, contains('etp'));

      // txtetp is matched...
      expect(
        tokens.any((token) => 'ctl00\$contentplaceholder1\$txtetp'.contains(token)),
        isTrue,
      );
      // ...while the CAPTCHA box is not, on top of the script's own CAPTCHA
      // guard.
      expect(
        tokens.any(
          (token) => 'ctl00\$contentplaceholder1\$txtcaptcha'.contains(token),
        ),
        isFalse,
      );
    });

    test('Bihar and Jharkhand tokens never match the MP input', () {
      for (final token in ChallanPortal.bihar.challanInputTokens) {
        expect('ctl00\$contentplaceholder1\$txtetp'.contains(token), isFalse);
      }
    });

    test('the real form markup still carries every control we depend on', () {
      const markup = PortalFixtures.mpEtpFormMarkup;

      expect(markup, contains('rbsearchtype'));
      expect(markup, contains('value="1"'));
      expect(markup, contains('txtetp'));
      expect(markup, contains('txtCaptcha'));
      expect(markup, contains('value="Verify"'));
      expect(markup, contains('pnlgridvehicle'));
    });

    test('the bare form is never mistaken for a result', () {
      expect(parser.hasResultSection(PortalFixtures.mpEtpFormMarkup), isFalse);
      expect(parser.reportsNoRecord(PortalFixtures.mpEtpFormMarkup), isFalse);
      expect(parser.parse(PortalFixtures.mpEtpFormMarkup).isEmpty, isTrue);
    });

    test('capturing before searching asks the user to search, not to retry a '
        'broken layout', () async {
      final result = await mp.capture(
        request: request,
        readHtml: () async => PortalFixtures.mpEtpFormMarkup,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, 'captchaNotCompleted');
      expect(result.status, ChallanVerificationStatus.manualUnverified);
    });
  });

  group('grid result', () {
    test('reads the eTP out of a header-row / data-row grid', () {
      final payload = parser.parse(PortalFixtures.mpEtpGridFilled);

      expect(payload.challanNumber, '1234567890');
      expect(payload.vehicleNumber, 'MP09GH4455');
      expect(payload.mineralName, 'Sand');
      expect(payload.quantity, 18.5);
      expect(payload.quantityText, '18.500');
      expect(payload.quantityUnit, 'MT');
      expect(payload.consignorName, 'NARMADA SAND MINES');
      expect(payload.sourceLocation, 'Hoshangabad');
      expect(payload.destination, 'Bhopal');
      expect(payload.challanDate, isNotNull);
      expect(payload.validUntil, isNotNull);
    });

    test('the eTP date is read as IST wall clock', () {
      final payload = parser.parse(PortalFixtures.mpEtpGridFilled);
      final ist = payload.challanDate!.toUtc().add(
        const Duration(hours: 5, minutes: 30),
      );

      expect(ist.year, 2026);
      expect(ist.month, 7);
      expect(ist.day, 22);
      expect(ist.hour, 10);
      expect(ist.minute, 5);
    });

    test('captures successfully end to end', () async {
      final result = await mp.capture(
        request: request,
        readHtml: () async => PortalFixtures.mpEtpGridFilled,
      );

      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.status, ChallanVerificationStatus.portalCaptured);
      expect(result.method, ChallanVerificationMethod.webviewHumanVerification);
      expect(result.portalUrl, ChallanPortal.madhyaPradesh.url);
    });

    test('a grid for a different eTP is refused, never saved', () async {
      final result = await mp.capture(
        request: const ChallanCaptureRequest(
          challanNumber: '9999999999',
          financialYear: '2026-2027',
        ),
        readHtml: () async => PortalFixtures.mpEtpGridFilled,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, 'challanMismatch');
    });

    test('an unknown eTP is reported as not found', () async {
      expect(parser.reportsNoRecord(PortalFixtures.mpEtpNoRecord), isTrue);

      final result = await mp.capture(
        request: request,
        readHtml: () async => PortalFixtures.mpEtpNoRecord,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, 'challanNotFound');
    });
  });

  group('the grid layer cannot disturb the existing portals', () {
    test('Bihar still parses its label/value rows exactly as before', () {
      const bihar = ChallanDomParser();
      final payload = bihar.parse(PortalFixtures.realPortalFilled);

      expect(payload.challanNumber, '2413812606031238531');
      expect(payload.uidNumber, 'UID2026001');
      expect(payload.vehicleNumber, 'BR06GA1234');
      expect(payload.vehicleType, 'Truck');
      expect(payload.mineralName, 'sand');
      expect(payload.quantity, 2);
      expect(payload.quantityUnit, 'MT');
      expect(payload.consignorName, 'GANGA BALU SUPPLIERS');
      expect(payload.consigneeName, 'NAVDREAM INFRA');
      expect(payload.sourceLocation, 'Madhubani Ghat 2');
      expect(payload.destination, 'Madhubani Bus Stand');
    });

    test('Bihar\'s un-searched page still yields nothing', () {
      const bihar = ChallanDomParser();
      expect(bihar.parse(PortalFixtures.realPortalUnsearched).dataFieldCount, 0);
      expect(bihar.reportsNoRecord(PortalFixtures.realPortalNoRecord), isTrue);
    });

    test('Jharkhand\'s Bootstrap grid is untouched', () {
      const jharkhand = ChallanDomParser(portal: ChallanPortal.jharkhand);
      final payload = jharkhand.parse(PortalFixtures.jharkhandFilled);

      expect(payload.challanNumber, 'JH/2026/0012345');
      expect(payload.consignorName, 'JHARKHAND STONE WORKS');
      expect(payload.vehicleNumber, 'JH05BC7788');
      expect(payload.quantity, 14.5);
    });

    test('a two-column label/value table never activates the grid layer', () {
      // Three label rows in a row-per-field table: the header guard needs three
      // exact labels in ONE row, so this must not be read column-wise.
      const markup = '''
<html><body><table>
<tr><td>Challan No.</td><td>:</td><td>111</td></tr>
<tr><td>Vehicle No.</td><td>:</td><td>BR01AA1111</td></tr>
<tr><td>Mineral Name</td><td>:</td><td>sand</td></tr>
<tr><td>Quantity</td><td>:</td><td>5.000 MT</td></tr>
</table></body></html>
''';
      const bihar = ChallanDomParser();
      final payload = bihar.parse(markup);

      expect(payload.challanNumber, '111');
      expect(payload.vehicleNumber, 'BR01AA1111');
      expect(payload.mineralName, 'sand');
      expect(payload.quantity, 5);
    });
  });
}
