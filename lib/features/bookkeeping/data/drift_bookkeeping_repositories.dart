import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' show SqliteException;

import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart' as sql;
import '../../sync/data/drift_sync_mutation_capture.dart';
import '../../sync/domain/sync_protocol.dart';
import '../domain/bookkeeping.dart' as domain;

DateTime _utc(int value) =>
    DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);

Failure<T> _storeFailure<T>(SqliteException error) => Failure(
  error.resultCode == 19 && error.message.contains('UNIQUE constraint failed')
      ? FailureCode.recordAlreadyExists
      : FailureCode.localStoreUnavailable,
);

domain.Account _account(sql.Account row) => domain.Account(
  id: LocalId(row.id),
  profileId: LocalId(row.profileId),
  name: row.name,
  kind: domain.AccountKind.values.byName(row.kind),
  currency: Currency.fromCode(row.currencyCode),
  openingBalance: Money.fromMinorUnits(
    Currency.fromCode(row.currencyCode),
    row.openingMinorUnits,
  ),
  openingDate: domain.BusinessDate(row.openingDate),
  isArchived: row.isArchived,
  createdAtUtc: _utc(row.createdAtUtc),
  updatedAtUtc: _utc(row.updatedAtUtc),
);

domain.Category _category(sql.Category row) => domain.Category(
  id: LocalId(row.id),
  profileId: LocalId(row.profileId),
  name: row.name,
  kind: domain.EntryKind.values.byName(row.kind),
  isArchived: row.isArchived,
  createdAtUtc: _utc(row.createdAtUtc),
  updatedAtUtc: _utc(row.updatedAtUtc),
);

domain.BookkeepingEntry _entry(sql.BookkeepingTransaction row) =>
    domain.BookkeepingEntry(
      id: LocalId(row.id),
      profileId: LocalId(row.profileId),
      accountId: LocalId(row.accountId),
      categoryId: LocalId(row.categoryId),
      projectId: row.projectId == null ? null : LocalId(row.projectId!),
      kind: domain.EntryKind.values.byName(row.kind),
      amount: Money.fromMinorUnits(
        Currency.fromCode(row.currencyCode),
        row.amountMinorUnits,
      ),
      businessDate: domain.BusinessDate(row.businessDate),
      note: row.note,
      createdAtUtc: _utc(row.createdAtUtc),
      updatedAtUtc: _utc(row.updatedAtUtc),
      deletedAtUtc: row.deletedAtUtc == null ? null : _utc(row.deletedAtUtc!),
    );

final class DriftAccountRepository implements domain.AccountRepository {
  DriftAccountRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<domain.Account>> create(domain.Account account) async {
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.accounts)
            .insert(
              sql.AccountsCompanion.insert(
                id: account.id.value,
                profileId: account.profileId.value,
                name: account.name,
                kind: account.kind.name,
                currencyCode: account.currency.code,
                openingMinorUnits: account.openingBalance.minorUnits,
                openingDate: account.openingDate.value,
                isArchived: drift.Value(account.isArchived),
                createdAtUtc: account.createdAtUtc.microsecondsSinceEpoch,
                updatedAtUtc: account.updatedAtUtc.microsecondsSinceEpoch,
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.account,
          entityId: account.id.value,
          operation: SyncOperation.create,
          payload: SyncPayloads.account(
            profileId: account.profileId.value,
            name: account.name,
            kind: account.kind.name,
            currencyCode: account.currency.code,
            openingMinorUnits: account.openingBalance.minorUnits,
            openingDate: account.openingDate.value,
            isArchived: account.isArchived,
            createdAt: account.createdAtUtc,
            updatedAt: account.updatedAtUtc,
          ),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
      });
      return Success(account);
    } on SqliteException catch (error) {
      return _storeFailure(error);
    }
  }

  @override
  Future<Result<domain.Account?>> get(
    LocalId profileId,
    LocalId accountId,
  ) async {
    try {
      final row =
          await (_db.select(_db.accounts)..where(
                (a) =>
                    a.id.equals(accountId.value) &
                    a.profileId.equals(profileId.value),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _account(row));
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<domain.Account>>> list(
    LocalId profileId, {
    bool includeArchived = false,
  }) async {
    try {
      final query = _db.select(_db.accounts)
        ..where(
          (a) =>
              a.profileId.equals(profileId.value) &
              (includeArchived
                  ? const drift.Constant(true)
                  : a.isArchived.equals(false)),
        )
        ..orderBy([
          (a) => drift.OrderingTerm.asc(a.createdAtUtc),
          (a) => drift.OrderingTerm.asc(a.id),
        ]);
      return Success((await query.get()).map(_account).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.Account>> archive(
    LocalId profileId,
    LocalId accountId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        final count =
            await (_db.update(_db.accounts)..where(
                  (a) =>
                      a.id.equals(accountId.value) &
                      a.profileId.equals(profileId.value) &
                      a.createdAtUtc.isSmallerOrEqualValue(
                        nowUtc.microsecondsSinceEpoch,
                      ),
                ))
                .write(
                  sql.AccountsCompanion(
                    isArchived: const drift.Value(true),
                    updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                  ),
                );
        if (count == 0) return const Failure(FailureCode.accountNotFound);
        final result = await get(profileId, accountId);
        if (result is Success<domain.Account?>) {
          final account = result.value!;
          final captured = await _sync.capture(
            entityType: SyncEntityType.account,
            entityId: account.id.value,
            operation: SyncOperation.update,
            payload: SyncPayloads.account(
              profileId: account.profileId.value,
              name: account.name,
              kind: account.kind.name,
              currencyCode: account.currency.code,
              openingMinorUnits: account.openingBalance.minorUnits,
              openingDate: account.openingDate.value,
              isArchived: true,
              createdAt: account.createdAtUtc,
              updatedAt: account.updatedAtUtc,
            ),
          );
          if (captured is Failure<bool>)
            throw StateError('sync capture failed');
          return Success(account);
        }
        return const Failure(FailureCode.localStoreUnavailable);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

final class DriftCategoryRepository implements domain.CategoryRepository {
  DriftCategoryRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<domain.Category>> create(domain.Category category) async {
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.categories)
            .insert(
              sql.CategoriesCompanion.insert(
                id: category.id.value,
                profileId: category.profileId.value,
                name: category.name,
                kind: category.kind.name,
                isArchived: drift.Value(category.isArchived),
                createdAtUtc: category.createdAtUtc.microsecondsSinceEpoch,
                updatedAtUtc: category.updatedAtUtc.microsecondsSinceEpoch,
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.category,
          entityId: category.id.value,
          operation: SyncOperation.create,
          payload: SyncPayloads.category(
            profileId: category.profileId.value,
            name: category.name,
            kind: category.kind.name,
            isArchived: category.isArchived,
            createdAt: category.createdAtUtc,
            updatedAt: category.updatedAtUtc,
          ),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
      });
      return Success(category);
    } on SqliteException catch (error) {
      return _storeFailure(error);
    }
  }

  @override
  Future<Result<domain.Category?>> get(
    LocalId profileId,
    LocalId categoryId,
  ) async {
    try {
      final row =
          await (_db.select(_db.categories)..where(
                (c) =>
                    c.id.equals(categoryId.value) &
                    c.profileId.equals(profileId.value),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _category(row));
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<domain.Category>>> list(
    LocalId profileId, {
    domain.EntryKind? kind,
    bool includeArchived = false,
  }) async {
    try {
      final query = _db.select(_db.categories)
        ..where(
          (c) =>
              c.profileId.equals(profileId.value) &
              (includeArchived
                  ? const drift.Constant(true)
                  : c.isArchived.equals(false)) &
              (kind == null
                  ? const drift.Constant(true)
                  : c.kind.equals(kind.name)),
        )
        ..orderBy([
          (c) => drift.OrderingTerm.asc(c.name),
          (c) => drift.OrderingTerm.asc(c.id),
        ]);
      return Success((await query.get()).map(_category).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.Category>> archive(
    LocalId profileId,
    LocalId categoryId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        final count =
            await (_db.update(_db.categories)..where(
                  (c) =>
                      c.id.equals(categoryId.value) &
                      c.profileId.equals(profileId.value) &
                      c.createdAtUtc.isSmallerOrEqualValue(
                        nowUtc.microsecondsSinceEpoch,
                      ),
                ))
                .write(
                  sql.CategoriesCompanion(
                    isArchived: const drift.Value(true),
                    updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                  ),
                );
        if (count == 0) return const Failure(FailureCode.categoryNotFound);
        final result = await get(profileId, categoryId);
        if (result is Success<domain.Category?>) {
          final category = result.value!;
          final captured = await _sync.capture(
            entityType: SyncEntityType.category,
            entityId: category.id.value,
            operation: SyncOperation.update,
            payload: SyncPayloads.category(
              profileId: category.profileId.value,
              name: category.name,
              kind: category.kind.name,
              isArchived: true,
              createdAt: category.createdAtUtc,
              updatedAt: category.updatedAtUtc,
            ),
          );
          if (captured is Failure<bool>)
            throw StateError('sync capture failed');
          return Success(category);
        }
        return const Failure(FailureCode.localStoreUnavailable);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

final class DriftEntryRepository implements domain.EntryRepository {
  DriftEntryRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<domain.BookkeepingEntry>> create(
    domain.BookkeepingEntry entry,
  ) async {
    // The reads and insert share a SQLite transaction so archives cannot race validation.
    try {
      return await _db.transaction(() async {
        final account =
            await (_db.select(_db.accounts)..where(
                  (a) =>
                      a.id.equals(entry.accountId.value) &
                      a.profileId.equals(entry.profileId.value),
                ))
                .getSingleOrNull();
        if (account == null)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.accountNotFound,
          );
        if (account.isArchived)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.accountArchived,
          );
        final category =
            await (_db.select(_db.categories)..where(
                  (c) =>
                      c.id.equals(entry.categoryId.value) &
                      c.profileId.equals(entry.profileId.value),
                ))
                .getSingleOrNull();
        if (category == null)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.categoryNotFound,
          );
        if (category.isArchived)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.categoryArchived,
          );
        if (category.kind != entry.kind.name)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.categoryKindMismatch,
          );
        if (entry.projectId != null) {
          final project =
              await (_db.select(_db.projects)..where(
                    (p) =>
                        p.id.equals(entry.projectId!.value) &
                        p.profileId.equals(entry.profileId.value),
                  ))
                  .getSingleOrNull();
          if (project == null) {
            return const Failure<domain.BookkeepingEntry>(
              FailureCode.projectNotFound,
            );
          }
          if (project.isArchived) {
            return const Failure<domain.BookkeepingEntry>(
              FailureCode.projectArchived,
            );
          }
        }
        if (account.currencyCode != entry.amount.currency.code)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.currencyMismatch,
          );
        if (entry.businessDate.value.compareTo(account.openingDate) < 0)
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.dateBeforeOpening,
          );
        await _db
            .into(_db.bookkeepingTransactions)
            .insert(
              sql.BookkeepingTransactionsCompanion.insert(
                id: entry.id.value,
                profileId: entry.profileId.value,
                accountId: entry.accountId.value,
                categoryId: entry.categoryId.value,
                projectId: drift.Value(entry.projectId?.value),
                kind: entry.kind.name,
                amountMinorUnits: entry.amount.minorUnits,
                currencyCode: entry.amount.currency.code,
                businessDate: entry.businessDate.value,
                note: drift.Value(entry.note),
                createdAtUtc: entry.createdAtUtc.microsecondsSinceEpoch,
                updatedAtUtc: entry.updatedAtUtc.microsecondsSinceEpoch,
                deletedAtUtc: drift.Value(
                  entry.deletedAtUtc?.microsecondsSinceEpoch,
                ),
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.transaction,
          entityId: entry.id.value,
          operation: SyncOperation.create,
          payload: _entryPayload(entry),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success<domain.BookkeepingEntry>(entry);
      });
    } on SqliteException catch (error) {
      return _storeFailure(error);
    }
  }

  @override
  Future<Result<domain.BookkeepingEntry?>> get(
    LocalId profileId,
    LocalId entryId,
  ) async {
    try {
      final row =
          await (_db.select(_db.bookkeepingTransactions)..where(
                (t) =>
                    t.id.equals(entryId.value) &
                    t.profileId.equals(profileId.value) &
                    t.deletedAtUtc.isNull(),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _entry(row));
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<domain.BookkeepingEntry>>> history(
    LocalId profileId, {
    LocalId? accountId,
  }) async {
    try {
      final query = _db.select(_db.bookkeepingTransactions)
        ..where(
          (t) =>
              t.profileId.equals(profileId.value) &
              t.deletedAtUtc.isNull() &
              (accountId == null
                  ? const drift.Constant(true)
                  : t.accountId.equals(accountId.value)),
        )
        ..orderBy([
          (t) => drift.OrderingTerm.desc(t.businessDate),
          (t) => drift.OrderingTerm.desc(t.id),
        ]);
      return Success((await query.get()).map(_entry).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.BookkeepingEntry>> delete(
    LocalId profileId,
    LocalId entryId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        final prior = await get(profileId, entryId);
        if (prior is Failure<domain.BookkeepingEntry?>)
          return Failure(prior.code);
        final entry = (prior as Success<domain.BookkeepingEntry?>).value;
        if (entry == null) return const Failure(FailureCode.recordNotFound);
        final count =
            await (_db.update(_db.bookkeepingTransactions)..where(
                  (t) =>
                      t.id.equals(entryId.value) &
                      t.profileId.equals(profileId.value) &
                      t.deletedAtUtc.isNull() &
                      t.createdAtUtc.isSmallerOrEqualValue(
                        nowUtc.microsecondsSinceEpoch,
                      ),
                ))
                .write(
                  sql.BookkeepingTransactionsCompanion(
                    deletedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                    updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                  ),
                );
        if (count == 0) return const Failure(FailureCode.recordNotFound);
        final deleted = domain.BookkeepingEntry(
          id: entry.id,
          profileId: entry.profileId,
          accountId: entry.accountId,
          categoryId: entry.categoryId,
          projectId: entry.projectId,
          kind: entry.kind,
          amount: entry.amount,
          businessDate: entry.businessDate,
          note: entry.note,
          createdAtUtc: entry.createdAtUtc,
          updatedAtUtc: nowUtc,
          deletedAtUtc: nowUtc,
        );
        final captured = await _sync.capture(
          entityType: SyncEntityType.transaction,
          entityId: deleted.id.value,
          operation: SyncOperation.delete,
          payload: _entryPayload(deleted),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success(deleted);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.BookkeepingEntry>> assignProject(
    LocalId profileId,
    LocalId entryId,
    LocalId? projectId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        if (projectId != null) {
          final project =
              await (_db.select(_db.projects)..where(
                    (p) =>
                        p.id.equals(projectId.value) &
                        p.profileId.equals(profileId.value),
                  ))
                  .getSingleOrNull();
          if (project == null) {
            return const Failure<domain.BookkeepingEntry>(
              FailureCode.projectNotFound,
            );
          }
          if (project.isArchived) {
            return const Failure<domain.BookkeepingEntry>(
              FailureCode.projectArchived,
            );
          }
        }
        final count =
            await (_db.update(_db.bookkeepingTransactions)..where(
                  (t) =>
                      t.id.equals(entryId.value) &
                      t.profileId.equals(profileId.value) &
                      t.deletedAtUtc.isNull(),
                ))
                .write(
                  sql.BookkeepingTransactionsCompanion(
                    projectId: drift.Value(projectId?.value),
                    updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                  ),
                );
        if (count != 1) {
          return const Failure<domain.BookkeepingEntry>(
            FailureCode.recordNotFound,
          );
        }
        final loaded = await get(profileId, entryId);
        if (loaded is Success<domain.BookkeepingEntry?>) {
          final value = loaded.value!;
          final captured = await _sync.capture(
            entityType: SyncEntityType.transaction,
            entityId: value.id.value,
            operation: SyncOperation.update,
            payload: _entryPayload(value),
          );
          if (captured is Failure<bool>)
            throw StateError('sync capture failed');
          return Success(value);
        }
        return const Failure(FailureCode.localStoreUnavailable);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

Map<String, Object?> _entryPayload(domain.BookkeepingEntry entry) =>
    SyncPayloads.entry(
      profileId: entry.profileId.value,
      accountId: entry.accountId.value,
      categoryId: entry.categoryId.value,
      projectId: entry.projectId?.value,
      kind: entry.kind.name,
      amountMinorUnits: entry.amount.minorUnits,
      currencyCode: entry.amount.currency.code,
      businessDate: entry.businessDate.value,
      note: entry.note,
      createdAt: entry.createdAtUtc,
      updatedAt: entry.updatedAtUtc,
      deletedAt: entry.deletedAtUtc,
    );
