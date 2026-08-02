import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/widgets/expense_category_picker.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  testWidgets('expands only the selected parent category', (tester) async {
    final categories = const [
      ExpenseCategory(name: 'Item', subcategories: ['item1', 'item2']),
      ExpenseCategory(name: 'Another', subcategories: ['another1', 'another2']),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: ExpenseCategoryOptionsView(
              categories: categories,
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('item1'), findsNothing);
    expect(find.text('item2'), findsNothing);
    expect(find.text('another1'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('expense-category-expand-Item')),
    );
    await tester.pumpAndSettle();

    expect(find.text('item1'), findsOneWidget);
    expect(find.text('item2'), findsOneWidget);
    expect(find.text('another1'), findsNothing);
    expect(find.text('another2'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('expense-category-expand-Another')),
    );
    await tester.pumpAndSettle();

    expect(find.text('item1'), findsOneWidget);
    expect(find.text('another1'), findsOneWidget);
  });

  testWidgets('returns parent and child when a subcategory is selected', (
    tester,
  ) async {
    ExpenseCategorySelection? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: ExpenseCategoryOptionsView(
              categories: const [
                ExpenseCategory(name: 'Item', subcategories: ['item1']),
              ],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('expense-category-expand-Item')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('item1'));

    expect(
      selected,
      const ExpenseCategorySelection(category: 'Item', subcategory: 'item1'),
    );
  });
}
