import '../../shared/models/ledger_models.dart';

class BalanceCalculator {
  const BalanceCalculator();

  int signedAmount(LedgerTransaction transaction) {
    final amount = transaction.amountPaise.abs();
    final sign = switch (transaction.type) {
      TransactionType.youGave => 1,
      TransactionType.sale => 1,
      TransactionType.openingBalance => 1,
      TransactionType.adjustment => 1,
      TransactionType.youGot => -1,
      TransactionType.purchase => -1,
      TransactionType.expense => -1,
      TransactionType.refund => -1,
      TransactionType.discountWriteOff => -1,
    };
    final signed = amount * sign;
    return transaction.isReversal ? -signed : signed;
  }

  int balanceFor(Iterable<LedgerTransaction> transactions) {
    return transactions
        .where((entry) => entry.deletedAt == null)
        .fold<int>(0, (total, entry) => total + signedAmount(entry));
  }

  LedgerTransaction reversalFor(
    LedgerTransaction transaction, {
    required String reversalId,
    required DateTime occurredAt,
    String? actorId,
  }) {
    return transaction.copyWith(
      id: reversalId,
      occurredAt: occurredAt,
      isReversal: true,
      reversalOfTransactionId: transaction.id,
      createdBy: actorId ?? transaction.createdBy,
      updatedBy: actorId ?? transaction.updatedBy,
      note: 'Reversal: ${transaction.note ?? transaction.type.name}',
      syncStatus: SyncStatus.pending,
      deletedAt: null,
    );
  }
}
