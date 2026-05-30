class Money implements Comparable<Money> {
  const Money._(this.paise);

  factory Money.fromPaise(int paise) => Money._(paise);

  factory Money.fromRupeeString(String input) {
    final normalized = input.replaceAll(',', '').replaceAll('₹', '').trim();
    if (normalized.isEmpty) {
      throw const FormatException('Amount is required');
    }

    final negative = normalized.startsWith('-');
    final unsigned = negative ? normalized.substring(1) : normalized;
    final parts = unsigned.split('.');
    if (parts.length > 2 || parts.first.isEmpty) {
      throw FormatException('Invalid amount: $input');
    }

    final rupees = int.parse(parts.first);
    final rawPaise = parts.length == 2 ? parts.last : '0';
    if (rawPaise.length > 2) {
      throw const FormatException('Money supports up to 2 decimal places');
    }

    final paise = int.parse(rawPaise.padRight(2, '0'));
    final value = rupees * 100 + paise;
    return Money._(negative ? -value : value);
  }

  final int paise;

  bool get isPositive => paise > 0;
  bool get isNegative => paise < 0;
  bool get isZero => paise == 0;

  Money abs() => Money._(paise.abs());

  Money operator +(Money other) => Money._(paise + other.paise);
  Money operator -(Money other) => Money._(paise - other.paise);
  Money operator -() => Money._(-paise);

  String formatInr({bool signed = false}) {
    final negative = paise < 0;
    final absolute = paise.abs();
    final rupees = absolute ~/ 100;
    final cents = absolute % 100;
    final sign = negative
        ? '-'
        : signed && paise > 0
        ? '+'
        : '';
    return '$sign₹${_formatIndianGrouping(rupees)}.${cents.toString().padLeft(2, '0')}';
  }

  /// Plain decimal string (no symbol, no grouping), suitable for pre-filling an
  /// editable amount field that is later parsed by [Money.fromRupeeString].
  String formatPlain() {
    final negative = paise < 0;
    final absolute = paise.abs();
    final rupees = absolute ~/ 100;
    final cents = absolute % 100;
    final sign = negative ? '-' : '';
    return '$sign$rupees.${cents.toString().padLeft(2, '0')}';
  }

  /// Compact Indian formatting using Crore / Lakh suffixes, e.g.
  /// ₹1.50 Cr, ₹75.25 Lakh, ₹12,500. Useful for dashboard KPIs and cards.
  String formatCompactInr() {
    final negative = paise < 0;
    final absoluteRupees = paise.abs() / 100.0;
    final sign = negative ? '-' : '';
    if (absoluteRupees >= 10000000) {
      final cr = absoluteRupees / 10000000;
      return '$sign₹${_trim(cr)} Cr';
    }
    if (absoluteRupees >= 100000) {
      final lakh = absoluteRupees / 100000;
      return '$sign₹${_trim(lakh)} Lakh';
    }
    return formatInr();
  }

  static String _trim(double value) {
    // Two decimals, then strip trailing zeros (1.50 -> 1.5, 2.00 -> 2).
    var s = value.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  static String _formatIndianGrouping(int rupees) {
    final value = rupees.toString();
    if (value.length <= 3) return value;

    final lastThree = value.substring(value.length - 3);
    var remaining = value.substring(0, value.length - 3);
    final groups = <String>[];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) groups.insert(0, remaining);
    return '${groups.join(',')},$lastThree';
  }

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) => other is Money && other.paise == paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => formatInr();
}
