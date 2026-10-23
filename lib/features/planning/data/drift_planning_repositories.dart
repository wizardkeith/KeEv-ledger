import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' show SqliteException;

import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../infrastructure/local/ledger_database.dart' as sql;
import '../../sync/data/drift_sync_mutation_capture.dart';
import '../../sync/domain/sync_protocol.dart';
import '../domain/budget.dart' as domain;
import '../domain/project.dart' as domain;

DateTime _utc(int value) =>
    DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);

Failure<T> _failure<T>(SqliteException error) => Failure(
  error.resultCode == 19 && error.message.contains('UNIQUE constraint failed')
      ? FailureCode.recordAlreadyExists
      : FailureCode.localStoreUnavailable,
);

domain.Project _project(sql.Project row) => domain.Project(
  id: LocalId(row.id),
  profileId: LocalId(row.profileId),
  name: row.name,
  description: row.description,
  isArchived: row.isArchived,
  createdAtUtc: _utc(row.createdAtUtc),
  updatedAtUtc: _utc(row.updatedAtUtc),
);

domain.Budget _budget(sql.Budget row) => domain.Budget(
  id: LocalId(row.id),
  profileId: LocalId(row.profileId),
  name: row.name,
  amount: Money.fromMinorUnits(
    Currency.fromCode(row.currencyCode),
    row.amountMinorUnits,
  ),
  month: domain.BudgetMonth(row.month),
  categoryId: row.categoryId == null ? null : LocalId(row.categoryId!),
  warningThresholdPercent: row.warningThresholdPercent,
  isArchived: row.isArchived,
  createdAtUtc: _utc(row.createdAtUtc),
  updatedAtUtc: _utc(row.updatedAtUtc),
);

final class DriftProjectRepository implements domain.ProjectRepository {
  DriftProjectRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<domain.Project>> create(domain.Project project) async {
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.projects)
            .insert(
              sql.ProjectsCompanion.insert(
                id: project.id.value,
                profileId: project.profileId.value,
                name: project.name,
                description: drift.Value(project.description),
                isArchived: drift.Value(project.isArchived),
                createdAtUtc: project.createdAtUtc.microsecondsSinceEpoch,
                updatedAtUtc: project.updatedAtUtc.microsecondsSinceEpoch,
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.project,
          entityId: project.id.value,
          operation: SyncOperation.create,
          payload: _projectPayload(project),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
      });
      return Success(project);
    } on SqliteException catch (error) {
      return _failure(error);
    }
  }

  @override
  Future<Result<domain.Project?>> get(
    LocalId profileId,
    LocalId projectId,
  ) async {
    try {
      final row =
          await (_db.select(_db.projects)..where(
                (p) =>
                    p.id.equals(projectId.value) &
                    p.profileId.equals(profileId.value),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _project(row));
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<List<domain.Project>>> list(
    LocalId profileId, {
    bool includeArchived = false,
  }) async {
    try {
      final query = _db.select(_db.projects)
        ..where(
          (p) =>
              p.profileId.equals(profileId.value) &
              (includeArchived
                  ? const drift.Constant(true)
                  : p.isArchived.equals(false)),
        )
        ..orderBy([
          (p) => drift.OrderingTerm.asc(p.name),
          (p) => drift.OrderingTerm.asc(p.id),
        ]);
      return Success((await query.get()).map(_project).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.Project>> update(domain.Project project) async {
    try {
      final count = await _db.transaction(() async {
        final updated =
            await (_db.update(_db.projects)..where(
                  (p) =>
                      p.id.equals(project.id.value) &
                      p.profileId.equals(project.profileId.value),
                ))
                .write(
                  sql.ProjectsCompanion(
                    name: drift.Value(project.name),
                    description: drift.Value(project.description),
                    updatedAtUtc: drift.Value(
                      project.updatedAtUtc.microsecondsSinceEpoch,
                    ),
                  ),
                );
        if (updated == 1) {
          final captured = await _sync.capture(
            entityType: SyncEntityType.project,
            entityId: project.id.value,
            operation: SyncOperation.update,
            payload: _projectPayload(project),
          );
          if (captured is Failure<bool>)
            throw StateError('sync capture failed');
        }
        return updated;
      });
      return count == 1
          ? Success(project)
          : const Failure(FailureCode.projectNotFound);
    } on SqliteException catch (error) {
      return _failure(error);
    }
  }

  @override
  Future<Result<domain.Project>> archive(
    LocalId profileId,
    LocalId projectId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        final count =
            await (_db.update(_db.projects)..where(
                  (p) =>
                      p.id.equals(projectId.value) &
                      p.profileId.equals(profileId.value),
                ))
                .write(
                  sql.ProjectsCompanion(
                    isArchived: const drift.Value(true),
                    updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
                  ),
                );
        if (count != 1) return const Failure(FailureCode.projectNotFound);
        final result = await get(profileId, projectId);
        if (result is! Success<domain.Project?>)
          return const Failure(FailureCode.localStoreUnavailable);
        final project = result.value!;
        final captured = await _sync.capture(
          entityType: SyncEntityType.project,
          entityId: project.id.value,
          operation: SyncOperation.update,
          payload: _projectPayload(project),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success(project);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

final class DriftBudgetRepository implements domain.BudgetRepository {
  DriftBudgetRepository(this._db, {DriftSyncMutationCapture? sync})
    : _sync = sync ?? DriftSyncMutationCapture(_db);
  final sql.LedgerDatabase _db;
  final DriftSyncMutationCapture _sync;

  @override
  Future<Result<domain.Budget>> create(domain.Budget budget) async {
    try {
      return await _db.transaction(() async {
        if (budget.categoryId != null) {
          final category =
              await (_db.select(_db.categories)..where(
                    (c) =>
                        c.id.equals(budget.categoryId!.value) &
                        c.profileId.equals(budget.profileId.value),
                  ))
                  .getSingleOrNull();
          if (category == null) {
            return const Failure<domain.Budget>(FailureCode.categoryNotFound);
          }
          if (category.kind != 'expense') {
            return const Failure<domain.Budget>(
              FailureCode.budgetCategoryMustBeExpense,
            );
          }
        }
        await _db
            .into(_db.budgets)
            .insert(
              sql.BudgetsCompanion.insert(
                id: budget.id.value,
                profileId: budget.profileId.value,
                name: budget.name,
                amountMinorUnits: budget.amount.minorUnits,
                currencyCode: budget.currency.code,
                month: budget.month.value,
                categoryId: drift.Value(budget.categoryId?.value),
                warningThresholdPercent: drift.Value(
                  budget.warningThresholdPercent,
                ),
                isArchived: drift.Value(budget.isArchived),
                createdAtUtc: budget.createdAtUtc.microsecondsSinceEpoch,
                updatedAtUtc: budget.updatedAtUtc.microsecondsSinceEpoch,
              ),
            );
        final captured = await _sync.capture(
          entityType: SyncEntityType.budget,
          entityId: budget.id.value,
          operation: SyncOperation.create,
          payload: _budgetPayload(budget),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success<domain.Budget>(budget);
      });
    } on SqliteException catch (error) {
      return _failure(error);
    }
  }

  @override
  Future<Result<List<domain.Budget>>> list(
    LocalId profileId, {
    bool includeArchived = false,
  }) async {
    try {
      final query = _db.select(_db.budgets)
        ..where(
          (b) =>
              b.profileId.equals(profileId.value) &
              (includeArchived
                  ? const drift.Constant(true)
                  : b.isArchived.equals(false)),
        )
        ..orderBy([
          (b) => drift.OrderingTerm.desc(b.month),
          (b) => drift.OrderingTerm.asc(b.name),
          (b) => drift.OrderingTerm.asc(b.id),
        ]);
      return Success((await query.get()).map(_budget).toList());
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }

  @override
  Future<Result<domain.Budget>> archive(
    LocalId profileId,
    LocalId budgetId,
    DateTime nowUtc,
  ) async {
    if (!nowUtc.isUtc) throw ArgumentError('Expected UTC');
    try {
      return await _db.transaction(() async {
        final row =
            await (_db.select(_db.budgets)..where(
                  (b) =>
                      b.id.equals(budgetId.value) &
                      b.profileId.equals(profileId.value),
                ))
                .getSingleOrNull();
        if (row == null) return const Failure(FailureCode.budgetNotFound);
        await (_db.update(
          _db.budgets,
        )..where((b) => b.id.equals(budgetId.value))).write(
          sql.BudgetsCompanion(
            isArchived: const drift.Value(true),
            updatedAtUtc: drift.Value(nowUtc.microsecondsSinceEpoch),
          ),
        );
        final archived = domain.Budget(
          id: LocalId(row.id),
          profileId: LocalId(row.profileId),
          name: row.name,
          amount: Money.fromMinorUnits(
            Currency.fromCode(row.currencyCode),
            row.amountMinorUnits,
          ),
          month: domain.BudgetMonth(row.month),
          categoryId: row.categoryId == null ? null : LocalId(row.categoryId!),
          warningThresholdPercent: row.warningThresholdPercent,
          isArchived: true,
          createdAtUtc: _utc(row.createdAtUtc),
          updatedAtUtc: nowUtc,
        );
        final captured = await _sync.capture(
          entityType: SyncEntityType.budget,
          entityId: archived.id.value,
          operation: SyncOperation.update,
          payload: _budgetPayload(archived),
        );
        if (captured is Failure<bool>) throw StateError('sync capture failed');
        return Success(archived);
      });
    } on SqliteException {
      return const Failure(FailureCode.localStoreUnavailable);
    }
  }
}

Map<String, Object?> _projectPayload(domain.Project value) =>
    SyncPayloads.project(
      profileId: value.profileId.value,
      name: value.name,
      description: value.description,
      isArchived: value.isArchived,
      createdAt: value.createdAtUtc,
      updatedAt: value.updatedAtUtc,
    );

Map<String, Object?> _budgetPayload(domain.Budget value) => SyncPayloads.budget(
  profileId: value.profileId.value,
  name: value.name,
  amountMinorUnits: value.amount.minorUnits,
  currencyCode: value.currency.code,
  month: value.month.value,
  categoryId: value.categoryId?.value,
  warningThresholdPercent: value.warningThresholdPercent,
  isArchived: value.isArchived,
  createdAt: value.createdAtUtc,
  updatedAt: value.updatedAtUtc,
);
