import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  group('OrgPermissions', () {
    const ownExpense = ProjectExpense(
      id: 'expense-1',
      projectId: 'project-1',
      createdBy: 'customer-1',
    );
    const otherExpense = ProjectExpense(
      id: 'expense-2',
      projectId: 'project-1',
      createdBy: 'customer-2',
    );

    test('customer can read and add expenses', () {
      const permissions = OrgPermissions(
        OrgMemberRole.customer,
        currentUserId: 'customer-1',
      );

      expect(permissions.canReadOrg, isTrue);
      expect(permissions.canAddExpense, isTrue);
    });

    test('customer can edit only own expense', () {
      const permissions = OrgPermissions(
        OrgMemberRole.customer,
        currentUserId: 'customer-1',
      );

      expect(permissions.canEditExpense(ownExpense), isTrue);
      expect(permissions.canEditExpense(otherExpense), isFalse);
    });

    test('customer cannot delete expenses or manage admin data', () {
      const permissions = OrgPermissions(
        OrgMemberRole.customer,
        currentUserId: 'customer-1',
      );

      expect(permissions.canDeleteExpense, isFalse);
      expect(permissions.canManageProjects, isFalse);
      expect(permissions.canManageUsers, isFalse);
      expect(permissions.canManageInvestments, isFalse);
      expect(permissions.canManageFunds, isFalse);
      expect(permissions.canEditSettings, isFalse);
      expect(permissions.canViewAuditLogs, isFalse);
    });

    test('owner keeps full admin permissions', () {
      const permissions = OrgPermissions(OrgMemberRole.owner);

      expect(permissions.canManageUsers, isTrue);
      expect(permissions.canManageProjects, isTrue);
      expect(permissions.canDeleteExpense, isTrue);
      expect(permissions.canViewAuditLogs, isTrue);
    });
  });
}
