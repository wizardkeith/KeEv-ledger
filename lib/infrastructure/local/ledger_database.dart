import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/local_id.dart';

part 'ledger_database.g.dart';

/// Local identity is independent from any cloud account.
class LocalProfiles extends Table {
  IntColumn get slot => integer()();
  TextColumn get id => text().unique()();
  TextColumn get baseCurrencyCode => text()();
  IntColumn get createdAtUtc => integer()(); // UTC microseconds since epoch.
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {slot};

  @override
  List<String> get customConstraints => [
    'CHECK (slot = 1)',
    'CHECK (length(id) = 36)',
    "CHECK (base_currency_code IN ('HKD','USD','EUR','GBP','JPY','THB','CNY'))",
    'CHECK (created_at_utc <= updated_at_utc)',
  ];
}

/// Account balances are derived; there is no stored current balance.
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get currencyCode => text()();
  IntColumn get openingMinorUnits => integer()();
  TextColumn get openingDate => text()(); // ISO yyyy-MM-dd business date.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (length(trim(name)) BETWEEN 1 AND 120)',
    "CHECK (kind IN ('cash','bank','creditCard','eWallet','other'))",
    "CHECK (currency_code IN ('HKD','USD','EUR','GBP','JPY','THB','CNY'))",
    'CHECK (opening_minor_units >= -9223372036854775807)',
    'CHECK (length(opening_date) = 10)',
    'CHECK (created_at_utc <= updated_at_utc)',
  ];
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (length(trim(name)) BETWEEN 1 AND 120)',
    "CHECK (kind IN ('income','expense'))",
    'CHECK (created_at_utc <= updated_at_utc)',
  ];
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (length(trim(name)) BETWEEN 1 AND 120)',
    'CHECK (description IS NULL OR length(description) <= 500)',
    'CHECK (created_at_utc <= updated_at_utc)',
  ];
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  TextColumn get name => text()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get month => text()(); // ISO yyyy-MM business period.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get warningThresholdPercent =>
      integer().withDefault(const Constant(80))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (length(trim(name)) BETWEEN 1 AND 120)',
    'CHECK (amount_minor_units >= 0)',
    "CHECK (currency_code IN ('HKD','USD','EUR','GBP','JPY','THB','CNY'))",
    "CHECK (length(month) = 7 AND substr(month, 5, 1) = '-')",
    'CHECK (warning_threshold_percent BETWEEN 1 AND 100)',
    'CHECK (created_at_utc <= updated_at_utc)',
  ];
}

@TableIndex(
  name: 'history_profile_date_id',
  columns: {#profileId, #businessDate, #id},
)
class BookkeepingTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  TextColumn get kind => text()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get businessDate => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();
  IntColumn get deletedAtUtc => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    "CHECK (kind IN ('income','expense'))",
    'CHECK (amount_minor_units > 0)',
    'CHECK (length(business_date) = 10)',
    'CHECK (created_at_utc <= updated_at_utc)',
    'CHECK (deleted_at_utc IS NULL OR deleted_at_utc >= created_at_utc)',
  ];
}

@TableIndex(
  name: 'transfer_profile_date_id',
  columns: {#profileId, #businessDate, #id},
)
class Transfers extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  @ReferenceName('outgoingTransfers')
  TextColumn get sourceAccountId => text().references(Accounts, #id)();
  @ReferenceName('incomingTransfers')
  TextColumn get destinationAccountId => text().references(Accounts, #id)();
  IntColumn get sourceMinorUnits => integer()();
  TextColumn get sourceCurrencyCode => text()();
  IntColumn get destinationMinorUnits => integer()();
  TextColumn get destinationCurrencyCode => text()();
  TextColumn get businessDate => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();
  IntColumn get deletedAtUtc => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (source_account_id <> destination_account_id)',
    'CHECK (source_minor_units > 0 AND destination_minor_units > 0)',
    "CHECK (source_currency_code IN ('HKD','USD','EUR','GBP','JPY','THB','CNY'))",
    "CHECK (destination_currency_code IN ('HKD','USD','EUR','GBP','JPY','THB','CNY'))",
    'CHECK (source_currency_code <> destination_currency_code OR source_minor_units = destination_minor_units)',
    'CHECK (length(business_date) = 10)',
    'CHECK (created_at_utc <= updated_at_utc)',
    'CHECK (deleted_at_utc IS NULL OR deleted_at_utc >= created_at_utc)',
  ];
}

@TableIndex(
  name: 'receipt_transaction_position',
  columns: {#transactionId, #position},
  unique: true,
)
class ReceiptAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalProfiles, #id)();
  TextColumn get transactionId =>
      text().references(BookkeepingTransactions, #id)();
  TextColumn get storageKey => text().unique()();
  TextColumn get mimeType => text()();
  IntColumn get byteSize => integer()();
  TextColumn get sha256Hex => text()();
  IntColumn get position => integer()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (length(storage_key) BETWEEN 1 AND 160)',
    "CHECK (mime_type IN ('image/jpeg'))",
    'CHECK (byte_size BETWEEN 1 AND 10485760)',
    'CHECK (length(sha256_hex) = 64)',
    'CHECK (position BETWEEN 0 AND 4)',
  ];
}

class SyncLinkStates extends Table {
  IntColumn get slot => integer()();
  TextColumn get cloudAccountId => text().nullable()();
  TextColumn get state => text().withDefault(const Constant('unlinked'))();
  BoolColumn get syncEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get needsReconciliation =>
      boolean().withDefault(const Constant(false))();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {slot};
  @override
  List<String> get customConstraints => [
    'CHECK (slot = 1)',
    "CHECK (state IN ('unlinked','linked','needsReconciliation'))",
    'CHECK (cloud_account_id IS NULL OR length(cloud_account_id) = 36)',
  ];
}

class SyncDeviceStates extends Table {
  IntColumn get slot => integer()();
  TextColumn get deviceId => text().unique()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {slot};
  @override
  List<String> get customConstraints => [
    'CHECK (slot = 1)',
    'CHECK (length(device_id) = 36)',
  ];
}

class SyncCursors extends Table {
  IntColumn get slot => integer()();
  IntColumn get lastAppliedSequence =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {slot};
  @override
  List<String> get customConstraints => [
    'CHECK (slot = 1)',
    'CHECK (last_applied_sequence >= 0)',
  ];
}

class SyncEntityStates extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get serverVersion => integer()();
  IntColumn get serverRevision => integer()();

  @override
  Set<Column> get primaryKey => {entityType, entityId};
  @override
  List<String> get customConstraints => [
    'CHECK (server_version >= 1)',
    'CHECK (server_revision > 0)',
  ];
}

@TableIndex(name: 'sync_outbox_queue', columns: {#queueSequence})
@TableIndex(
  name: 'sync_outbox_entity_queue',
  columns: {#entityType, #entityId, #queueSequence},
)
class SyncOutbox extends Table {
  IntColumn get queueSequence => integer().autoIncrement()();
  TextColumn get mutationId => text().unique()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  IntColumn get baseServerVersion => integer().nullable()();
  TextColumn get payloadJson => text()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get lastAttemptAtUtc => integer().nullable()();
  IntColumn get nextAttemptAtUtc => integer().nullable()();
  TextColumn get lastFailureCode => text().nullable()();
  IntColumn get createdAtUtc => integer()();

  @override
  List<String> get customConstraints => [
    'CHECK (length(mutation_id) = 36)',
    "CHECK (operation IN ('create','update','delete'))",
    'CHECK (base_server_version IS NULL OR base_server_version >= 0)',
    "CHECK (state IN ('pending','processing','blocked'))",
    'CHECK (attempt_count >= 0)',
  ];
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get mutationId => text().nullable()();
  IntColumn get baseServerVersion => integer()();
  IntColumn get remoteServerVersion => integer()();
  IntColumn get remoteServerRevision => integer()();
  TextColumn get localCandidateJson => text()();
  TextColumn get remoteCandidateJson => text()();
  IntColumn get detectedAtUtc => integer()();
  TextColumn get status => text().withDefault(const Constant('unresolved'))();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'CHECK (length(id) = 36)',
    'CHECK (base_server_version >= 0)',
    'CHECK (remote_server_version >= 1)',
    'CHECK (remote_server_revision >= 1)',
    "CHECK (status IN ('unresolved','resolved'))",
  ];
}

/// Durable bytes retained solely for uncertain live receipt synchronization.
class SyncReceiptSpoolEntries extends Table {
  TextColumn get attachmentId => text()();
  TextColumn get storageKey => text()();
  TextColumn get sha256Hex => text()();
  IntColumn get byteSize => integer()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {attachmentId};
  @override
  List<String> get customConstraints => [
    'CHECK (length(attachment_id) = 36)',
    'CHECK (length(storage_key) BETWEEN 1 AND 160)',
    'CHECK (length(sha256_hex) = 64)',
    'CHECK (byte_size BETWEEN 1 AND 10485760)',
  ];
}

class SyncAttachmentCleanup extends Table {
  TextColumn get storagePath => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAtUtc => integer().nullable()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {storagePath};
}

class SyncOnboardingStates extends Table {
  @override
  String get tableName => 'sync_onboarding_state';
  IntColumn get slot => integer()();
  TextColumn get datasetGeneration => text().nullable()();
  TextColumn get stage => text().withDefault(const Constant('idle'))();
  TextColumn get initializationOperationId => text().nullable()();
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
  IntColumn get lastSuccessfulSyncAtUtc => integer().nullable()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column> get primaryKey => {slot};
  @override
  List<String> get customConstraints => [
    'CHECK (slot = 1)',
    'CHECK (dataset_generation IS NULL OR length(dataset_generation) = 36)',
    'CHECK (initialization_operation_id IS NULL OR length(initialization_operation_id) = 36)',
    "CHECK (stage IN ('idle','discovering','localToCloud','cloudToLocal','reconciling','active','failed'))",
  ];
}

class SyncInitializationEntities extends Table {
  @override
  String get tableName => 'sync_initialization_entities';
  IntColumn get ordinal => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {entityType, entityId},
  ];
  @override
  List<String> get customConstraints => ['CHECK (length(entity_id) = 36)'];
}

@DriftDatabase(
  tables: [
    LocalProfiles,
    Accounts,
    Categories,
    Projects,
    Budgets,
    BookkeepingTransactions,
    Transfers,
    ReceiptAttachments,
    SyncLinkStates,
    SyncDeviceStates,
    SyncCursors,
    SyncEntityStates,
    SyncOutbox,
    SyncConflicts,
    SyncReceiptSpoolEntries,
    SyncAttachmentCleanup,
    SyncOnboardingStates,
    SyncInitializationEntities,
  ],
)
class LedgerDatabase extends _$LedgerDatabase {
  LedgerDatabase(super.executor);

  /// Open a real app-documents SQLite file, never an in-memory product store.
  LedgerDatabase.openLocal() : super(driftDatabase(name: 'keev_ledger'));

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedSyncControlState();
    },
    onUpgrade: (m, from, to) async {
      if (from < 1 || from > 7 || to < 2 || to > 8 || to <= from) {
        throw StateError('Missing reviewed SQLite migration from $from to $to');
      }
      if (from == 1) {
        await m.createTable(accounts);
        await m.createTable(categories);
        if (to >= 4) {
          // The current transaction table references projects, so create that
          // parent before using the current table definition on a direct v1→v4
          // upgrade. Older targets retain their historical v2/v3 shape.
          await m.createTable(projects);
          await m.createTable(bookkeepingTransactions);
        } else {
          await customStatement('''
            CREATE TABLE bookkeeping_transactions (
              id TEXT NOT NULL,
              profile_id TEXT NOT NULL REFERENCES local_profiles(id),
              account_id TEXT NOT NULL REFERENCES accounts(id),
              category_id TEXT NOT NULL REFERENCES categories(id),
              kind TEXT NOT NULL,
              amount_minor_units INTEGER NOT NULL,
              currency_code TEXT NOT NULL,
              business_date TEXT NOT NULL,
              note TEXT NULL,
              created_at_utc INTEGER NOT NULL,
              updated_at_utc INTEGER NOT NULL,
              deleted_at_utc INTEGER NULL,
              PRIMARY KEY (id),
              CHECK (length(id) = 36),
              CHECK (kind IN ('income','expense')),
              CHECK (amount_minor_units > 0),
              CHECK (length(business_date) = 10),
              CHECK (created_at_utc <= updated_at_utc),
              CHECK (deleted_at_utc IS NULL OR deleted_at_utc >= created_at_utc)
            )
          ''');
        }
        await customStatement(
          'CREATE INDEX history_profile_date_id ON '
          'bookkeeping_transactions (profile_id, business_date, id)',
        );
      }
      if (from <= 2 && to >= 3) {
        await m.createTable(transfers);
        await m.createIndex(transferProfileDateId);
      }
      if (from < 4 && to >= 4) {
        if (from != 1) await m.createTable(projects);
        await m.createTable(budgets);
        if (from != 1) {
          await m.addColumn(
            bookkeepingTransactions,
            bookkeepingTransactions.projectId,
          );
        }
      }
      if (from < 5 && to >= 5) {
        await m.createTable(receiptAttachments);
        await m.createIndex(receiptTransactionPosition);
      }
      if (from < 6 && to >= 6) {
        await m.createTable(syncLinkStates);
        await m.createTable(syncDeviceStates);
        await m.createTable(syncCursors);
        await m.createTable(syncEntityStates);
        if (to == 6) {
          await _createV6RuntimeTables();
        } else {
          await m.createTable(syncOutbox);
          await m.createIndex(syncOutboxQueue);
          await m.createIndex(syncOutboxEntityQueue);
          await m.createTable(syncConflicts);
        }
        if (to < 8) await _seedSyncControlState(includeOnboarding: false);
      }
      if (from == 6 && to >= 7) {
        await customStatement(
          'ALTER TABLE sync_outbox RENAME TO sync_outbox_v6',
        );
        await m.createTable(syncOutbox);
        await m.createIndex(syncOutboxQueue);
        await m.createIndex(syncOutboxEntityQueue);
        await customStatement('''
          INSERT INTO sync_outbox (
            mutation_id, entity_type, entity_id, operation,
            base_server_version, payload_json, state, attempt_count,
            created_at_utc
          )
          SELECT mutation_id, entity_type, entity_id, operation,
            base_server_version, payload_json, state, 0, created_at_utc
          FROM sync_outbox_v6
          ORDER BY created_at_utc, mutation_id
        ''');
        await customStatement('DROP TABLE sync_outbox_v6');
        await customStatement(
          'ALTER TABLE sync_conflicts RENAME TO sync_conflicts_v6',
        );
        await m.createTable(syncConflicts);
        await customStatement('''
          INSERT INTO sync_conflicts (
            id, entity_type, entity_id, mutation_id, base_server_version,
            remote_server_version, remote_server_revision,
            local_candidate_json, remote_candidate_json, detected_at_utc,
            status
          )
          SELECT id, entity_type, entity_id, mutation_id,
            base_server_version, remote_server_version, 1,
            local_candidate_json, remote_candidate_json, detected_at_utc,
            status
          FROM sync_conflicts_v6
        ''');
        await customStatement('DROP TABLE sync_conflicts_v6');
        await m.createTable(syncReceiptSpoolEntries);
        await m.createTable(syncAttachmentCleanup);
      }
      if (from < 6 && to >= 7) {
        await m.createTable(syncReceiptSpoolEntries);
        await m.createTable(syncAttachmentCleanup);
      }
      if (from < 8 && to >= 8) {
        await m.createTable(syncOnboardingStates);
        await m.createTable(syncInitializationEntities);
        await customStatement('''
          INSERT OR IGNORE INTO sync_onboarding_state (
            slot, stage, paused, updated_at_utc
          ) VALUES (1, 'idle', 0, strftime('%s','now') * 1000000)
        ''');
        if (from == 7) {
          await customStatement('''
            UPDATE sync_link_states
            SET sync_enabled = 0,
                needs_reconciliation = CASE
                  WHEN cloud_account_id IS NULL THEN 0 ELSE 1 END,
                state = CASE
                  WHEN cloud_account_id IS NULL THEN 'unlinked'
                  ELSE 'needsReconciliation' END,
                updated_at_utc = strftime('%s','now') * 1000000
          ''');
          await customStatement('''
            UPDATE sync_onboarding_state
            SET stage = 'reconciling'
            WHERE slot = 1 AND EXISTS (
              SELECT 1 FROM sync_link_states
              WHERE slot = 1 AND cloud_account_id IS NOT NULL
            )
          ''');
        }
        await _seedSyncControlState();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedSyncControlState({bool includeOnboarding = true}) async {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    await into(syncLinkStates).insert(
      SyncLinkStatesCompanion.insert(slot: const Value(1), updatedAtUtc: now),
      mode: InsertMode.insertOrIgnore,
    );
    await into(syncDeviceStates).insert(
      SyncDeviceStatesCompanion.insert(
        slot: const Value(1),
        deviceId: SecureUuidV4Generator().generate().value,
        createdAtUtc: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    await into(syncCursors).insert(
      SyncCursorsCompanion.insert(slot: const Value(1)),
      mode: InsertMode.insertOrIgnore,
    );
    if (includeOnboarding) {
      await customStatement(
        '''
        INSERT OR IGNORE INTO sync_onboarding_state (
          slot, stage, paused, updated_at_utc
        ) VALUES (1, 'idle', 0, ?)
      ''',
        [now],
      );
    }
  }

  Future<void> _createV6RuntimeTables() async {
    await customStatement('''
      CREATE TABLE sync_outbox (
        mutation_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        base_server_version INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        state TEXT NOT NULL DEFAULT 'pending',
        created_at_utc INTEGER NOT NULL,
        PRIMARY KEY (mutation_id),
        CHECK (length(mutation_id) = 36),
        CHECK (operation IN ('create','update','delete')),
        CHECK (base_server_version >= 0),
        CHECK (state IN ('pending','processing','blocked'))
      )
    ''');
    await customStatement(
      'CREATE INDEX sync_outbox_created ON '
      'sync_outbox (created_at_utc, mutation_id)',
    );
    await customStatement('''
      CREATE TABLE sync_conflicts (
        id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        mutation_id TEXT NULL,
        base_server_version INTEGER NOT NULL,
        remote_server_version INTEGER NOT NULL,
        local_candidate_json TEXT NOT NULL,
        remote_candidate_json TEXT NOT NULL,
        detected_at_utc INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'unresolved',
        PRIMARY KEY (id),
        CHECK (length(id) = 36),
        CHECK (base_server_version >= 0),
        CHECK (remote_server_version >= 1),
        CHECK (status IN ('unresolved','resolved'))
      )
    ''');
  }
}
