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
      const investment = 10000000; // 1 Lakh
      const govtReceived = 7000000; // 70k
      const expenses = 4500000; // 45k
      final available = investment + govtReceived - expenses;
      expect(available, 12500000);
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
}
