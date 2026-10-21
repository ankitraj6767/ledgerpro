import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../core/money/money.dart';

/// Expense-only surfaces; other project tabs keep their own presentation.
class ExpenseWorkspaceStyle {
  const ExpenseWorkspaceStyle._();

  static const ink = Color(0xFF102B3F);
  static const muted = Color(0xFF667585);
  static const field = Color(0xFFF4F7FA);
  static const gold = Color(0xFFDEC592);
  static const line = Color(0xFFE3E8ED);

  static BoxDecoration surface({bool selected = false}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: selected ? ink : line, width: selected ? 1.5 : 1),
  );
}

class ExpenseWorkspaceToolbar extends StatelessWidget {
  const ExpenseWorkspaceToolbar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.showSort,
    required this.sortByName,
    required this.ascending,
    required this.onSortChanged,
    required this.onToggleDirection,
    this.onAdd,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showSort;
  final bool sortByName;
  final bool ascending;
  final ValueChanged<bool> onSortChanged;
  final VoidCallback onToggleDirection;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    color: ExpenseWorkspaceStyle.ink,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search category, subcategory or amount',
                    hintStyle: const TextStyle(
                      color: ExpenseWorkspaceStyle.muted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 21,
                      color: ExpenseWorkspaceStyle.muted,
                    ),
                    suffixIcon: query.trim().isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: onClear,
                            icon: const Icon(Icons.close_rounded, size: 19),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: ExpenseWorkspaceStyle.line,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: ExpenseWorkspaceStyle.line,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: ExpenseWorkspaceStyle.ink,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              if (onAdd != null) ...[
                const SizedBox(width: 10),
                IconButton.filled(
                  tooltip: 'Add expense',
                  onPressed: onAdd,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(54, 54),
                    backgroundColor: ExpenseWorkspaceStyle.ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ],
          ),
          if (showSort) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Date')),
                      ButtonSegment(value: true, label: Text('Name')),
                    ],
                    selected: {sortByName},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        onSortChanged(selection.first),
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      side: const WidgetStatePropertyAll(
                        BorderSide(color: ExpenseWorkspaceStyle.line),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? ExpenseWorkspaceStyle.ink
                            : Colors.white,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : ExpenseWorkspaceStyle.muted,
                      ),
                      textStyle: WidgetStatePropertyAll(
                        Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: ascending ? 'Ascending' : 'Descending',
                  onPressed: onToggleDirection,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: Colors.white,
                    foregroundColor: ExpenseWorkspaceStyle.ink,
                    side: const BorderSide(color: ExpenseWorkspaceStyle.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ExpenseSummaryCard extends StatelessWidget {
  const ExpenseSummaryCard({
    super.key,
    required this.projectName,
    required this.amountPaise,
    required this.expenseCount,
    required this.categoryCount,
    required this.filtered,
  });

  final String projectName;
  final int amountPaise;
  final int expenseCount;
  final int categoryCount;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [InfraColors.navy, Color(0xFF15374A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C4658)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            style: const TextStyle(
              color: Color(0xFFB3C2CE),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            filtered ? 'Filtered Expenses' : 'Total Expenses',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            Money.fromPaise(amountPaise).formatInr(),
            style: const TextStyle(
              color: ExpenseWorkspaceStyle.gold,
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'} · $categoryCount ${categoryCount == 1 ? 'category' : 'categories'}',
            style: const TextStyle(
              color: Color(0xFFB3C2CE),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseEntryCard extends StatelessWidget {
  const ExpenseEntryCard({
    super.key,
    required this.title,
    required this.metadata,
    required this.amountPaise,
    required this.selected,
    required this.onSelectionChanged,
    required this.onTap,
    required this.menu,
    this.nested = false,
  });

  final String title;
  final String metadata;
  final int amountPaise;
  final bool selected;
  final ValueChanged<bool?> onSelectionChanged;
  final VoidCallback onTap;
  final Widget menu;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: nested ? 14 : 0, bottom: 10),
      decoration: ExpenseWorkspaceStyle.surface(selected: selected),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Select $title for PDF',
                  child: Checkbox(
                    value: selected,
                    activeColor: ExpenseWorkspaceStyle.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: onSelectionChanged,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 8,
                              ),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: ExpenseWorkspaceStyle.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          menu,
                        ],
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          if (metadata.isNotEmpty)
                            Text(
                              metadata,
                              style: const TextStyle(
                                color: ExpenseWorkspaceStyle.muted,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          Text(
                            Money.fromPaise(amountPaise).formatInr(),
                            style: const TextStyle(
                              color: ExpenseWorkspaceStyle.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpenseSelectionBar extends StatelessWidget {
  const ExpenseSelectionBar({
    super.key,
    required this.count,
    required this.allSelected,
    required this.onSelectAll,
    required this.onClear,
    required this.onGeneratePdf,
  });

  final int count;
  final bool allSelected;
  final ValueChanged<bool?> onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onGeneratePdf;

  @override
  Widget build(BuildContext context) {
    final selection = Row(
      children: [
        Semantics(
          label: 'Select all matching expenses',
          child: Checkbox(
            activeColor: ExpenseWorkspaceStyle.ink,
            value: allSelected,
            onChanged: onSelectAll,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$count Selected',
            style: const TextStyle(
              color: ExpenseWorkspaceStyle.ink,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: onClear,
          child: const Text(
            'Clear',
            style: TextStyle(color: ExpenseWorkspaceStyle.muted),
          ),
        ),
      ],
    );
    final pdf = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: ExpenseWorkspaceStyle.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      onPressed: onGeneratePdf,
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 19),
      label: const Text('Generate PDF', textAlign: TextAlign.center),
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
      decoration: ExpenseWorkspaceStyle.surface(selected: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 560 &&
              MediaQuery.textScalerOf(context).scale(14) < 20) {
            return Row(
              children: [
                Expanded(child: selection),
                const SizedBox(width: 16),
                pdf,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [selection, const SizedBox(height: 4), pdf],
          );
        },
      ),
    );
  }
}
