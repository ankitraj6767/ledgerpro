import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/money/money.dart';
import '../../shared/models/ledger_models.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepository(Supabase.instance.client);
});

final ledgerWorkspaceProvider = FutureProvider<LedgerWorkspace>((ref) async {
  return ref.watch(ledgerRepositoryProvider).ensureWorkspace();
});

final partiesProvider = FutureProvider<List<Party>>((ref) async {
  final workspace = await ref.watch(ledgerWorkspaceProvider.future);
  return ref.watch(ledgerRepositoryProvider).fetchParties(workspace.bookId);
});

final ledgerTransactionsProvider = FutureProvider<List<LedgerTransaction>>((
  ref,
) async {
  final workspace = await ref.watch(ledgerWorkspaceProvider.future);
  return ref
      .watch(ledgerRepositoryProvider)
      .fetchTransactions(workspace.bookId);
});

final businessSummaryProvider = FutureProvider<BusinessSummary>((ref) async {
  final parties = await ref.watch(partiesProvider.future);
  final transactions = await ref.watch(ledgerTransactionsProvider.future);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final receivable = parties
      .where((party) => party.balancePaise > 0)
      .fold<int>(0, (sum, party) => sum + party.balancePaise);
  final payable = parties
      .where((party) => party.balancePaise < 0)
      .fold<int>(0, (sum, party) => sum + party.balancePaise.abs());
  final todayTransactions = transactions.where(
    (transaction) => transaction.occurredAt.isAfter(todayStart),
  );

  return BusinessSummary(
    totalReceivablePaise: receivable,
    totalPayablePaise: payable,
    todayCollectionPaise: todayTransactions
        .where((transaction) => transaction.type == TransactionType.youGot)
        .fold<int>(0, (sum, transaction) => sum + transaction.amountPaise),
    todayCreditGivenPaise: todayTransactions
        .where((transaction) => transaction.type == TransactionType.youGave)
        .fold<int>(0, (sum, transaction) => sum + transaction.amountPaise),
    overdueParties: transactions
        .where(
          (transaction) =>
              transaction.dueDate != null &&
              transaction.dueDate!.isBefore(todayStart),
        )
        .map((transaction) => transaction.partyId)
        .toSet()
        .length,
    activeParties: parties.length,
    lowStockItems: 0,
    pendingSyncItems:
        parties.where((party) => party.syncStatus != SyncStatus.synced).length +
        transactions
            .where((transaction) => transaction.syncStatus != SyncStatus.synced)
            .length,
  );
});

final businessNameProvider = FutureProvider<String>((ref) async {
  final workspace = await ref.watch(ledgerWorkspaceProvider.future);
  return workspace.businessName;
});

/// Full business profile (name, owner, phone, UPI id, gstin) for the active
/// business. Used for payment QR generation and statements.
final businessProfileProvider = FutureProvider<BusinessProfile>((ref) async {
  final workspace = await ref.watch(ledgerWorkspaceProvider.future);
  return ref
      .watch(ledgerRepositoryProvider)
      .fetchBusinessProfile(workspace.businessId);
});

/// A single party by id, sourced from the real parties list.
final partyByIdProvider = Provider.family<Party?, String>((ref, partyId) {
  final parties = ref.watch(partiesProvider).value ?? const <Party>[];
  for (final party in parties) {
    if (party.id == partyId) return party;
  }
  return null;
});

/// Transactions for a single party, derived from the real transactions list.
final partyTransactionsProvider =
    Provider.family<List<LedgerTransaction>, String>((ref, partyId) {
      final transactions =
          ref.watch(ledgerTransactionsProvider).value ??
          const <LedgerTransaction>[];
      return transactions
          .where((entry) => entry.partyId == partyId)
          .toList();
    });

class LedgerWorkspace {
  const LedgerWorkspace({
    required this.businessId,
    required this.bookId,
    required this.businessName,
  });

  final String businessId;
  final String bookId;
  final String businessName;
}

class LedgerRepository {
  const LedgerRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in again to continue.');
    }
    return user.id;
  }

  Future<LedgerWorkspace> ensureWorkspace() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in again to continue.');
    }

    final row = await _client
        .rpc(
          'ensure_ledger_workspace',
          params: {
            'p_email': user.email,
            'p_full_name': user.userMetadata?['full_name']?.toString(),
          },
        )
        .single();

    return LedgerWorkspace(
      businessId: row['business_id'] as String,
      bookId: row['book_id'] as String,
      businessName: row['business_name'] as String,
    );
  }

  Future<List<Party>> fetchParties(String bookId) async {
    final rows = await _client
        .from('parties')
        .select()
        .eq('book_id', bookId)
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: false);

    return rows
        .map<Party>((row) => _partyFromRow(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<LedgerTransaction>> fetchTransactions(String bookId) async {
    final rows = await _client
        .from('transactions')
        .select()
        .eq('book_id', bookId)
        .isFilter('deleted_at', null)
        .order('occurred_at', ascending: false)
        .limit(50);

    return rows
        .map<LedgerTransaction>(
          (row) => _transactionFromRow(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<void> createParty({
    required PartyType type,
    required String name,
    required String phone,
    required int openingBalancePaise,
    required int creditLimitPaise,
    required List<String> tags,
    String? notes,
    String? upiId,
  }) async {
    final workspace = await ensureWorkspace();
    final userId = _userId;

    await _client.from('parties').insert({
      'business_id': workspace.businessId,
      'book_id': workspace.bookId,
      'kind': _partyTypeToDb(type),
      'name': name,
      'phone': phone.isEmpty ? null : phone,
      'upi_id': upiId?.trim().isEmpty ?? true ? null : upiId!.trim(),
      'opening_balance_paise': openingBalancePaise,
      'cached_balance_paise': openingBalancePaise,
      'credit_limit_paise': creditLimitPaise,
      'tags': tags,
      'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
      'created_by': userId,
      'updated_by': userId,
    });
  }

  Future<void> updateParty({
    required String partyId,
    required PartyType type,
    required String name,
    required String phone,
    required int creditLimitPaise,
    required List<String> tags,
    String? notes,
    String? upiId,
  }) async {
    final userId = _userId;
    await _client
        .from('parties')
        .update({
          'kind': _partyTypeToDb(type),
          'name': name,
          'phone': phone.isEmpty ? null : phone,
          'upi_id': upiId?.trim().isEmpty ?? true ? null : upiId!.trim(),
          'credit_limit_paise': creditLimitPaise,
          'tags': tags,
          'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
          'updated_by': userId,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', partyId);
  }

  /// Soft-deletes a party (hard delete is blocked by a DB trigger). The row is
  /// retained for audit but excluded from all fetches via the deleted_at filter.
  Future<void> softDeleteParty(String partyId) async {
    final userId = _userId;
    await _client
        .from('parties')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_by': userId,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', partyId);
  }

  Future<BusinessProfile> fetchBusinessProfile(String businessId) async {
    final row = await _client
        .from('businesses')
        .select('id, business_name, owner_name, phone, upi_id, gstin, address')
        .eq('id', businessId)
        .single();

    return BusinessProfile(
      id: row['id'] as String,
      name: row['business_name']?.toString() ?? 'LedgerPro Business',
      ownerName: row['owner_name']?.toString(),
      phone: row['phone']?.toString(),
      upiId: row['upi_id']?.toString(),
      gstin: row['gstin']?.toString(),
      address: row['address']?.toString(),
    );
  }

  Future<void> createTransaction({
    required String partyId,
    required TransactionType type,
    required int amountPaise,
    required PaymentMode paymentMode,
    String? note,
    DateTime? dueDate,
  }) async {
    final workspace = await ensureWorkspace();
    final userId = _userId;
    final balanceDelta = type == TransactionType.youGot
        ? -amountPaise
        : amountPaise;

    await _client.rpc(
      'create_ledger_transaction',
      params: {
        'p_business_id': workspace.businessId,
        'p_book_id': workspace.bookId,
        'p_party_id': partyId,
        'p_type': _transactionTypeToDb(type),
        'p_amount_paise': amountPaise,
        'p_payment_mode': _paymentModeToDb(paymentMode),
        'p_note': note?.trim().isEmpty ?? true ? null : note!.trim(),
        'p_due_date': dueDate?.toIso8601String().split('T').first,
        'p_balance_delta_paise': balanceDelta,
        'p_actor_id': userId,
      },
    );
  }

  Party _partyFromRow(Map<String, dynamic> row) {
    return Party(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      bookId: row['book_id'] as String,
      name: row['name'] as String,
      phone: row['phone']?.toString() ?? '',
      type: _partyTypeFromDb(row['kind'] as String?),
      balancePaise: (row['cached_balance_paise'] as num?)?.toInt() ?? 0,
      creditLimitPaise: (row['credit_limit_paise'] as num?)?.toInt() ?? 0,
      tags:
          (row['tags'] as List?)?.map((tag) => tag.toString()).toList() ??
          const [],
      alternatePhone: row['alternate_phone']?.toString(),
      address: row['address']?.toString(),
      gstin: row['gstin']?.toString(),
      upiId: row['upi_id']?.toString(),
      notes: row['notes']?.toString(),
      profileImageUrl: row['profile_image_path']?.toString(),
      lastActivityAt: DateTime.tryParse(row['updated_at']?.toString() ?? ''),
      syncStatus: _syncStatusFromDb(row['sync_status'] as String?),
      deletedAt: DateTime.tryParse(row['deleted_at']?.toString() ?? ''),
    );
  }

  LedgerTransaction _transactionFromRow(Map<String, dynamic> row) {
    return LedgerTransaction(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      bookId: row['book_id'] as String,
      partyId: row['party_id'] as String,
      type: _transactionTypeFromDb(row['type'] as String?),
      amountPaise: (row['amount_paise'] as num).toInt(),
      occurredAt:
          DateTime.tryParse(row['occurred_at']?.toString() ?? '') ??
          DateTime.now(),
      paymentMode: _paymentModeFromDb(row['payment_mode'] as String?),
      note: row['note']?.toString(),
      dueDate: DateTime.tryParse(row['due_date']?.toString() ?? ''),
      reminderDate: DateTime.tryParse(row['reminder_date']?.toString() ?? ''),
      attachmentPath: row['attachment_path']?.toString(),
      createdBy: row['created_by']?.toString(),
      updatedBy: row['updated_by']?.toString(),
      reversalOfTransactionId: row['original_transaction_id']?.toString(),
      isReversal: row['is_reversal'] == true,
      syncStatus: _syncStatusFromDb(row['sync_status'] as String?),
      deletedAt: DateTime.tryParse(row['deleted_at']?.toString() ?? ''),
    );
  }

  static int parsePaise(String input) => Money.fromRupeeString(input).paise;

  static String _partyTypeToDb(PartyType value) => switch (value) {
    PartyType.customer => 'customer',
    PartyType.supplier => 'supplier',
    PartyType.both => 'both',
  };

  static PartyType _partyTypeFromDb(String? value) => switch (value) {
    'supplier' => PartyType.supplier,
    'both' => PartyType.both,
    _ => PartyType.customer,
  };

  static String _transactionTypeToDb(TransactionType value) => switch (value) {
    TransactionType.youGave => 'you_gave',
    TransactionType.youGot => 'you_got',
    TransactionType.sale => 'sale',
    TransactionType.purchase => 'purchase',
    TransactionType.expense => 'expense',
    TransactionType.refund => 'refund',
    TransactionType.adjustment => 'adjustment',
    TransactionType.discountWriteOff => 'discount_write_off',
    TransactionType.openingBalance => 'opening_balance',
  };

  static TransactionType _transactionTypeFromDb(String? value) =>
      switch (value) {
        'you_got' => TransactionType.youGot,
        'sale' => TransactionType.sale,
        'purchase' => TransactionType.purchase,
        'expense' => TransactionType.expense,
        'refund' => TransactionType.refund,
        'adjustment' => TransactionType.adjustment,
        'discount_write_off' => TransactionType.discountWriteOff,
        'opening_balance' => TransactionType.openingBalance,
        _ => TransactionType.youGave,
      };

  static String _paymentModeToDb(PaymentMode value) => value.name;

  static PaymentMode _paymentModeFromDb(String? value) => switch (value) {
    'upi' => PaymentMode.upi,
    'bank' => PaymentMode.bank,
    'card' => PaymentMode.card,
    'cheque' => PaymentMode.cheque,
    'wallet' => PaymentMode.wallet,
    'other' => PaymentMode.other,
    _ => PaymentMode.cash,
  };

  static SyncStatus _syncStatusFromDb(String? value) => switch (value) {
    'pending' => SyncStatus.pending,
    'failed' => SyncStatus.failed,
    _ => SyncStatus.synced,
  };
}
