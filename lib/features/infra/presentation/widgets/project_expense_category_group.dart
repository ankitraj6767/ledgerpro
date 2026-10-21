import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../core/money/money.dart';
import 'project_expense_workspace.dart';
import '../../../../shared/models/infra_models.dart';

/// A collapsed-by-default parent category that reveals its existing expense
/// transactions only when the user expands it.
class ProjectExpenseCategoryGroupSection extends StatefulWidget {
  const ProjectExpenseCategoryGroupSection({
    super.key,
    required this.group,
    required this.isExpenseSelected,
    required this.onGroupSelectionChanged,
    required this.childBuilder,
  });

  final ProjectExpenseCategoryGroup group;
  final bool Function(String expenseId) isExpenseSelected;
  final void Function(Iterable<ProjectExpense> expenses, bool selected)
  onGroupSelectionChanged;
  final Widget Function(BuildContext context, ProjectExpense expense)
  childBuilder;

  @override
  State<ProjectExpenseCategoryGroupSection> createState() =>
      _ProjectExpenseCategoryGroupSectionState();
}

class _ProjectExpenseCategoryGroupSectionState
    extends State<ProjectExpenseCategoryGroupSection> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.group.expenses
        .where((expense) => widget.isExpenseSelected(expense.id))
        .length;
    final isAllSelected = selectedCount == widget.group.expenses.length;
    final isPartiallySelected = selectedCount > 0 && !isAllSelected;
    final expenseCount = widget.group.expenses.length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _isExpanded ? const Color(0xFFEEF3F7) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isExpanded
                  ? const Color(0xFFC7D4DF)
                  : ExpenseWorkspaceStyle.line,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey(
                'expense-category-group-${widget.group.categoryKey}',
              ),
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Select all ${widget.group.category} expenses',
                      child: Checkbox(
                        activeColor: ExpenseWorkspaceStyle.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        tristate: true,
                        value: isAllSelected
                            ? true
                            : isPartiallySelected
                            ? null
                            : false,
                        onChanged: (value) => widget.onGroupSelectionChanged(
                          widget.group.expenses,
                          value == true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.group.category,
                              style: const TextStyle(
                                color: ExpenseWorkspaceStyle.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: ExpenseWorkspaceStyle.muted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Money.fromPaise(
                                widget.group.totalAmountPaise,
                              ).formatInr(),
                              style: const TextStyle(
                                color: ExpenseWorkspaceStyle.ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      key: ValueKey(
                        'expense-category-group-expand-${widget.group.categoryKey}',
                      ),
                      tooltip: _isExpanded
                          ? 'Collapse ${widget.group.category}'
                          : 'Expand ${widget.group.category}',
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: InfraColors.textSecondary,
                      ),
                      onPressed: _toggleExpanded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded)
          ...widget.group.expenses.map(
            (expense) => widget.childBuilder(context, expense),
          ),
      ],
    );
  }
}
