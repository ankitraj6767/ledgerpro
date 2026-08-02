import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/infra_forms.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  testWidgets(
    'expense form keeps category and subcategory as separate fields',
    (tester) async {
      const project = InfraProject(
        id: 'project-1',
        organizationId: 'org-1',
        name: 'Test Project',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentOrgRoleProvider.overrideWith(
              (ref) async => OrgMemberRole.owner,
            ),
            currentOrgPermissionsProvider.overrideWithValue(
              const OrgPermissions(OrgMemberRole.owner),
            ),
            projectExpensesProvider(project.id).overrideWith(
              (ref) async => const [
                ProjectExpense(
                  id: 'expense-1',
                  projectId: 'project-1',
                  category: 'Labor',
                  subcategory: 'Unskilled Labor',
                ),
                ProjectExpense(
                  id: 'expense-2',
                  projectId: 'project-1',
                  category: 'Labor',
                  subcategory: 'Skilled Labor',
                ),
              ],
            ),
          ],
          child: const MaterialApp(home: ExpenseFormScreen(project: project)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Subcategory'), findsOneWidget);
      expect(find.text('Category / use case'), findsNothing);
    },
  );
}
