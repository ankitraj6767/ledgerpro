import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/money/balance_calculator.dart';
import 'package:ledgerpro_mobile/shared/models/ledger_models.dart';

void main() {
  final calculator = BalanceCalculator();

  LedgerTransaction entry({
    required String id,
    required TransactionType type,
    required int amountPaise,
    bool isReversal = false,
  }) {
    return LedgerTransaction(
      id: id,
      businessId: 'b1',
      bookId: 'book1',
      partyId: 'p1',
      type: type,
      amountPaise: amountPaise,
      occurredAt: DateTime(2026, 5, 27),
      isReversal: isReversal,
    );
  }

  group('BalanceCalculator', () {
    test('computes party balance from transaction history', () {
      final balance = calculator.balanceFor([
        entry(id: 't1', type: TransactionType.youGave, amountPaise: 10000),
        entry(id: 't2', type: TransactionType.youGot, amountPaise: 2500),
        entry(
          id: 't3',
          type: TransactionType.discountWriteOff,
          amountPaise: 500,
        ),
      ]);

      expect(balance, 7000);
    });

    test(
      'creates reversal entry without mutating the original transaction',
      () {
        final original = entry(
          id: 't1',
          type: TransactionType.youGave,
          amountPaise: 10000,
        );
        final reversal = calculator.reversalFor(
          original,
          reversalId: 'r1',
          occurredAt: DateTime(2026, 5, 28),
          actorId: 'owner',
        );

        expect(original.isReversal, isFalse);
        expect(reversal.isReversal, isTrue);
        expect(reversal.reversalOfTransactionId, 't1');
        expect(calculator.balanceFor([original, reversal]), 0);
      },
    );

    test('ignores soft-deleted entries in reproducible balance', () {
      final deleted = entry(
        id: 'deleted',
        type: TransactionType.youGave,
        amountPaise: 10000,
      ).copyWith(deletedAt: DateTime(2026, 5, 29));

      expect(calculator.balanceFor([deleted]), 0);
    });
  });
}
