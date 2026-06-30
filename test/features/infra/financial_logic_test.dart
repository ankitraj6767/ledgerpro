import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  group('GovernmentFund.pendingAmountPaise', () {
    test('computes sanctioned minus received', () {
      const fund = GovernmentFund(
        id: '1',
        projectId: 'p1',
        departmentName: 'PWD',
        amountSanctionedPaise: 15000000,
        amountReceivedPaise: 7000000,
      );
      expect(fund.pendingAmountPaise, 8000000);
    });

    test('never goes negative when over-received', () {
      const fund = GovernmentFund(
        id: '1',
        projectId: 'p1',
        departmentName: 'PWD',
        amountSanctionedPaise: 5000000,
        amountReceivedPaise: 5000000,
      );
      expect(fund.pendingAmountPaise, 0);
    });
  });

  group('Project financial summary math (deterministic)', () {
    test('available balance = investment + govt received - expenses', () {
      const summary = ProjectFinancialSummary(
        totalInvestmentPaise: 2050000, // Rs 20,500
        totalGovtReceivedPaise: 500000, // Rs 5,000
        totalExpensePaise: 52666900, // Rs 5,26,669
      );

      expect(summary.cashInPaise, 2550000);
      expect(summary.calculatedAvailableBalancePaise, -50116900);
    });

    test('expense category percentages sum to ~100', () {
      final byCategory = {
        'Material': 1800000,
        'Labor': 1250000,
        'Machine Rent': 600000,
        'Transport': 450000,
        'Other': 460000,
      };
      final total = byCategory.values.fold<int>(0, (s, v) => s + v);
      final sumPct = byCategory.values
          .map((v) => v / total * 100)
          .fold<double>(0, (s, v) => s + v);
      expect(sumPct, closeTo(100, 0.001));
    });
  });

  group('InfraProject.financialProgressPercent', () {
    InfraProject project({
      required int estimatedCost,
      required int invested,
      required int received,
      int returned = 0,
    }) => InfraProject(
      id: 'p1',
      organizationId: 'o1',
      name: 'Project',
      totalEstimatedCostPaise: estimatedCost,
      totalInvestmentPaise: invested,
      totalInvestmentReturnedPaise: returned,
      totalGovtReceivedPaise: received,
    );

    test('uses gross investment minus returned capital', () {
      final value = project(
        estimatedCost: 10000,
        invested: 9000,
        returned: 3000,
        received: 0,
      );

      expect(value.netInvestmentPaise, 6000);
      expect(value.financialProgressPercent, 60);
    });

    test('combines investment and received funds against estimated cost', () {
      expect(
        project(
          estimatedCost: 10000,
          invested: 4300,
          received: 0,
        ).financialProgressPercent,
        43,
      );
      expect(
        project(
          estimatedCost: 10000,
          invested: 3000,
          received: 2000,
        ).financialProgressPercent,
        50,
      );
      expect(
        project(
          estimatedCost: 10000,
          invested: 6000,
          received: 4000,
        ).financialProgressPercent,
        100,
      );
    });

    test('handles no estimate and clamps over-funding to 100', () {
      expect(
        project(
          estimatedCost: 0,
          invested: 5000,
          received: 5000,
        ).financialProgressPercent,
        0,
      );
      expect(
        project(
          estimatedCost: 10000,
          invested: 8000,
          received: 4000,
        ).financialProgressPercent,
        100,
      );
    });

    test('never exposes a negative net investment', () {
      expect(
        project(
          estimatedCost: 10000,
          invested: 3000,
          returned: 4000,
          received: 0,
        ).netInvestmentPaise,
        0,
      );
    });
  });

  group('ExpenseCategories suggestions', () {
    test('keeps existing values and removes case-insensitive duplicates', () {
      final suggestions = ExpenseCategories.suggestions([
        'fuel',
        'asdf',
        'sand',
        'Contractor',
        'Fuel',
      ]);

      expect(suggestions.take(4), ['fuel', 'asdf', 'sand', 'Contractor']);
      expect(
        suggestions.where((category) => category.toLowerCase() == 'fuel'),
        hasLength(1),
      );
    });

    test('filters suggestions as the user types', () {
      final matches = ExpenseCategories.matching(
        ExpenseCategories.suggestions(['fuel', 'sand']),
        'fu',
      );

      expect(matches, contains('fuel'));
      expect(matches, isNot(contains('sand')));
    });
  });
}
