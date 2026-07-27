import 'package:intl/intl.dart';

/// Display formatting for challan timestamps.
///
/// Shared by the detail screen and the PDF report so an exported challan reads
/// exactly like the one on screen — a mismatch between the two would be a real
/// problem, since the PDF is what gets handed to an auditor.
class ChallanDates {
  const ChallanDates._();

  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _day = DateFormat('dd MMM yyyy');

  /// Portal timestamps are IST wall-clock stored as UTC, so they are rendered in
  /// IST regardless of the device's zone. The time is dropped when the portal
  /// only gave a date.
  static String ist(DateTime? value, {String fallback = '—'}) {
    if (value == null) return fallback;
    final shifted = value.toUtc().add(const Duration(hours: 5, minutes: 30));
    final naive = DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
    );
    final hasTime = shifted.hour != 0 || shifted.minute != 0;
    return '${hasTime ? _dateTime.format(naive) : _day.format(naive)} IST';
  }

  /// LedgerPro's own audit timestamps (captured/saved), shown in device time.
  static String local(DateTime? value, {String fallback = '—'}) =>
      value == null ? fallback : _dateTime.format(value.toLocal());

  /// Short IST day, for table rows where a full timestamp will not fit.
  static String istDay(DateTime? value, {String fallback = '-'}) {
    if (value == null) return fallback;
    final shifted = value.toUtc().add(const Duration(hours: 5, minutes: 30));
    return _day.format(DateTime(shifted.year, shifted.month, shifted.day));
  }
}
