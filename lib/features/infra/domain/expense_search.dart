import '../../../core/money/money.dart';
import '../../../shared/models/infra_models.dart';

/// Returns whether an expense matches every term in [rawQuery].
///
/// Expense search intentionally covers the persisted category hierarchy and
/// the amount shown to the user. Other transaction metadata remains excluded
/// so a note, vendor, or payment mode cannot make an unrelated expense appear
/// in category search results.
bool matchesProjectExpenseSearch(ProjectExpense expense, String rawQuery) {
  final amount = Money.fromPaise(expense.amountPaise);
  final plainAmount = amount.formatPlain();

  return _matchesSearchFields([
    expense.category,
    expense.subcategory,
    amount.formatInr(),
    plainAmount,
    // Also support entering whole rupees without decimal places or Indian
    // grouping separators, e.g. 515000 for ₹5,15,000.00.
    plainAmount.replaceFirst(RegExp(r'\.00$'), ''),
    amount.formatInr().replaceAll(',', ''),
    '₹$plainAmount',
  ], rawQuery);
}

bool _matchesSearchFields(Iterable<Object?> fields, String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return true;

  final haystack = fields
      .where((value) => value != null)
      .map((value) => value.toString().toLowerCase())
      .join(' ');

  return query
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .every(haystack.contains);
}
