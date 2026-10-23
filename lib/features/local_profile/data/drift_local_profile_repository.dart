import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;

import '../../../core/clock.dart';
import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/local_unit_of_work.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart';
import '../domain/local_profile.dart' as domain;

/// Data mapping is explicit; generated Drift rows never enter the domain.
final class DriftLocalProfileRepository
    implements domain.LocalProfileRepository {
  DriftLocalProfileRepository(this._db, this._ids, this._clock);

  final LedgerDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  domain.LocalProfile _toDomain(LocalProfile row) => domain.LocalProfile(
    id: LocalId(row.id),
    baseCurrency: Currency.fromCode(row.baseCurrencyCode),
    createdAtUtc: DateTime.fromMicrosecondsSinceEpoch(
      row.createdAtUtc,
      isUtc: true,
    ),
    updatedAtUtc: DateTime.fromMicrosecondsSinceEpoch(
      row.updatedAtUtc,
      isUtc: true,
    ),
  );

  @override
  Future<Result<domain.LocalProfile?>> read() async {
    try {
      final row = await _db.select(_db.localProfiles).getSingleOrNull();
      return Success(row == null ? null : _toDomain(row));
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.LocalProfile>> create({
    required Currency baseCurrency,
  }) async {
    final id = _ids.generate();
    final now = _clock.nowUtc();
    if (!now.isUtc) throw StateError('Clock must supply UTC instants');
    final profile = domain.LocalProfile(
      id: id,
      baseCurrency: baseCurrency,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    try {
      await _db
          .into(_db.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              slot: const Value(1),
              id: id.value,
              baseCurrencyCode: baseCurrency.code,
              createdAtUtc: now.microsecondsSinceEpoch,
              updatedAtUtc: now.microsecondsSinceEpoch,
            ),
          );
      return Success(profile);
    } on SqliteException catch (error) {
      return Failure(
        error.resultCode == 19
            ? FailureCode.localProfileAlreadyExists
            : FailureCode.localStoreUnavailable,
      );
    }
  }
}

/// A Phase 2B command can compose multiple repository writes atomically.
final class DriftLocalUnitOfWork implements LocalUnitOfWork {
  DriftLocalUnitOfWork(this._db);
  final LedgerDatabase _db;

  @override
  Future<Result<T>> run<T>(Future<Result<T>> Function() action) async {
    try {
      return await _db.transaction(() async {
        final result = await action();
        if (result is Failure<T>) throw _RollbackFailure<T>(result);
        return result;
      });
    } on _RollbackFailure<T> catch (rolledBack) {
      return rolledBack.failure;
    } on SqliteException {
      return Failure<T>(FailureCode.localStoreUnavailable);
    }
  }
}

final class _RollbackFailure<T> implements Exception {
  const _RollbackFailure(this.failure);
  final Failure<T> failure;
}
