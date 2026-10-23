import '../../../core/clock.dart';
import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../bookkeeping/domain/transfer.dart';
import '../../bookkeeping/domain/recorded_fx.dart';
import '../../local_profile/domain/local_profile.dart';
import '../domain/budget.dart';
import '../domain/project.dart';

final class PlanningService {
  PlanningService({
    required this.profiles,
    required this.entries,
    required this.transfers,
    required this.budgets,
    required this.projects,
    required this.ids,
    required this.clock,
  });

  final LocalProfileRepository profiles;
  final EntryRepository entries;
  final TransferRepository transfers;
  final BudgetRepository budgets;
  final ProjectRepository projects;
  final IdGenerator ids;
  final Clock clock;
  static const _fx = RecordedFxConverter();

  Future<Result<LocalProfile?>> localProfile() => profiles.read();

  Future<Result<List<Budget>>> listBudgets(
    LocalId profileId, {
    bool includeArchived = false,
  }) => budgets.list(profileId, includeArchived: includeArchived);

  Future<Result<List<Project>>> listProjects(
    LocalId profileId, {
    bool includeArchived = false,
  }) => projects.list(profileId, includeArchived: includeArchived);

  Future<Result<Budget>> archiveBudget(LocalId profileId, LocalId budgetId) =>
      budgets.archive(profileId, budgetId, _now());

  Future<Result<Project>> archiveProject(
    LocalId profileId,
    LocalId projectId,
  ) => projects.archive(profileId, projectId, _now());

  DateTime _now() {
    final value = clock.nowUtc();
    if (!value.isUtc) throw StateError('Clock must supply UTC instants');
    return value;
  }

  Future<Result<Budget>> createBudget({
    required LocalId profileId,
    required String name,
    required Money amount,
    required BudgetMonth month,
    LocalId? categoryId,
    int warningThresholdPercent = 80,
  }) async {
    final now = _now();
    return budgets.create(
      Budget(
        id: ids.generate(),
        profileId: profileId,
        name: name,
        amount: amount,
        month: month,
        categoryId: categoryId,
        warningThresholdPercent: warningThresholdPercent,
        isArchived: false,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<Result<Project>> createProject({
    required LocalId profileId,
    required String name,
    String? description,
  }) async {
    final now = _now();
    return projects.create(
      Project(
        id: ids.generate(),
        profileId: profileId,
        name: name,
        description: description,
        isArchived: false,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<Result<Project>> updateProject({
    required Project project,
    required String name,
    String? description,
  }) => projects.update(
    Project(
      id: project.id,
      profileId: project.profileId,
      name: name,
      description: description,
      isArchived: project.isArchived,
      createdAtUtc: project.createdAtUtc,
      updatedAtUtc: _now(),
    ),
  );

  Future<Result<BookkeepingEntry>> assignProject({
    required LocalId profileId,
    required LocalId entryId,
    LocalId? projectId,
  }) => entries.assignProject(profileId, entryId, projectId, _now());

  Future<Result<BudgetProgress>> calculateBudget(Budget budget) async {
    final entryResult = await entries.history(budget.profileId);
    if (entryResult is Failure<List<BookkeepingEntry>>) {
      return Failure(entryResult.code);
    }
    final transferResult = await transfers.history(budget.profileId);
    if (transferResult is Failure<List<LedgerTransfer>>) {
      return Failure(transferResult.code);
    }
    var spent = BigInt.zero;
    final missing = <String>{};
    for (final entry
        in (entryResult as Success<List<BookkeepingEntry>>).value) {
      if (entry.kind != EntryKind.expense ||
          !budget.month.contains(entry.businessDate.value) ||
          (budget.categoryId != null &&
              entry.categoryId != budget.categoryId)) {
        continue;
      }
      final converted = _fx.convert(
        amount: entry.amount,
        target: budget.currency,
        businessDate: entry.businessDate,
        availableTransfers:
            (transferResult as Success<List<LedgerTransfer>>).value,
      );
      if (!converted.isComplete) {
        missing.add(entry.amount.currency.code);
      } else {
        spent += BigInt.from(converted.money!.minorUnits);
      }
    }
    final spentMoney = Money.fromExactMinorUnits(budget.currency, spent);
    final remaining = budget.amount - spentMoney;
    return Success(
      BudgetProgress(
        budget: budget.amount,
        spent: spentMoney,
        remaining: remaining,
        isOverBudget: spentMoney.minorUnits > budget.amount.minorUnits,
        isComplete: missing.isEmpty,
        missingCurrencies: Set.unmodifiable(missing),
      ),
    );
  }

  Future<Result<ProjectSummary>> calculateProjectSummary({
    required Project project,
    required Currency currency,
  }) async {
    final entryResult = await entries.history(project.profileId);
    if (entryResult is Failure<List<BookkeepingEntry>>) {
      return Failure(entryResult.code);
    }
    final transferResult = await transfers.history(project.profileId);
    if (transferResult is Failure<List<LedgerTransfer>>) {
      return Failure(transferResult.code);
    }
    var income = BigInt.zero;
    var expense = BigInt.zero;
    final missing = <String>{};
    for (final entry
        in (entryResult as Success<List<BookkeepingEntry>>).value) {
      if (entry.projectId != project.id) continue;
      final converted = _fx.convert(
        amount: entry.amount,
        target: currency,
        businessDate: entry.businessDate,
        availableTransfers:
            (transferResult as Success<List<LedgerTransfer>>).value,
      );
      if (!converted.isComplete) {
        missing.add(entry.amount.currency.code);
      } else if (entry.kind == EntryKind.income) {
        income += BigInt.from(converted.money!.minorUnits);
      } else {
        expense += BigInt.from(converted.money!.minorUnits);
      }
    }
    final incomeMoney = Money.fromExactMinorUnits(currency, income);
    final expenseMoney = Money.fromExactMinorUnits(currency, expense);
    return Success(
      ProjectSummary(
        income: incomeMoney,
        expense: expenseMoney,
        net: incomeMoney - expenseMoney,
        isComplete: missing.isEmpty,
        missingCurrencies: Set.unmodifiable(missing),
      ),
    );
  }
}
