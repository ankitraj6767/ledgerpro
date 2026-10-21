import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../shared/components/infra_components.dart';
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
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            key: ValueKey('expense-category-group-${widget.group.categoryKey}'),
            contentPadding: const EdgeInsets.fromLTRB(6, 2, 4, 2),
            leading: Checkbox(
              activeColor: InfraColors.royalBlue,
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
            title: Text(
              widget.group.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: InfraColors.textSecondary,
                ),
              ),
            ),
            onTap: _toggleExpanded,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AmountText(
                  paise: widget.group.totalAmountPaise,
                  color: InfraColors.red,
                  size: 13,
                  weight: FontWeight.w700,
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
        if (_isExpanded)
          ...widget.group.expenses.map(
            (expense) => widget.childBuilder(context, expense),
          ),
      ],
    );
  }
}
