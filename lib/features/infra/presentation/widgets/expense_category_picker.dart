import 'package:flutter/material.dart';

import '../../../../shared/models/infra_models.dart';

/// The nested category list used by the expense autocomplete overlay.
///
/// Expansion is intentionally tracked by category name, so opening one parent
/// never expands its siblings. Children are rendered only while their own
/// parent is expanded.
class ExpenseCategoryOptionsView extends StatefulWidget {
  const ExpenseCategoryOptionsView({
    super.key,
    required this.categories,
    required this.query,
    required this.onSelected,
  });

  final List<ExpenseCategory> categories;
  final String query;
  final ValueChanged<ExpenseCategorySelection> onSelected;

  @override
  State<ExpenseCategoryOptionsView> createState() =>
      _ExpenseCategoryOptionsViewState();
}

class _ExpenseCategoryOptionsViewState
    extends State<ExpenseCategoryOptionsView> {
  final Set<String> _expandedCategories = <String>{};

  bool _matchesChild(ExpenseCategory category) {
    final query = widget.query.trim().toLowerCase();
    return query.isNotEmpty &&
        category.subcategories.any(
          (subcategory) => subcategory.toLowerCase().contains(query),
        );
  }

  bool _isExpanded(ExpenseCategory category) {
    return _expandedCategories.contains(category.name) ||
        _matchesChild(category);
  }

  void _toggle(ExpenseCategory category) {
    setState(() {
      if (!_expandedCategories.remove(category.name)) {
        _expandedCategories.add(category.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final expanded = _isExpanded(category);
        return Column(
          key: ValueKey('expense-category-group-${category.name}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: ValueKey('expense-category-${category.name}'),
              leading: Icon(
                category.hasSubcategories
                    ? Icons.folder_outlined
                    : Icons.category_outlined,
              ),
              title: Text(category.name),
              subtitle: category.hasSubcategories
                  ? const Text('Category')
                  : null,
              trailing: category.hasSubcategories
                  ? IconButton(
                      key: ValueKey('expense-category-expand-${category.name}'),
                      tooltip: expanded
                          ? 'Collapse category'
                          : 'Expand category',
                      onPressed: () => _toggle(category),
                      icon: Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    )
                  : null,
              onTap: () => widget.onSelected(
                ExpenseCategorySelection(category: category.name),
              ),
            ),
            if (expanded)
              for (final subcategory in category.subcategories)
                ListTile(
                  key: ValueKey(
                    'expense-subcategory-${category.name}-$subcategory',
                  ),
                  contentPadding: const EdgeInsets.only(left: 56, right: 16),
                  dense: true,
                  leading: const Icon(Icons.subdirectory_arrow_right),
                  title: Text(subcategory),
                  onTap: () => widget.onSelected(
                    ExpenseCategorySelection(
                      category: category.name,
                      subcategory: subcategory,
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
