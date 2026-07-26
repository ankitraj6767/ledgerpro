import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/bihar_epass_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_dom_parser.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_portal_adapter.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_exceptions.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';

import 'fixtures/portal_result_fixtures.dart';

/// Regression tests built from markup captured off the live Bihar e-Pass page.
///
/// The live page renders every detail span as the literal `NA` until a search
/// succeeds. Treating `NA` as a value made an un-searched page look like a
/// partial result and produced a misleading
/// "missing: challan date, quantity" error.
void main() {
  const parser = ChallanDomParser();
  const adapter = BiharEPassWebViewAdapter();

  const request = ChallanCaptureRequest(
    challanNumber: '2413812606031238531',
    financialYear: '2026-2027',
  );

  group('un-searched real page (all fields are "NA")', () {
    test('extracts no fields at all', () {
      final payload = parser.parse(PortalFixtures.realPortalUnsearched);

      expect(payload.dataFieldCount, 0);
      expect(payload.isEmpty, isTrue);
      // Crucially, "NA" must not survive as a value.
      expect(payload.challanNumber, isNull);
      expect(payload.vehicleNumber, isNull);
      expect(payload.mineralName, isNull);
      expect(payload.uidNumber, isNull);
      expect(payload.consignorName, isNull);
      expect(payload.destination, isNull);
    });

    test('is not mistaken for a result section', () {
      expect(
        parser.hasResultSection(PortalFixtures.realPortalUnsearched),
        isFalse,
      );
    });

    test('tells the user to press Search, not that fields are missing', () {
      final result = adapter.evaluate(
        request: request,
        rawHtml: PortalFixtures.realPortalUnsearched,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.captchaNotCompleted.name);
      expect(result.errorMessage, contains('Search'));
      // The old, misleading wording must not come back.
      expect(result.errorMessage, isNot(contains('missing')));
      expect(result.errorMessage, isNot(contains('challan date, quantity')));
    });
  });

  group('successful real capture', () {
    test('reads every field from the real markup', () {
      final payload = parser.parse(PortalFixtures.realPortalFilled);

      expect(payload.challanNumber, '2413812606031238531');
      expect(payload.uidNumber, 'UID2026001');
      expect(
        payload.challanDate,
        DateTime.utc(
          2026,
          7,
          26,
          0,
          54,
        ).subtract(const Duration(hours: 5, minutes: 30)),
      );
      expect(payload.validUntil, isNotNull);
      expect(payload.vehicleNumber, 'BR06GA1234');
      expect(payload.vehicleType, 'Truck');
      expect(payload.mineralName, 'sand');
      expect(payload.quantity, 2);
      expect(payload.quantityText, '2.000');
      // Read from the portal's separate lblunit control.
      expect(payload.quantityUnit, 'MT');
      // "Consigner Name" (portal spelling) via lblconsignername.
      expect(payload.consignorName, 'GANGA BALU SUPPLIERS');
      expect(payload.consigneeName, 'NAVDREAM INFRA');
      expect(payload.sourceLocation, 'Madhubani Ghat 2');
      expect(payload.destination, 'Madhubani Bus Stand');
      // "Challan Generate from" is rendered by lbluser.
      expect(payload.generatedFrom, 'Mine Owner');
      expect(payload.hasAllMandatoryFields, isTrue);
      expect(payload.missingMandatoryFields, isEmpty);
    });

    test('the adapter accepts it as a portal capture', () {
      final result = adapter.evaluate(
        request: request,
        rawHtml: PortalFixtures.realPortalFilled,
      );

      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.status, ChallanVerificationStatus.portalCaptured);
      expect(result.method, ChallanVerificationMethod.webviewHumanVerification);
    });

    test('the 12:54 AM timestamp is not shifted to midday', () {
      final payload = parser.parse(PortalFixtures.realPortalFilled);
      final ist = payload.challanDate!.toUtc().add(
        const Duration(hours: 5, minutes: 30),
      );

      expect(ist.hour, 0);
      expect(ist.minute, 54);
      expect(ist.day, 26);
      expect(ist.month, 7);
    });

    test('a real capture is rejected when the number does not match', () {
      final result = adapter.evaluate(
        request: const ChallanCaptureRequest(
          challanNumber: '9999999999999999999',
          financialYear: '2026-2027',
        ),
        rawHtml: PortalFixtures.realPortalFilled,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.challanMismatch.name);
    });
  });

  group('real page reporting no record', () {
    test('detects the portal lblresult message', () {
      expect(parser.reportsNoRecord(PortalFixtures.realPortalNoRecord), isTrue);
      expect(
        parser.portalMessage(PortalFixtures.realPortalNoRecord),
        'No Record Found',
      );
    });

    test('surfaces challan-not-found rather than a missing-field error', () {
      final result = adapter.evaluate(
        request: request,
        rawHtml: PortalFixtures.realPortalNoRecord,
      );

      expect(result.success, isFalse);
      expect(result.errorKind, ChallanErrorKind.challanNotFound.name);
    });

    test('a filled result is never treated as no-record', () {
      expect(parser.reportsNoRecord(PortalFixtures.realPortalFilled), isFalse);
    });
  });

  group('placeholder handling', () {
    test('common portal placeholders map to null', () {
      for (final placeholder in [
        'NA',
        'na',
        'N/A',
        'n.a.',
        'NIL',
        '-',
        '--',
        'null',
        'None',
      ]) {
        final html =
            '''
<html><body><table>
<tr><td>Challan No.</td><td>:</td><td>$placeholder</td></tr>
<tr><td>Vehicle No.</td><td>:</td><td>$placeholder</td></tr>
<tr><td>Mineral Name</td><td>:</td><td>$placeholder</td></tr>
</table></body></html>
''';
        final payload = parser.parse(html);
        expect(
          payload.challanNumber,
          isNull,
          reason: '"$placeholder" must not be treated as a challan number',
        );
        expect(payload.vehicleNumber, isNull, reason: placeholder);
        expect(payload.mineralName, isNull, reason: placeholder);
      }
    });

    test('a value that merely contains "na" is preserved', () {
      // e.g. a real consignor name starting with those letters
      const html = '''
<html><body><table>
<tr><td>Consigner Name</td><td>:</td><td>NANDLAL TRADERS</td></tr>
<tr><td>Vehicle No.</td><td>:</td><td>BR06NA1234</td></tr>
</table></body></html>
''';
      final payload = parser.parse(html);

      expect(payload.consignorName, 'NANDLAL TRADERS');
      expect(payload.vehicleNumber, 'BR06NA1234');
    });
  });

  group('textual month dates', () {
    test('parses the month-name formats ASP.NET may emit', () {
      final expected = DateTime.utc(
        2026,
        7,
        26,
      ).subtract(const Duration(hours: 5, minutes: 30));

      expect(ChallanDomParser.parsePortalDate('26-Jul-2026'), expected);
      expect(ChallanDomParser.parsePortalDate('26 Jul 2026'), expected);
      expect(ChallanDomParser.parsePortalDate('26/July/2026'), expected);
      expect(ChallanDomParser.parsePortalDate('Jul 26, 2026'), expected);
      expect(
        ChallanDomParser.parsePortalDate('26-Jul-2026 02:30 PM'),
        DateTime.utc(
          2026,
          7,
          26,
          14,
          30,
        ).subtract(const Duration(hours: 5, minutes: 30)),
      );
    });

    test('still rejects placeholders and nonsense', () {
      expect(ChallanDomParser.parsePortalDate('NA'), isNull);
      expect(ChallanDomParser.parsePortalDate('--'), isNull);
      expect(ChallanDomParser.parsePortalDate('26-Xyz-2026'), isNull);
    });

    test('numeric formats are unaffected', () {
      expect(
        ChallanDomParser.parsePortalDate('26/07/2026'),
        DateTime.utc(
          2026,
          7,
          26,
        ).subtract(const Duration(hours: 5, minutes: 30)),
      );
    });
  });

  group('portal form contract', () {
    test('prefill targets exist on the real page markup', () {
      // Guards the prefill selectors against a portal rename: the challan input
      // must be discoverable by the same id substring the injected script uses.
      const searchForm = PortalFixtures.realPortalUnsearched;

      expect(searchForm.contains('lblchallanno'), isTrue);
      expect(searchForm.contains('lblquantity'), isTrue);
      expect(searchForm.contains('lblunit'), isTrue);
      expect(searchForm.contains('lbluser'), isTrue);
    });
  });
}
