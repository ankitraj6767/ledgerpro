import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_dom_parser.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';

import 'fixtures/portal_result_fixtures.dart';

void main() {
  const parser = ChallanDomParser();

  /// Portal dates are IST wall-clock; the parser returns UTC.
  DateTime istToUtc(
    int year,
    int month,
    int day, [
    int hour = 0,
    int minute = 0,
  ]) => DateTime.utc(
    year,
    month,
    day,
    hour,
    minute,
  ).subtract(const Duration(hours: 5, minutes: 30));

  group('layer 1 — ASP.NET label ids', () {
    test('extracts every field from generated control ids', () {
      final payload = parser.parse(PortalFixtures.aspNetLabelIds);

      expect(payload.challanNumber, 'BR2026001234');
      expect(payload.uidNumber, 'UID-88112');
      expect(payload.challanDate, istToUtc(2026, 5, 12, 14, 30));
      expect(payload.validUntil, istToUtc(2026, 5, 13, 14, 30));
      expect(payload.vehicleNumber, 'BR 01 GH 4567');
      expect(payload.vehicleType, 'Truck');
      expect(payload.mineralName, 'Sand (Balu)');
      expect(payload.quantity, 12.5);
      expect(payload.quantityText, '12.500');
      expect(payload.quantityUnit, 'MT');
      expect(payload.consignorName, 'Bihar Minerals Pvt Ltd');
      expect(payload.consigneeName, 'Navdream Infra');
      expect(payload.sourceLocation, 'Patna Ghat 4');
      expect(payload.destination, 'Gaya Site');
      expect(payload.hasAllMandatoryFields, isTrue);
    });

    test('suffix matching survives a different master-page prefix', () {
      final rewritten = PortalFixtures.aspNetLabelIds.replaceAll(
        'ctl00_ContentPlaceHolder1_',
        'ctl99_MainContent_Inner_',
      );
      final payload = parser.parse(rewritten);

      expect(payload.challanNumber, 'BR2026001234');
      expect(payload.hasAllMandatoryFields, isTrue);
    });
  });

  group('layer 2 — bilingual labelled containers', () {
    test('extracts English label rows with a colon separator cell', () {
      final payload = parser.parse(PortalFixtures.englishLabelRows);

      expect(payload.challanNumber, 'BR2026009999');
      expect(payload.uidNumber, 'UID-55010');
      expect(payload.challanDate, istToUtc(2026, 7, 1, 9, 15));
      expect(payload.vehicleNumber, 'BR-02-XY-1122');
      expect(payload.vehicleType, 'Hyva');
      expect(payload.mineralName, 'Stone Chips');
      expect(payload.quantity, 30);
      expect(payload.quantityUnit, 'MT');
      expect(payload.generatedFrom, 'Mine Owner');
      expect(payload.sourceLocation, 'Sone River Ghat');
      expect(payload.destination, 'Nalanda');
      expect(payload.consigneeName, 'Navdream Infra');
      // Repeated whitespace collapsed.
      expect(payload.consignorName, 'Ganga Stone Works');
      expect(payload.hasAllMandatoryFields, isTrue);
    });

    test('extracts Hindi-only label rows', () {
      final payload = parser.parse(PortalFixtures.hindiLabelRows);

      expect(payload.challanNumber, 'BR2026007777');
      expect(payload.uidNumber, 'UID-31415');
      expect(payload.challanDate, istToUtc(2026, 6, 15));
      expect(payload.validUntil, istToUtc(2026, 6, 16));
      expect(payload.vehicleNumber, 'BR 03 AB 9090');
      expect(payload.vehicleType, 'ट्रक');
      expect(payload.mineralName, 'बालू');
      expect(payload.quantity, 25.75);
      expect(payload.quantityText, '25.750');
      expect(payload.destination, 'पटना');
      expect(payload.hasAllMandatoryFields, isTrue);
    });

    test('handles mixed bilingual labels, entities and non-MT units', () {
      final payload = parser.parse(PortalFixtures.bilingualBootstrap);

      expect(payload.challanNumber, 'BR2026005555');
      expect(payload.challanDate, istToUtc(2026, 6, 20));
      expect(payload.vehicleNumber, 'BR-04 CD 3344');
      expect(payload.mineralName, 'Boulder & Grit');
      expect(payload.quantity, 8.25);
      expect(payload.quantityUnit, 'CUM');
      expect(payload.consigneeName, 'Navdream Infra');
      // Royalty is parsed with integer math, so no float drift.
      expect(payload.royaltyAmountPaise, 125050);
      expect(payload.hasAllMandatoryFields, isTrue);
    });
  });

  group('layer 3 — visible text pairs', () {
    test('extracts label : value pairs with no table markup', () {
      final payload = parser.parse(PortalFixtures.plainTextPairs);

      expect(payload.challanNumber, 'BR2026003333');
      expect(payload.challanDate, istToUtc(2026, 4, 5));
      expect(payload.vehicleNumber, 'BR05EF7788');
      expect(payload.mineralName, 'Brick');
      expect(payload.quantity, 5000);
      expect(payload.hasAllMandatoryFields, isTrue);
    });
  });

  group('missing and malformed pages', () {
    test('search form without a result yields no challan fields', () {
      final payload = parser.parse(PortalFixtures.searchFormOnly);

      expect(payload.challanNumber, isNull);
      expect(payload.hasAllMandatoryFields, isFalse);
      expect(parser.hasResultSection(PortalFixtures.searchFormOnly), isFalse);
    });

    test('no-record banner is detected', () {
      expect(parser.reportsNoRecord(PortalFixtures.noRecord), isTrue);
      expect(parser.reportsNoRecord(PortalFixtures.englishLabelRows), isFalse);
    });

    test('changed layout reports the mandatory fields that are missing', () {
      final payload = parser.parse(PortalFixtures.layoutChangedPartial);

      expect(payload.challanNumber, 'BR2026001234');
      expect(payload.hasAllMandatoryFields, isFalse);
      expect(
        payload.missingMandatoryFields,
        containsAll(<String>[
          'challan date',
          'vehicle number',
          'mineral name',
          'quantity',
        ]),
      );
    });

    test('garbage input never throws', () {
      expect(() => parser.parse(''), returnsNormally);
      expect(() => parser.parse('<<<>>>not html at all'), returnsNormally);
      expect(parser.parse('').isEmpty, isTrue);
    });

    test('quantity without a printed unit leaves the unit null', () {
      final payload = parser.parse(PortalFixtures.quantityWithoutUnit);

      expect(payload.quantity, 18.4);
      expect(payload.quantityText, '18.400');
      // Never invent "MT" — the assumption is applied (and recorded) at save.
      expect(payload.quantityUnit, isNull);
    });
  });

  group('date parsing', () {
    test('accepts the portal formats and treats them as IST', () {
      expect(
        ChallanDomParser.parsePortalDate('12/05/2026'),
        istToUtc(2026, 5, 12),
      );
      expect(
        ChallanDomParser.parsePortalDate('12-05-2026'),
        istToUtc(2026, 5, 12),
      );
      expect(
        ChallanDomParser.parsePortalDate('12.05.2026'),
        istToUtc(2026, 5, 12),
      );
      expect(
        ChallanDomParser.parsePortalDate('2026-05-12'),
        istToUtc(2026, 5, 12),
      );
      expect(
        ChallanDomParser.parsePortalDate('12/05/2026 02:30 PM'),
        istToUtc(2026, 5, 12, 14, 30),
      );
      expect(
        ChallanDomParser.parsePortalDate('12/05/2026 12:15 AM'),
        istToUtc(2026, 5, 12, 0, 15),
      );
    });

    test('a date is the same instant regardless of the device timezone', () {
      // Parsing is anchored to IST, so the result is an absolute instant and
      // does not depend on where the user's device is.
      final parsed = ChallanDomParser.parsePortalDate('12/05/2026 00:00')!;
      expect(parsed.isUtc, isTrue);
      expect(parsed, DateTime.utc(2026, 5, 11, 18, 30));
    });

    test('rejects nonsense dates', () {
      expect(ChallanDomParser.parsePortalDate(null), isNull);
      expect(ChallanDomParser.parsePortalDate(''), isNull);
      expect(ChallanDomParser.parsePortalDate('not a date'), isNull);
      expect(ChallanDomParser.parsePortalDate('45/45/2026'), isNull);
      expect(ChallanDomParser.parsePortalDate('12/05/2026 99:99'), isNull);
    });
  });

  group('numeric parsing', () {
    test('rupees convert to paise without float error', () {
      expect(ChallanDomParser.parseRupeesToPaise('₹ 1,250.50'), 125050);
      expect(ChallanDomParser.parseRupeesToPaise('1250'), 125000);
      expect(
        ChallanDomParser.parseRupeesToPaise('Rs. 10,00,000.05'),
        100000005,
      );
      expect(ChallanDomParser.parseRupeesToPaise('0.1'), 10);
      expect(ChallanDomParser.parseRupeesToPaise(null), isNull);
      expect(ChallanDomParser.parseRupeesToPaise('no amount'), isNull);
    });
  });

  group('normalization', () {
    test('challan numbers keep the original but normalize for comparison', () {
      expect(ChallanText.tidyChallanNumber('  br-2026/001 '), 'BR-2026/001');
      expect(ChallanText.normalizeToken('br-2026/001'), 'BR2026001');
      expect(ChallanText.normalizeToken('BR 2026 001'), 'BR2026001');
      // Differently formatted inputs collide, which is what blocks duplicates.
      expect(
        ChallanText.normalizeToken('br/2026/001'),
        ChallanText.normalizeToken('BR-2026-001'),
      );
    });

    test('vehicle numbers normalize away formatting', () {
      expect(ChallanText.normalizeToken('br 01 gh 4567'), 'BR01GH4567');
      expect(ChallanText.normalizeToken('BR-01-GH-4567'), 'BR01GH4567');
    });

    test('blank values collapse to null', () {
      expect(ChallanText.cleanOrNull(''), isNull);
      expect(ChallanText.cleanOrNull('   '), isNull);
      expect(ChallanText.cleanOrNull(null), isNull);
      expect(ChallanText.cleanOrNull('  a   b  '), 'a b');
    });
  });

  group('response hash', () {
    test('is stable for the same page and differs across pages', () {
      final a = parser.parse(PortalFixtures.englishLabelRows);
      final b = parser.parse(PortalFixtures.englishLabelRows);
      final c = parser.parse(PortalFixtures.hindiLabelRows);

      expect(a.responseHash, isNotNull);
      expect(a.responseHash, b.responseHash);
      expect(a.responseHash, isNot(c.responseHash));
    });
  });
}
