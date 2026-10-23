import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' show SqliteException;

import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart' as sql;
import '../../sync/data/drift_sync_mutation_capture.dart';
import '../../sync/domain/sync_protocol.dart';
import '../domain/bookkeeping.dart';
import '../domain/transfer.dart';

LedgerTransfer _fromRow(sql.Transfer row) => LedgerTransfer(
  id: LocalId(row.id),
  profileId: LocalId(row.profileId),
  sourceAccountId: LocalId(row.sourceAccountId),
  destinationAccountId: LocalId(row.destinationAccountId),
  sent: Money.fromMinorUnits(
    Currency.fromCode(row.sourceCurrencyCode),
    row.sourceMinorUnits,
  ),
  received: Money.fromMinorUnits(
    Currency.fromCode(row.destinationCurrencyCode),
    row.destinationMinorUnits,
  ),
  businessDate: BusinessDate(row.businessDate),
  note: row.note,
  createdAtUtc: DateTime.fromMicrosecondsSinceEpoch(
    row.createdAtUtc,
    isUtc: true,
  ),
  updatedAtUtc: DateTime.fromMicrosecondsSinceEpoch(
    row.updatedAtUtc,
    isUtc: true,
  ),
  deletedAtUtc: row.deletedAtUtc == null
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(row.deletedAtUtc!, isUtc: true),
);

/// A single row contains both sides; an incomplete transfer cannot be stored.
final class DriftTransferRepository implements TransferRepository {
  DriftTransferRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<LedgerTransfer>> create(LedgerTransfer transfer) async {
    try {
      return await _db.transaction(() async {
        final source =
            await (_db.select(_db.accounts)..where(
                  (a) =>
                      a.id.equals(transfer.sourceAccountId.value) &
                      a.profileId.equals(transfer.profileId.value),
                ))
                .getSingleOrNull();
        final destination =
            await (_db.select(_db.accounts)..where(
                  (a) =>
                      a.id.equals(transfer.destinationAccountId.value) &
                      a.profileId.equals(transfer.profileId.value),
                ))
                .getSingleOrNull();
        if (source == null || destination == null)
          return const Failure<LedgerTransfer>(FailureCode.accountNotFound);
        if (source.isArchived || destination.isArchived)
          return const Failure<LedgerTransfer>(FailureCode.accountArchived);
        if (transfer.sent.currency.code != source.currencyCode ||
            transfer.received.currency.code != destination.currencyCode) {
          return const Failure<LedgerTransfer>(FailureCode.currencyMismatch);
        }
        if (transfer.businessDate.value.compareTo(source.openingDate) < 0 ||
            transfer.businessDate.value.compareTo(destination.openingDate) <
                0) {
          return const Failure<LedgerTransfer>(FailureCode.dateBeforeOpening);
        }
        await _db
            .into(_db.transfers)
            .insert(
              sql.TransfersCompanion.insert(
                id: transfer.id.value,
                profileId: transfer.profileId.value,
                sourceAccountId: transfer.sourceAccountId.value,
                destinationAccountId: transfer.destinationAccountId.value,
                sourceMinorUnits: transfer.sent.minorUnits,
                sourceCurrencyCode: transfer.sent.currency.code,
                destinationMinorUnits: transfer.received.minorUnits,
                destinationCurrencyCode: transfer.received.currency.code,
                businessDate: transfer.businessDate.value,
                note: drift.Value(transfer.note),
                createdAtUtc: transfer.createdAtUtc.microsecondsSinceEpoch,
                updatedAtUtc: transfer.updatedAtUtc.microsecondsSinceEpoch,
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.transfer,
          entityId: transfer.id.value,
          operation: SyncOperation.create,
          payload: _payload(transfer),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success<LedgerTransfer>(transfer);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<LedgerTransfer>>> history(
    LocalId profileId, {
    LocalId? accountId,
  }) async {
    try {
      final query = _db.select(_db.transfers)
        ..where(
          (t) =>
              t.profileId.equals(profileId.value) &
              t.deletedAtUtc.isNull() &
              (accountId == null
                  ? const drift.Constant(true)
                  : (t.sourceAccountId.equals(accountId.value) |
                        t.destinationAccountId.equals(accountId.value))),
        )
        ..orderBy([
          (t) => drift.OrderingTerm.desc(t.businessDate),
          (t) => drift.OrderingTerm.desc(t.id),
        ]);
      return Success((await query.get()).map(_fromRow).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<LedgerTransfer>> delete(
    LocalId profileId,
    LocalId transferId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        final row =
            await (_db.select(_db.transfers)..where(
                  (t) =>
                      t.id.equals(transferId.value) &
                      t.profileId.equals(profileId.value) &
                      t.deletedAtUtc.isNull(),
                ))
                .getSingleOrNull();
        if (row == null)
          return const Failure<LedgerTransfer>(FailureCode.recordNotFound);
        final count =
            await (_db.update(_db.transfers)..where(
                  (t) =>
                      t.id.equals(transferId.value) &
                      t.profileId.equals(profileId.value) &
                      t.deletedAtUtc.isNull(),
                ))
                .write(
                  sql.TransfersCompanion(
                    updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                    deletedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                  ),
                );
        if (count != 1)
          return const Failure<LedgerTransfer>(FailureCode.recordNotFound);
        final deleted = LedgerTransfer(
          id: LocalId(row.id),
          profileId: LocalId(row.profileId),
          sourceAccountId: LocalId(row.sourceAccountId),
          destinationAccountId: LocalId(row.destinationAccountId),
          sent: Money.fromMinorUnits(
            Currency.fromCode(row.sourceCurrencyCode),
            row.sourceMinorUnits,
          ),
          received: Money.fromMinorUnits(
            Currency.fromCode(row.destinationCurrencyCode),
            row.destinationMinorUnits,
          ),
          businessDate: BusinessDate(row.businessDate),
          note: row.note,
          createdAtUtc: DateTime.fromMicrosecondsSinceEpoch(
            row.createdAtUtc,
            isUtc: true,
          ),
          updatedAtUtc: nowUtc,
          deletedAtUtc: nowUtc,
        );
        final captured = await _sync.capture(
          entityType: SyncEntityType.transfer,
          entityId: deleted.id.value,
          operation: SyncOperation.delete,
          payload: _payload(deleted),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success(deleted);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

Map<String, Object?> _payload(LedgerTransfer value) => SyncPayloads.transfer(
  profileId: value.profileId.value,
  sourceAccountId: value.sourceAccountId.value,
  destinationAccountId: value.destinationAccountId.value,
  sourceMinorUnits: value.sent.minorUnits,
  sourceCurrencyCode: value.sent.currency.code,
  destinationMinorUnits: value.received.minorUnits,
  destinationCurrencyCode: value.received.currency.code,
  businessDate: value.businessDate.value,
  note: value.note,
  createdAt: value.createdAtUtc,
  updatedAt: value.updatedAtUtc,
  deletedAt: value.deletedAtUtc,
);
