import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/widgets/project_expense_category_group.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  testWidgets('starts collapsed and expands only its own subcategory rows', (
    tester,
  ) async {
    final groups = ProjectExpenseCategoryGroup.fromExpenses([
      const ProjectExpense(
        id: 'e1',
        projectId: 'p1',
        category: 'Biscuit',
        subcategory: 'vhhh',
      ),
      const ProjectExpense(
        id: 'e2',
        projectId: 'p1',
        category: 'Biscuit',
        subcategory: 'Skilled',
      ),
      const ProjectExpense(
        id: 'e3',
        projectId: 'p1',
        category: 'Labour',
        subcategory: 'unskilled',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              for (final group in groups)
                ProjectExpenseCategoryGroupSection(
                  group: group,
                  isExpenseSelected: (_) => false,
                  onGroupSelectionChanged: (expenses, selected) {},
                  childBuilder: (context, expense) => ListTile(
                    title: Text(expense.subcategory ?? expense.category),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Biscuit'), findsOneWidget);
    expect(find.text('Labour'), findsOneWidget);
    expect(find.text('vhhh'), findsNothing);
    expect(find.text('Skilled'), findsNothing);
    expect(find.text('unskilled'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('expense-category-group-expand-biscuit')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biscuit'), findsOneWidget);
    expect(find.text('vhhh'), findsOneWidget);
    expect(find.text('Skilled'), findsOneWidget);
    expect(find.text('unskilled'), findsNothing);
  });
}
