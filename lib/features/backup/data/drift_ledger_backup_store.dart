import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart';
import '../application/backup_contracts.dart';

/// Logical snapshot boundary. Drift rows never leave this infrastructure file.
final class DriftLedgerBackupStore implements LedgerBackupStore {
  const DriftLedgerBackupStore(this.db);
  final LedgerDatabase db;

  @override
  Future<Result<Map<String, dynamic>>> exportLogicalSnapshot() async {
    try {
      final profileRows = await db.select(db.localProfiles).get();
      if (profileRows.length != 1)
        return const Failure(FailureCode.profileNotFound);
      return Success({
        'logicalSchemaVersion': 1,
        'sourceDriftSchemaVersion': db.schemaVersion,
        'localProfiles': profileRows.map((e) => e.toJson()).toList(),
        'accounts': (await db.select(db.accounts).get())
            .map((e) => e.toJson())
            .toList(),
        'categories': (await db.select(db.categories).get())
            .map((e) => e.toJson())
            .toList(),
        'projects': (await db.select(db.projects).get())
            .map((e) => e.toJson())
            .toList(),
        'budgets': (await db.select(db.budgets).get())
            .map((e) => e.toJson())
            .toList(),
        'transactions': (await db.select(db.bookkeepingTransactions).get())
            .map((e) => e.toJson())
            .toList(),
        'transfers': (await db.select(db.transfers).get())
            .map((e) => e.toJson())
            .toList(),
        'receiptAttachments': (await db.select(db.receiptAttachments).get())
            .map((e) => e.toJson())
            .toList(),
      });
    } on Object {
      return const Failure(FailureCode.backupGenerationFailed);
    }
  }

  @override
  Future<Result<void>> validateLogicalSnapshot(
    Map<String, dynamic> snapshot,
  ) async {
    try {
      _decode(snapshot);
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.restoreValidationFailed);
    }
  }

  @override
  Future<Result<void>> replaceLogicalSnapshot(
    Map<String, dynamic> snapshot,
  ) async {
    try {
      final decoded = _decode(snapshot);
      await db.transaction(() async {
        await db.delete(db.receiptAttachments).go();
        await db.delete(db.bookkeepingTransactions).go();
        await db.delete(db.transfers).go();
        await db.delete(db.budgets).go();
        await db.delete(db.projects).go();
        await db.delete(db.categories).go();
        await db.delete(db.accounts).go();
        await db.delete(db.localProfiles).go();
        await db.batch((batch) {
          batch.insertAll(
            db.localProfiles,
            decoded.profiles.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.accounts,
            decoded.accounts.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.categories,
            decoded.categories.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.projects,
            decoded.projects.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.budgets,
            decoded.budgets.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.bookkeepingTransactions,
            decoded.transactions.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.transfers,
            decoded.transfers.map((e) => e.toCompanion(true)),
          );
          batch.insertAll(
            db.receiptAttachments,
            decoded.receipts.map((e) => e.toCompanion(true)),
          );
        });
        await db.delete(db.syncOutbox).go();
        await db.delete(db.syncEntityStates).go();
        await db.delete(db.syncConflicts).go();
        await db.delete(db.syncReceiptSpoolEntries).go();
        await db.delete(db.syncAttachmentCleanup).go();
        await db.customStatement('DELETE FROM sync_initialization_entities');
        await (db.update(db.syncCursors)..where((e) => e.slot.equals(1))).write(
          const SyncCursorsCompanion(lastAppliedSequence: Value(0)),
        );
        final link = await (db.select(
          db.syncLinkStates,
        )..where((e) => e.slot.equals(1))).getSingle();
        await (db.update(
          db.syncLinkStates,
        )..where((e) => e.slot.equals(1))).write(
          SyncLinkStatesCompanion(
            syncEnabled: const Value(false),
            needsReconciliation: Value(link.cloudAccountId != null),
            state: Value(
              link.cloudAccountId == null ? 'unlinked' : 'needsReconciliation',
            ),
            updatedAtUtc: Value(DateTime.now().toUtc().microsecondsSinceEpoch),
          ),
        );
        await db.customStatement(
          "UPDATE sync_onboarding_state SET stage=CASE WHEN ? THEN "
          "'reconciling' ELSE 'idle' END, initialization_operation_id=NULL, "
          'paused=0, last_successful_sync_at_utc=NULL, updated_at_utc=? '
          'WHERE slot=1',
          [
            link.cloudAccountId != null ? 1 : 0,
            DateTime.now().toUtc().microsecondsSinceEpoch,
          ],
        );
      });
      return const Success(null);
    } on FormatException {
      return const Failure(FailureCode.restoreValidationFailed);
    } on Object {
      return const Failure(FailureCode.restoreFailed);
    }
  }

  _DecodedSnapshot _decode(Map<String, dynamic> json) {
    if (json['logicalSchemaVersion'] != 1) throw const FormatException();
    List<Map<String, dynamic>> rows(String key) {
      final value = json[key];
      if (value is! List || value.length > 100000)
        throw const FormatException();
      return value.map((e) {
        if (e is! Map<String, dynamic>) throw const FormatException();
        return e;
      }).toList();
    }

    final profiles = rows('localProfiles').map(LocalProfile.fromJson).toList();
    final accounts = rows('accounts').map(Account.fromJson).toList();
    final categories = rows('categories').map(Category.fromJson).toList();
    final projects = rows('projects').map(Project.fromJson).toList();
    final budgets = rows('budgets').map(Budget.fromJson).toList();
    final transactions = rows(
      'transactions',
    ).map(BookkeepingTransaction.fromJson).toList();
    final transfers = rows('transfers').map(Transfer.fromJson).toList();
    final receipts = rows(
      'receiptAttachments',
    ).map(ReceiptAttachment.fromJson).toList();
    if (profiles.length != 1) throw const FormatException();
    _unique(accounts.map((e) => e.id));
    _unique(categories.map((e) => e.id));
    _unique(projects.map((e) => e.id));
    _unique(budgets.map((e) => e.id));
    _unique(transactions.map((e) => e.id));
    _unique(transfers.map((e) => e.id));
    _unique(receipts.map((e) => e.id));
    _unique(receipts.map((e) => e.storageKey));
    _unique(receipts.map((e) => '${e.transactionId}:${e.position}'));
    final profileId = profiles.single.id;
    if ([
      ...accounts.map((e) => e.profileId),
      ...categories.map((e) => e.profileId),
      ...projects.map((e) => e.profileId),
      ...budgets.map((e) => e.profileId),
      ...transactions.map((e) => e.profileId),
      ...transfers.map((e) => e.profileId),
      ...receipts.map((e) => e.profileId),
    ].any((id) => id != profileId))
      throw const FormatException();
    final accountIds = accounts.map((e) => e.id).toSet();
    final categoryIds = categories.map((e) => e.id).toSet();
    final projectIds = projects.map((e) => e.id).toSet();
    final transactionIds = transactions.map((e) => e.id).toSet();
    if (transactions.any(
      (e) =>
          !accountIds.contains(e.accountId) ||
          !categoryIds.contains(e.categoryId) ||
          (e.projectId != null && !projectIds.contains(e.projectId)),
    ))
      throw const FormatException();
    if (transfers.any(
      (e) =>
          !accountIds.contains(e.sourceAccountId) ||
          !accountIds.contains(e.destinationAccountId),
    ))
      throw const FormatException();
    final accountById = {for (final e in accounts) e.id: e};
    final categoryById = {for (final e in categories) e.id: e};
    if (budgets.any(
      (e) => e.categoryId != null && !categoryIds.contains(e.categoryId),
    ))
      throw const FormatException();
    if (receipts.any((e) => !transactionIds.contains(e.transactionId)))
      throw const FormatException();
    final currencies = {'HKD', 'USD', 'EUR', 'GBP', 'JPY', 'THB', 'CNY'};
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final date = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final month = RegExp(r'^\d{4}-\d{2}$');
    if (!uuid.hasMatch(profileId) ||
        profiles.single.slot != 1 ||
        !currencies.contains(profiles.single.baseCurrencyCode) ||
        profiles.single.createdAtUtc > profiles.single.updatedAtUtc) {
      throw const FormatException();
    }
    if (accounts.any(
      (e) =>
          !uuid.hasMatch(e.id) ||
          e.name.trim().isEmpty ||
          e.name.length > 120 ||
          !{
            'cash',
            'bank',
            'creditCard',
            'eWallet',
            'other',
          }.contains(e.kind) ||
          !currencies.contains(e.currencyCode) ||
          !date.hasMatch(e.openingDate) ||
          e.createdAtUtc > e.updatedAtUtc,
    ))
      throw const FormatException();
    if (categories.any(
      (e) =>
          !uuid.hasMatch(e.id) ||
          e.name.trim().isEmpty ||
          e.name.length > 120 ||
          !{'income', 'expense'}.contains(e.kind) ||
          e.createdAtUtc > e.updatedAtUtc,
    ))
      throw const FormatException();
    if (projects.any(
      (e) =>
          !uuid.hasMatch(e.id) ||
          e.name.trim().isEmpty ||
          e.name.length > 120 ||
          (e.description?.length ?? 0) > 500 ||
          e.createdAtUtc > e.updatedAtUtc,
    ))
      throw const FormatException();
    if (budgets.any(
      (e) =>
          !uuid.hasMatch(e.id) ||
          e.name.trim().isEmpty ||
          e.amountMinorUnits < 0 ||
          !currencies.contains(e.currencyCode) ||
          !month.hasMatch(e.month) ||
          e.warningThresholdPercent < 1 ||
          e.warningThresholdPercent > 100 ||
          (e.categoryId != null &&
              categoryById[e.categoryId]?.kind != 'expense') ||
          e.createdAtUtc > e.updatedAtUtc,
    ))
      throw const FormatException();
    if (transactions.any((e) {
      final account = accountById[e.accountId];
      final category = categoryById[e.categoryId];
      return !uuid.hasMatch(e.id) ||
          e.amountMinorUnits <= 0 ||
          !{'income', 'expense'}.contains(e.kind) ||
          !currencies.contains(e.currencyCode) ||
          !date.hasMatch(e.businessDate) ||
          e.createdAtUtc > e.updatedAtUtc ||
          (e.deletedAtUtc != null && e.deletedAtUtc! < e.createdAtUtc) ||
          account?.currencyCode != e.currencyCode ||
          category?.kind != e.kind;
    }))
      throw const FormatException();
    if (transfers.any((e) {
      final source = accountById[e.sourceAccountId];
      final destination = accountById[e.destinationAccountId];
      return !uuid.hasMatch(e.id) ||
          e.sourceAccountId == e.destinationAccountId ||
          e.sourceMinorUnits <= 0 ||
          e.destinationMinorUnits <= 0 ||
          source?.currencyCode != e.sourceCurrencyCode ||
          destination?.currencyCode != e.destinationCurrencyCode ||
          (e.sourceCurrencyCode == e.destinationCurrencyCode &&
              e.sourceMinorUnits != e.destinationMinorUnits) ||
          !date.hasMatch(e.businessDate) ||
          e.createdAtUtc > e.updatedAtUtc;
    }))
      throw const FormatException();
    if (receipts.any(
      (e) =>
          !uuid.hasMatch(e.id) ||
          !RegExp(r'^[0-9a-f-]{36}\.jpg$').hasMatch(e.storageKey) ||
          e.mimeType != 'image/jpeg' ||
          e.byteSize < 1 ||
          e.byteSize > 10485760 ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(e.sha256Hex) ||
          e.position < 0 ||
          e.position > 4,
    ))
      throw const FormatException();
    return _DecodedSnapshot(
      profiles,
      accounts,
      categories,
      projects,
      budgets,
      transactions,
      transfers,
      receipts,
    );
  }

  void _unique(Iterable<String> ids) {
    final values = ids.toList();
    if (values.toSet().length != values.length) throw const FormatException();
  }
}

final class _DecodedSnapshot {
  const _DecodedSnapshot(
    this.profiles,
    this.accounts,
    this.categories,
    this.projects,
    this.budgets,
    this.transactions,
    this.transfers,
    this.receipts,
  );
  final List<LocalProfile> profiles;
  final List<Account> accounts;
  final List<Category> categories;
  final List<Project> projects;
  final List<Budget> budgets;
  final List<BookkeepingTransaction> transactions;
  final List<Transfer> transfers;
  final List<ReceiptAttachment> receipts;
}
