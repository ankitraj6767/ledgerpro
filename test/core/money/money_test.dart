import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/money/money.dart';

void main() {
  group('Money', () {
    test('parses rupee strings into integer paise without floating point', () {
      expect(Money.fromRupeeString('1,23,456.70').paise, 12345670);
      expect(Money.fromRupeeString('₹99').paise, 9900);
      expect(Money.fromRupeeString('-10.05').paise, -1005);
    });

    test('formats INR with Indian grouping', () {
      expect(Money.fromPaise(12345670).formatInr(), '₹1,23,456.70');
      expect(Money.fromPaise(-500).formatInr(), '-₹5.00');
      expect(Money.fromPaise(500).formatInr(signed: true), '+₹5.00');
    });

    test('rejects more than two decimal places', () {
      expect(() => Money.fromRupeeString('10.555'), throwsFormatException);
    });
  });
}
