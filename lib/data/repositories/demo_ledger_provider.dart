import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/ledger_models.dart';

final businessNameProvider = Provider<String>((ref) => 'Aarav Traders');
final activeBusinessIdProvider = Provider<String>((ref) => 'demo-business');
final activeBookIdProvider = Provider<String>((ref) => 'demo-book');
final ownerUpiIdProvider = Provider<String>((ref) => 'aaravtraders@upi');

final demoPartiesProvider = Provider<List<Party>>((ref) {
  final now = DateTime.now();
  return [
    Party(
      id: 'p1',
      businessId: 'demo-business',
      bookId: 'demo-book',
      name: 'Ravi Kirana Store',
      phone: '+919876543210',
      type: PartyType.customer,
      balancePaise: 1845000,
      creditLimitPaise: 2500000,
      tags: const ['weekly', 'priority'],
      notes: 'Prefers WhatsApp reminders after 6 PM',
      lastActivityAt: now.subtract(const Duration(hours: 3)),
      syncStatus: SyncStatus.synced,
    ),
    Party(
      id: 'p2',
      businessId: 'demo-business',
      bookId: 'demo-book',
      name: 'Meera Foods Supplier',
      phone: '+919812345678',
      type: PartyType.supplier,
      balancePaise: -920000,
      creditLimitPaise: 1500000,
      tags: const ['supplier', 'gst'],
      lastActivityAt: now.subtract(const Duration(days: 1)),
      syncStatus: SyncStatus.pending,
    ),
    Party(
      id: 'p3',
      businessId: 'demo-business',
      bookId: 'demo-book',
      name: 'Om Sai Cafe',
      phone: '+919700001111',
      type: PartyType.both,
      balancePaise: 125000,
      creditLimitPaise: 500000,
      tags: const ['upi'],
      lastActivityAt: now.subtract(const Duration(days: 4)),
      syncStatus: SyncStatus.failed,
    ),
  ];
});

final demoTransactionsProvider = Provider<List<LedgerTransaction>>((ref) {
  final now = DateTime.now();
  return [
    LedgerTransaction(
      id: 't1',
      businessId: 'demo-business',
      bookId: 'demo-book',
      partyId: 'p1',
      type: TransactionType.youGave,
      amountPaise: 1250000,
      occurredAt: now.subtract(const Duration(hours: 4)),
      paymentMode: PaymentMode.cash,
      note: 'Stock supplied on credit',
      syncStatus: SyncStatus.synced,
    ),
    LedgerTransaction(
      id: 't2',
      businessId: 'demo-business',
      bookId: 'demo-book',
      partyId: 'p1',
      type: TransactionType.youGot,
      amountPaise: 300000,
      occurredAt: now.subtract(const Duration(days: 1)),
      paymentMode: PaymentMode.upi,
      note: 'UPI received',
      syncStatus: SyncStatus.synced,
    ),
    LedgerTransaction(
      id: 't3',
      businessId: 'demo-business',
      bookId: 'demo-book',
      partyId: 'p2',
      type: TransactionType.purchase,
      amountPaise: 920000,
      occurredAt: now.subtract(const Duration(days: 2)),
      dueDate: now.add(const Duration(days: 5)),
      note: 'Monthly purchase bill',
      syncStatus: SyncStatus.pending,
    ),
  ];
});

final dashboardSummaryProvider = Provider<BusinessSummary>((ref) {
  final parties = ref.watch(demoPartiesProvider);
  final receivable = parties
      .where((party) => party.balancePaise > 0)
      .fold<int>(0, (sum, party) => sum + party.balancePaise);
  final payable = parties
      .where((party) => party.balancePaise < 0)
      .fold<int>(0, (sum, party) => sum + party.balancePaise.abs());

  return BusinessSummary(
    totalReceivablePaise: receivable,
    totalPayablePaise: payable,
    todayCollectionPaise: 300000,
    todayCreditGivenPaise: 1250000,
    overdueParties: 2,
    activeParties: parties.length,
    lowStockItems: 4,
    pendingSyncItems: parties
        .where((party) => party.syncStatus != SyncStatus.synced)
        .length,
  );
});

final reminderTemplatesProvider = Provider<List<ReminderTemplate>>((ref) {
  return const [
    ReminderTemplate(
      id: 'polite-en',
      name: 'Polite English',
      languageCode: 'en',
      body:
          'Hello {{name}}, {{amount}} is pending. Please make the payment when convenient. - {{business_name}}',
    ),
    ReminderTemplate(
      id: 'polite-hi',
      name: 'Polite Hindi',
      languageCode: 'hi',
      body:
          'Namaste {{name}}, {{amount}} pending hai. Kripya payment kar dein. - {{business_name}}',
    ),
    ReminderTemplate(
      id: 'hinglish',
      name: 'Hinglish',
      languageCode: 'hi-IN',
      body:
          'Hi {{name}}, aapka {{amount}} balance pending hai. Payment update kar dein. - {{business_name}}',
    ),
    ReminderTemplate(
      id: 'firm',
      name: 'Firm reminder',
      languageCode: 'en',
      body:
          'Reminder: {{amount}} is overdue. Please clear this payment today. - {{business_name}}',
      firmTone: true,
    ),
  ];
});
