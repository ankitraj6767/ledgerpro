import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ledgerpro_mobile/app/theme/infra_theme.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/infra_forms.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/project_detail_screen.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/widgets/project_expense_category_group.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/widgets/project_expense_workspace.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements InfraRepository {}

const _project = InfraProject(
  id: 'p1',
  organizationId: 'o1',
  name: 'Madhubani Bus Stand',
);
final _expenses = [
  ProjectExpense(
    id: 'staff',
    projectId: 'p1',
    category: 'SITE EXPENSES',
    subcategory: 'STAFF',
    amountPaise: 90000,
    expenseDate: DateTime(2026, 10, 20),
  ),
  ProjectExpense(
    id: 'misc',
    projectId: 'p1',
    category: 'SITE EXPENSES',
    subcategory: 'MISCELLANEOUS',
    amountPaise: 41000,
    expenseDate: DateTime(2026, 10, 19),
  ),
  ProjectExpense(
    id: 'transport',
    projectId: 'p1',
    category: 'TRANSPORT',
    amountPaise: 112000,
    expenseDate: DateTime(2026, 10, 18),
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  List<ProjectExpense>? expenses,
  OrgMemberRole role = OrgMemberRole.owner,
  Size size = const Size(430, 1100),
  double textScale = 1,
  double keyboard = 0,
  InfraRepository? repository,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const ProjectDetailScreen(
          projectId: 'p1',
          initialProject: _project,
          initialTabIndex: 3,
        ),
      ),
      GoRoute(
        path: '/projects/p1/expenses/new',
        builder: (_, state) => Scaffold(
          body: Text('New expense for ${(state.extra as InfraProject).name}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectsProvider.overrideWith((ref) async => [_project]),
        projectExpensesProvider(
          'p1',
        ).overrideWith((ref) async => expenses ?? _expenses),
        currentOrgRoleProvider.overrideWith((ref) async => role),
        currentOrgPermissionsProvider.overrideWithValue(
          OrgPermissions(role, currentUserId: 'u1'),
        ),
        if (repository != null)
          infraRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        theme: InfraTheme.light(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _entry(String id) => find.byKey(ValueKey('project-expense-entry-$id'));
Finder _expenseScroll() => find
    .descendant(
      of: find.byKey(const PageStorageKey('project-expenses-p1')),
      matching: find.byType(Scrollable),
    )
    .first;
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 220, scrollable: _expenseScroll());
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _expand(WidgetTester tester) async {
  final expand = find.byKey(
    const ValueKey('expense-category-group-expand-site expenses'),
  );
  await _reveal(tester, expand);
  await tester.tap(expand);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'exact totals, grouping and full transaction details are preserved',
    (tester) async {
      await _pump(tester);
      expect(find.text('₹2,430.00'), findsOneWidget);
      expect(find.text('3 expenses · 2 categories'), findsOneWidget);
      expect(find.text('STAFF'), findsNothing);
      await _expand(tester);
      await _reveal(tester, _entry('staff'));
      expect(find.text('STAFF'), findsOneWidget);
      await tester.tap(find.text('STAFF'));
      await tester.pumpAndSettle();
      expect(find.text('Expense Details'), findsOneWidget);
      expect(find.text('SITE EXPENSES / STAFF'), findsOneWidget);
      expect(find.text('Generate PDF'), findsOneWidget);
    },
  );

  testWidgets('category and amount search update totals and clear correctly', (
    tester,
  ) async {
    await _pump(tester);
    final search = find.widgetWithText(
      TextField,
      'Search category, subcategory or amount',
    );
    await tester.enterText(search, '410');
    await tester.pumpAndSettle();
    expect(find.text('Filtered Expenses'), findsOneWidget);
    expect(find.text('₹410.00'), findsWidgets);
    expect(find.text('1 expense · 1 category'), findsOneWidget);
    await tester.enterText(search, 'not-an-expense');
    await tester.pumpAndSettle();
    expect(find.text('No matching expenses'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('₹2,430.00'), findsOneWidget);
  });

  testWidgets(
    'date and name ordering retain their default directions and toggle',
    (tester) async {
      await _pump(tester);
      await _expand(tester);
      List<String> titles() => tester
          .widgetList<ExpenseEntryCard>(find.byType(ExpenseEntryCard))
          .map((card) => card.title)
          .toList();
      expect(titles(), ['STAFF', 'MISCELLANEOUS', 'TRANSPORT']);
      await _reveal(tester, find.text('Name'));
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Ascending'), findsOneWidget);
      expect(titles(), ['MISCELLANEOUS', 'STAFF', 'TRANSPORT']);
      await tester.tap(find.byTooltip('Ascending'));
      await tester.pumpAndSettle();
      expect(titles(), ['TRANSPORT', 'STAFF', 'MISCELLANEOUS']);
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Descending'), findsOneWidget);
      expect(titles(), ['STAFF', 'MISCELLANEOUS', 'TRANSPORT']);
    },
  );

  testWidgets(
    'group selection, partial selection and select all remain independent of expansion',
    (tester) async {
      await _pump(tester);
      final group = find.byType(ProjectExpenseCategoryGroupSection);
      await _reveal(tester, group);
      await tester.tap(
        find.descendant(of: group, matching: find.byType(Checkbox)).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('2 Selected'), findsOneWidget);
      expect(find.text('Generate PDF').hitTestable(), findsOneWidget);
      await _expand(tester);
      await _reveal(tester, _entry('staff'));
      await tester.tap(
        find.descendant(of: _entry('staff'), matching: find.byType(Checkbox)),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 Selected'), findsOneWidget);
      expect(
        tester
            .widget<Checkbox>(
              find.descendant(of: group, matching: find.byType(Checkbox)).first,
            )
            .value,
        isNull,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(ExpenseSelectionBar),
          matching: find.byType(Checkbox),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 Selected'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Clear'));
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseSelectionBar), findsNothing);
    },
  );

  testWidgets('add expense retains its project route payload', (tester) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Add expense'));
    await tester.pumpAndSettle();
    expect(find.text('New expense for Madhubani Bus Stand'), findsOneWidget);
  });

  testWidgets('edit opens the existing form with its saved values', (
    tester,
  ) async {
    await _pump(tester);
    await _expand(tester);
    await _reveal(tester, _entry('staff'));
    await tester.tap(
      find.descendant(
        of: _entry('staff'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseFormScreen), findsOneWidget);
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.controller?.text),
      contains('900.00'),
    );
  });

  testWidgets(
    'delete still requires confirmation before calling the repository',
    (tester) async {
      final repository = _Repository();
      when(
        () => repository.deleteExpense('transport'),
      ).thenAnswer((_) async {});
      await _pump(tester, repository: repository);
      Future<void> openDelete() async {
        await _reveal(tester, _entry('transport'));
        await tester.tap(
          find.descendant(
            of: _entry('transport'),
            matching: find.byType(PopupMenuButton<String>),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
      }

      await openDelete();
      expect(find.text('Delete expense?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verifyNever(() => repository.deleteExpense('transport'));
      await openDelete();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      verify(() => repository.deleteExpense('transport')).called(1);
    },
  );

  testWidgets('read-only permissions hide add, edit and delete actions', (
    tester,
  ) async {
    await _pump(tester, role: OrgMemberRole.viewer);
    expect(find.byTooltip('Add expense'), findsNothing);
    await _expand(tester);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('empty projects keep the add action and empty-state guidance', (
    tester,
  ) async {
    await _pump(tester, expenses: []);
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.byTooltip('Add expense'), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1200, 900),
  ]) {
    testWidgets('large text, long labels and keyboard fit $size', (
      tester,
    ) async {
      await _pump(
        tester,
        size: size,
        textScale: 1.8,
        keyboard: 220,
        expenses: [
          _expenses.first.copyWith(
            category: 'SITE EXPENSES AND PROJECT OPERATIONS',
            subcategory: 'OTHER PERSONAL LABOUR AND SPECIALIST SUPPORT',
            amountPaise: 2962736000,
          ),
        ],
      );
      expect(tester.takeException(), isNull);
      final group = find.byType(ProjectExpenseCategoryGroupSection);
      await _reveal(tester, group);
      await tester.tap(
        find.descendant(of: group, matching: find.byType(Checkbox)).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Generate PDF'));
      await tester.pumpAndSettle();
      expect(find.text('Generate PDF').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
