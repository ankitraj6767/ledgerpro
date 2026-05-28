import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LocalBusinesses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerName => text()();
  TextColumn get phone => text()();
  TextColumn get address => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get upiId => text().nullable()();
  TextColumn get defaultLanguage => text().withDefault(const Constant('en'))();
  TextColumn get defaultCurrency => text().withDefault(const Constant('INR'))();
  DateTimeColumn get financialYearStart => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalBooks extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(LocalBusinesses, #id)();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalParties extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(LocalBusinesses, #id)();
  TextColumn get bookId => text().references(LocalBooks, #id)();
  TextColumn get type => text().withDefault(const Constant('customer'))();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get alternatePhone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get gstin => text().nullable()();
  IntColumn get openingBalancePaise =>
      integer().withDefault(const Constant(0))();
  IntColumn get cachedBalancePaise =>
      integer().withDefault(const Constant(0))();
  IntColumn get creditLimitPaise => integer().withDefault(const Constant(0))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  TextColumn get profileImagePath => text().nullable()();
  TextColumn get searchIndex => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalLedgerTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(LocalBusinesses, #id)();
  TextColumn get bookId => text().references(LocalBooks, #id)();
  TextColumn get partyId => text().references(LocalParties, #id)();
  TextColumn get type => text()();
  IntColumn get amountPaise => integer()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get paymentMode => text().withDefault(const Constant('cash'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get reminderDate => dateTime().nullable()();
  TextColumn get attachmentPath => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  TextColumn get reversalOfTransactionId => text().nullable()();
  BoolColumn get isReversal => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPendingMutations extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAuditLogEntries extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get actorId => text().nullable()();
  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalReminders extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get bookId => text().nullable()();
  TextColumn get partyId => text()();
  TextColumn get channel => text().withDefault(const Constant('whatsapp'))();
  TextColumn get message => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalBusinesses,
    LocalBooks,
    LocalParties,
    LocalLedgerTransactions,
    LocalPendingMutations,
    LocalAuditLogEntries,
    LocalReminders,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<List<LocalParty>> searchParties(String query) {
    final normalized = query.trim().toLowerCase();
    final like = '%$normalized%';
    return (select(localParties)
          ..where(
            (party) => party.deletedAt.isNull() & party.searchIndex.like(like),
          )
          ..orderBy([
            (_) => OrderingTerm(
              expression: const CustomExpression<int>(
                'abs(cached_balance_paise)',
              ),
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<void> queueMutation(LocalPendingMutationsCompanion mutation) {
    return into(localPendingMutations).insertOnConflictUpdate(mutation);
  }

  Future<List<LocalPendingMutation>> pendingMutationsInSyncOrder() {
    final priority = CustomExpression<int>(
      "case entity_type when 'business' then 0 when 'book' then 1 when 'party' then 2 when 'transaction' then 3 when 'attachment' then 4 when 'reminder' then 5 else 6 end",
    );
    return (select(localPendingMutations)
          ..where((item) => item.status.isIn(['pending', 'failed']))
          ..orderBy([
            (_) => OrderingTerm(expression: priority),
            (item) => OrderingTerm(expression: item.createdAt),
          ]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ledgerpro_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
