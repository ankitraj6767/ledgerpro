import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/money/money.dart';

void main() {
  group('Money compact INR formatting', () {
    test('formats crore amounts', () {
      // 1.5 Cr = 1,50,00,000 rupees = 1,50,00,00,000 paise
      expect(Money.fromPaise(1500000000).formatCompactInr(), '₹1.5 Cr');
    });

    test('formats lakh amounts', () {
      // 75.25 Lakh = 75,25,000 rupees = 75,25,00,000 paise
      expect(Money.fromPaise(752500000).formatCompactInr(), '₹75.25 Lakh');
    });

    test('falls back to full INR below one lakh', () {
      // 12,500 rupees
      expect(Money.fromPaise(1250000).formatCompactInr(), '₹12,500.00');
    });

    test('trims trailing zeros in crore', () {
      // exactly 2 Cr = 2,00,00,000 rupees = 2,00,00,00,000 paise
      expect(Money.fromPaise(2000000000).formatCompactInr(), '₹2 Cr');
    });
  });

  group('Money paise parsing', () {
    test('parses rupee string to paise', () {
      expect(Money.fromRupeeString('1,00,000').paise, 10000000);
      expect(Money.fromRupeeString('₹2500.50').paise, 250050);
    });

    test('rejects more than two decimals', () {
      expect(() => Money.fromRupeeString('10.123'), throwsFormatException);
    });
  });
}
