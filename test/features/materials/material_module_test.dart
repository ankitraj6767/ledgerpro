import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/app/constants/app_constants.dart';
import 'package:ledgerpro_mobile/data/repositories/material_repository.dart';
import 'package:ledgerpro_mobile/shared/models/material_models.dart';
import 'package:ledgerpro_mobile/shared/widgets/infra_shell.dart';

void main() {
  group('material dashboard mapping', () {
    test('maps numeric RPC values into typed summary', () {
      final summary = MaterialDashboardSummary.fromJson({
        'total_schools': 250,
        'running_schools': 180,
        'completed_schools': 120,
        'pending_schools': 70,
        'total_items_in_warehouse': 18,
        'low_stock_items': 4,
        'total_received_quantity': 1000,
        'total_issued_quantity': 725.5,
        'total_remaining_quantity': 274.5,
      });

      expect(summary.totalSchools, 250);
      expect(summary.lowStockItems, 4);
      expect(summary.totalIssuedQuantity, 725.5);
    });
  });

  group('quantity validation', () {
    test('requires positive quantities', () {
      expect(validatePositiveQuantity('0'), isNotNull);
      expect(validatePositiveQuantity('-1'), isNotNull);
      expect(validatePositiveQuantity('2.5'), isNull);
    });

    test('blocks issue above available stock', () {
      expect(validateIssueQuantity('11', 10), contains('Only 10 available'));
      expect(validateIssueQuantity('10', 10), isNull);
    });
  });

  group('material setup readiness', () {
    test('receive needs tender, warehouse, and material', () {
      const status = MaterialSetupStatus(
        tenders: 1,
        districts: 1,
        warehouses: 1,
        managers: 0,
        schools: 0,
        materials: 1,
      );

      expect(status.isReadyForReceive, isTrue);
      expect(status.isReadyForIssue, isFalse);
      expect(status.completedSteps, 4);
    });

    test('issue is ready only after full operational setup', () {
      const status = MaterialSetupStatus(
        tenders: 1,
        districts: 1,
        warehouses: 1,
        managers: 1,
        schools: 1,
        materials: 1,
      );

      expect(status.isReadyForIssue, isTrue);
      expect(status.isComplete, isTrue);
    });
  });

  test('materials replaces expenses at bottom navigation index 2', () {
    expect(InfraShell.indexForPath(AppRoutes.materials), 2);
    expect(InfraShell.indexForPath(AppRoutes.reports), 3);
    expect(InfraShell.indexForPath(AppRoutes.profile), 4);
    expect(InfraShell.indexForPath(AppRoutes.expenses), 0);
  });
}
