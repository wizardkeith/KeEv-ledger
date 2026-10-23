import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show MigrationStrategy, QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/planning/domain/budget.dart';
import 'package:ledger/features/planning/domain/project.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;

final class _VersionThreeDatabase extends LedgerDatabase {
  _VersionThreeDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      final snapshot = jsonDecode(
        await File('drift_schemas/ledger_database/drift_schema_v3.json')
            .readAsString(),
      ) as Map<String, Object?>;
      for (final item in snapshot['fixed_sql']! as List<Object?>) {
        final statements =
            (item! as Map<String, Object?>)['sql']! as List<Object?>;
        final sqlite = statements.cast<Map<String, Object?>>().singleWhere(
          (statement) => statement['dialect'] == 'sqlite',
        );
        await customStatement(sqlite['sql']! as String);
      }
    },
  );
}

void main() {
  late Directory directory;
  late File file;
  late BookkeepingRuntime runtime;
  late LocalId profile;
  late Account hkd, secondHkd, usd;
  late Category food, travel, salary;

  Future<void> open() async {
    runtime = BookkeepingRuntime(LedgerDatabase(NativeDatabase(file)));
    profile = (await runtime.profile() as Success<LocalId>).value;
  }

  Future<Account> account(String name, Currency currency) async =>
      (await runtime.service.createAccount(
        profileId: profile,
        name: name,
        kind: AccountKind.bank,
        currency: currency,
        openingBalance: Money.zero(currency),
        openingDate: BusinessDate('2026-01-01'),
      ) as Success<Account>).value;

  Future<Category> category(String name, EntryKind kind) async =>
      (await runtime.service.createCategory(
        profileId: profile,
        name: name,
        kind: kind,
      ) as Success<Category>).value;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('keev-planning-');
    file = File('${directory.path}/ledger.sqlite');
    await open();
    hkd = await account('HKD', Currency.hkd);
    secondHkd = await account('Savings', Currency.hkd);
    usd = await account('USD', Currency.usd);
    food = await category('Food', EntryKind.expense);
    travel = await category('Travel', EntryKind.expense);
    salary = await category('Salary', EntryKind.income);
  });

  tearDown(() async {
    await runtime.close();
    await directory.delete(recursive: true);
  });

  Future<BookkeepingEntry> expense({
    required Account account,
    required Category category,
    required int amount,
    required String date,
    LocalId? projectId,
  }) async => (await runtime.service.recordExpense(
    profileId: profile,
    accountId: account.id,
    categoryId: category.id,
    amount: Money.fromMinorUnits(account.currency, amount),
    businessDate: BusinessDate(date),
    projectId: projectId,
  ) as Success<BookkeepingEntry>).value;

  test(
    'monthly budget counts only matching live expenses deterministically',
    () async {
      expect(BudgetMonth('2026-01').firstDay, '2026-01-01');
      expect(BudgetMonth('2026-01').nextMonthFirstDay, '2026-02-01');
      expect(BudgetMonth('2026-12').nextMonthFirstDay, '2027-01-01');

      await expense(
        account: hkd,
        category: food,
        amount: 6000,
        date: '2026-01-01',
      );
      await expense(
        account: hkd,
        category: food,
        amount: 5000,
        date: '2026-01-31',
      );
      await expense(
        account: hkd,
        category: food,
        amount: 9000,
        date: '2026-02-01',
      );
      await expense(
        account: hkd,
        category: travel,
        amount: 7000,
        date: '2026-01-15',
      );
      await runtime.service.recordIncome(
        profileId: profile,
        accountId: hkd.id,
        categoryId: salary.id,
        amount: Money.fromMinorUnits(Currency.hkd, 50000),
        businessDate: BusinessDate('2026-01-15'),
      );
      final deleted = await expense(
        account: hkd,
        category: food,
        amount: 4000,
        date: '2026-01-20',
      );
      await runtime.service.deleteEntry(profile, deleted.id);
      await runtime.service.transfer(
        profileId: profile,
        sourceAccountId: hkd.id,
        destinationAccountId: secondHkd.id,
        sent: Money.fromMinorUnits(Currency.hkd, 3000),
        businessDate: BusinessDate('2026-01-15'),
      );

      final budget = (await runtime.planning.createBudget(
        profileId: profile,
        name: 'Food January',
        amount: Money.fromMinorUnits(Currency.hkd, 10000),
        month: BudgetMonth('2026-01'),
        categoryId: food.id,
      ) as Success<Budget>).value;
      final progress = (await runtime.planning.calculateBudget(
        budget,
      ) as Success<BudgetProgress>).value;
      expect(progress.spent.minorUnits, 11000);
      expect(progress.remaining.minorUnits, -1000);
      expect(progress.isOverBudget, isTrue);
      expect(progress.isComplete, isTrue);

      final zero = (await runtime.planning.createBudget(
        profileId: profile,
        name: 'Zero',
        amount: Money.zero(Currency.hkd),
        month: BudgetMonth('2026-01'),
      ) as Success<Budget>).value;
      final zeroProgress = (await runtime.planning.calculateBudget(
        zero,
      ) as Success<BudgetProgress>).value;
      expect(zeroProgress.fraction, isNull);
      expect(zeroProgress.isOverBudget, isTrue);

      await runtime.close();
      await open();
      expect(
        (await runtime.planning.listBudgets(profile) as Success<List<Budget>>)
            .value
            .map((item) => item.name),
        containsAll(['Food January', 'Zero']),
      );
    },
  );

  test(
    'exact transfer-derived FX converts known dates and exposes missing FX',
    () async {
      await runtime.service.transfer(
        profileId: profile,
        sourceAccountId: usd.id,
        destinationAccountId: hkd.id,
        sent: Money.fromMinorUnits(Currency.usd, 10000),
        received: Money.fromMinorUnits(Currency.hkd, 78000),
        businessDate: BusinessDate('2026-01-10'),
      );
      await expense(
        account: usd,
        category: food,
        amount: 1000,
        date: '2026-01-10',
      );
      await expense(
        account: usd,
        category: food,
        amount: 500,
        date: '2026-01-11',
      );
      final budget = (await runtime.planning.createBudget(
        profileId: profile,
        name: 'HKD view',
        amount: Money.fromMinorUnits(Currency.hkd, 100000),
        month: BudgetMonth('2026-01'),
      ) as Success<Budget>).value;
      final progress = (await runtime.planning.calculateBudget(
        budget,
      ) as Success<BudgetProgress>).value;
      expect(progress.spent, Money.fromMinorUnits(Currency.hkd, 7800));
      expect(progress.isComplete, isFalse);
      expect(progress.missingCurrencies, {'USD'});
      expect(progress.spent.minorUnits, isNot(1500));
    },
  );

  test('projects persist, assignments change, archive preserves history and summaries ignore transfers', () async {
    final trip = (await runtime.planning.createProject(
      profileId: profile,
      name: 'Japan Trip',
      description: 'Spring',
    ) as Success<Project>).value;
    final home = (await runtime.planning.createProject(
      profileId: profile,
      name: 'Home',
    ) as Success<Project>).value;
    final purchase = await expense(
      account: hkd,
      category: travel,
      amount: 5000,
      date: '2026-01-10',
      projectId: trip.id,
    );
    await runtime.service.recordIncome(
      profileId: profile,
      accountId: hkd.id,
      categoryId: salary.id,
      amount: Money.fromMinorUnits(Currency.hkd, 8000),
      businessDate: BusinessDate('2026-01-11'),
      projectId: trip.id,
    );
    await runtime.service.transfer(
      profileId: profile,
      sourceAccountId: hkd.id,
      destinationAccountId: secondHkd.id,
      sent: Money.fromMinorUnits(Currency.hkd, 2000),
      businessDate: BusinessDate('2026-01-11'),
    );
    final summary = (await runtime.planning.calculateProjectSummary(
      project: trip,
      currency: Currency.hkd,
    ) as Success<ProjectSummary>).value;
    expect(summary.income.minorUnits, 8000);
    expect(summary.expense.minorUnits, 5000);
    expect(summary.net.minorUnits, 3000);

    expect(
      (await runtime.planning.assignProject(
        profileId: profile,
        entryId: purchase.id,
        projectId: home.id,
      ) as Success<BookkeepingEntry>).value.projectId,
      home.id,
    );
    expect(
      (await runtime.planning.assignProject(
        profileId: profile,
        entryId: purchase.id,
      ) as Success<BookkeepingEntry>).value.projectId,
      isNull,
    );
    await runtime.planning.assignProject(
      profileId: profile,
      entryId: purchase.id,
      projectId: trip.id,
    );
    await runtime.planning.archiveProject(profile, trip.id);
    expect(
      (await runtime.service.history(profile)
              as Success<List<BookkeepingEntry>>)
          .value
          .firstWhere((entry) => entry.id == purchase.id)
          .projectId,
      trip.id,
    );
    expect(
      (await runtime.planning.assignProject(
        profileId: profile,
        entryId: purchase.id,
        projectId: trip.id,
      ) as Failure<BookkeepingEntry>).code,
      FailureCode.projectArchived,
    );

    await runtime.close();
    await open();
    final reloaded = (await runtime.planning.listProjects(
      profile,
      includeArchived: true,
    ) as Success<List<Project>>).value;
    expect(
      reloaded.singleWhere((project) => project.id == trip.id).isArchived,
      isTrue,
    );
    expect(
      (await runtime.service.history(profile)
              as Success<List<BookkeepingEntry>>)
          .value
          .firstWhere((entry) => entry.id == purchase.id)
          .projectId,
      trip.id,
    );
  });

  test('real v3 file migrates, preserves records and balances, then reopens', () async {
    await runtime.close();
    await file.delete();
    final old = _VersionThreeDatabase(NativeDatabase(file));
    const owner = 'c64019ee-74e2-4492-b170-45bf48c8f601';
    const source = '00000000-0000-4000-8000-000000000001';
    const target = '00000000-0000-4000-8000-000000000002';
    const categoryId = '00000000-0000-4000-8000-000000000003';
    await old.customInsert(
      "INSERT INTO local_profiles VALUES (1,'$owner','HKD',100,100)",
    );
    await old.customInsert(
      "INSERT INTO accounts VALUES ('$source','$owner','Cash','cash','HKD',10000,'2026-01-01',0,100,100)",
    );
    await old.customInsert(
      "INSERT INTO accounts VALUES ('$target','$owner','Bank','bank','HKD',0,'2026-01-01',0,100,100)",
    );
    await old.customInsert(
      "INSERT INTO categories VALUES ('$categoryId','$owner','Food','expense',0,100,100)",
    );
    await old.customInsert(
      "INSERT INTO bookkeeping_transactions VALUES ('00000000-0000-4000-8000-000000000004','$owner','$source','$categoryId','expense',125,'HKD','2026-01-02',NULL,100,100,NULL)",
    );
    await old.customInsert(
      "INSERT INTO transfers VALUES ('00000000-0000-4000-8000-000000000005','$owner','$source','$target',250,'HKD',250,'HKD','2026-01-03',NULL,100,100,NULL)",
    );
    await old.close();

    runtime = BookkeepingRuntime(LedgerDatabase(NativeDatabase(file)));
    profile = (await runtime.profile() as Success<LocalId>).value;
    expect(
      (await runtime.database.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      runtime.database.schemaVersion,
    );
    expect(profile.value, owner);
    expect(
      (await runtime.database
              .select(runtime.database.bookkeepingTransactions)
              .get())
          .single
          .projectId,
      null,
    );
    expect(
      (await runtime.service.accountBalance(
        profile,
        LocalId(source),
      ) as Success<Money>).value.minorUnits,
      9625,
    );
    await runtime.close();
    await open();
    expect(
      (await runtime.service.accountBalance(
        profile,
        LocalId(target),
      ) as Success<Money>).value.minorUnits,
      250,
    );
  });
}
