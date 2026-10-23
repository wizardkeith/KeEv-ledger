import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/bookkeeping/domain/history_item.dart';
import 'package:ledger/features/bookkeeping/domain/recorded_fx.dart';
import 'package:ledger/features/planning/domain/project.dart';
import 'package:ledger/features/reports/application/csv_export.dart';
import 'package:ledger/features/reports/domain/reports.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;

void main() {
  late BookkeepingRuntime runtime;
  late LocalId profile;
  late Account cash, bank, card, usd;
  late Category food, travel, salary;

  Future<Account> account(
    String name,
    Currency currency, {
    AccountKind kind = AccountKind.bank,
    int opening = 0,
  }) async => (await runtime.service.createAccount(
    profileId: profile,
    name: name,
    kind: kind,
    currency: currency,
    openingBalance: Money.fromMinorUnits(currency, opening),
    openingDate: BusinessDate('2025-01-01'),
  ) as Success<Account>).value;

  Future<Category> category(String name, EntryKind kind) async =>
      (await runtime.service.createCategory(
        profileId: profile,
        name: name,
        kind: kind,
      ) as Success<Category>).value;

  Future<BookkeepingEntry> entry({
    required Account account,
    required Category category,
    required int amount,
    required String date,
    EntryKind kind = EntryKind.expense,
    String? note,
    LocalId? projectId,
  }) async {
    final result = kind == EntryKind.income
        ? await runtime.service.recordIncome(
            profileId: profile,
            accountId: account.id,
            categoryId: category.id,
            amount: Money.fromMinorUnits(account.currency, amount),
            businessDate: BusinessDate(date),
            note: note,
            projectId: projectId,
          )
        : await runtime.service.recordExpense(
            profileId: profile,
            accountId: account.id,
            categoryId: category.id,
            amount: Money.fromMinorUnits(account.currency, amount),
            businessDate: BusinessDate(date),
            note: note,
            projectId: projectId,
          );
    return (result as Success<BookkeepingEntry>).value;
  }

  ReportQuery query(
    String start,
    String end, {
    Currency currency = Currency.hkd,
    LocalId? categoryId,
    LocalId? accountId,
    LocalId? projectId,
  }) => ReportQuery(
    profileId: profile,
    range: ReportRange(start: BusinessDate(start), end: BusinessDate(end)),
    currency: currency,
    categoryId: categoryId,
    accountId: accountId,
    projectId: projectId,
  );

  setUp(() async {
    runtime = BookkeepingRuntime(LedgerDatabase(NativeDatabase.memory()));
    profile = (await runtime.profile() as Success<LocalId>).value;
    cash = await account('Cash', Currency.hkd, opening: 10000);
    bank = await account('Bank', Currency.hkd);
    card = await account('Card', Currency.hkd, kind: AccountKind.creditCard);
    usd = await account('USD', Currency.usd);
    food = await category('Food', EntryKind.expense);
    travel = await category('Travel', EntryKind.expense);
    salary = await category('Salary', EntryKind.income);
  });

  tearDown(() => runtime.close());

  test(
    'inclusive business-date report totals exclude transfers and tombstones',
    () async {
      await entry(
        account: cash,
        category: salary,
        amount: 10000,
        date: '2026-01-01',
        kind: EntryKind.income,
      );
      await entry(
        account: cash,
        category: food,
        amount: 2500,
        date: '2026-01-31',
      );
      await entry(
        account: cash,
        category: travel,
        amount: 300,
        date: '2025-12-31',
      );
      await entry(
        account: cash,
        category: travel,
        amount: 400,
        date: '2026-02-01',
      );
      final deleted = await entry(
        account: cash,
        category: food,
        amount: 999,
        date: '2026-01-15',
      );
      await runtime.service.deleteEntry(profile, deleted.id);
      await runtime.service.transfer(
        profileId: profile,
        sourceAccountId: cash.id,
        destinationAccountId: bank.id,
        sent: Money.fromMinorUnits(Currency.hkd, 2000),
        businessDate: BusinessDate('2026-01-20'),
      );
      await entry(
        account: card,
        category: food,
        amount: 500,
        date: '2026-01-10',
      );
      await runtime.service.transfer(
        profileId: profile,
        sourceAccountId: bank.id,
        destinationAccountId: card.id,
        sent: Money.fromMinorUnits(Currency.hkd, 500),
        businessDate: BusinessDate('2026-01-25'),
      );

      final report = (await runtime.reporting.incomeExpense(
        query('2026-01-01', '2026-01-31'),
      ) as Success<IncomeExpenseReport>).value;
      expect(report.totals.income.minorUnits, 10000);
      expect(report.totals.expense.minorUnits, 3000);
      expect(report.totals.net.minorUnits, 7000);
      expect(
        report.categories
            .singleWhere((row) => row.id == food.id)
            .totals
            .expense
            .minorUnits,
        3000,
      );
      expect(report.accounts.where((row) => row.id == bank.id), isEmpty);
      expect(
        report.trend.map((point) => point.date.value),
        containsAll(['2026-01-01', '2026-01-10', '2026-01-31']),
      );
    },
  );

  test('as-of balances use historical account sides, exclude future, and retain archives', () async {
    await entry(
      account: cash,
      category: salary,
      amount: 5000,
      date: '2026-01-05',
      kind: EntryKind.income,
    );
    await entry(
      account: cash,
      category: food,
      amount: 2000,
      date: '2026-01-10',
    );
    await runtime.service.transfer(
      profileId: profile,
      sourceAccountId: cash.id,
      destinationAccountId: bank.id,
      sent: Money.fromMinorUnits(Currency.hkd, 1000),
      businessDate: BusinessDate('2026-01-15'),
    );
    await entry(
      account: card,
      category: food,
      amount: 3000,
      date: '2026-01-12',
    );
    await entry(
      account: cash,
      category: salary,
      amount: 9999,
      date: '2026-02-01',
      kind: EntryKind.income,
    );
    await runtime.service.archiveAccount(profile, cash.id);

    final overview = (await runtime.reporting.assetsLiabilities(
      profileId: profile,
      asOf: BusinessDate('2026-01-31'),
      currency: Currency.hkd,
    ) as Success<AssetsLiabilitiesOverview>).value;
    expect(
      overview.accounts.any(
        (row) => row.account.id == cash.id && row.account.isArchived,
      ),
      isTrue,
    );
    expect(
      overview.accounts
          .singleWhere((row) => row.account.id == cash.id)
          .nativeBalance
          .minorUnits,
      12000,
    );
    expect(
      overview.accounts
          .singleWhere((row) => row.account.id == bank.id)
          .nativeBalance
          .minorUnits,
      1000,
    );
    expect(overview.assets.minorUnits, 13000);
    expect(overview.liabilities.minorUnits, 3000);
    expect(overview.net.minorUnits, 10000);
  });

  test(
    'exact, missing and ambiguous FX never fall back to nominal sums',
    () async {
      await runtime.service.transfer(
        profileId: profile,
        sourceAccountId: usd.id,
        destinationAccountId: bank.id,
        sent: Money.fromMinorUnits(Currency.usd, 10000),
        received: Money.fromMinorUnits(Currency.hkd, 78000),
        businessDate: BusinessDate('2026-01-10'),
      );
      await entry(
        account: usd,
        category: food,
        amount: 1000,
        date: '2026-01-10',
      );
      var report = (await runtime.reporting.incomeExpense(
        query('2026-01-10', '2026-01-10'),
      ) as Success<IncomeExpenseReport>).value;
      expect(report.totals.expense.minorUnits, 7800);
      expect(report.totals.completeness.isComplete, isTrue);
      expect(report.totals.completeness.provenance, isNotEmpty);

      await entry(
        account: usd,
        category: food,
        amount: 500,
        date: '2026-01-11',
      );
      report = (await runtime.reporting.incomeExpense(
        query('2026-01-10', '2026-01-11'),
      ) as Success<IncomeExpenseReport>).value;
      expect(report.totals.expense.minorUnits, 7800);
      expect(report.totals.completeness.isComplete, isFalse);
      expect(
        report.totals.completeness.issues.single.resolution,
        FxResolution.missing,
      );
      expect(report.totals.expense.minorUnits, isNot(1500));

      await runtime.service.transfer(
        profileId: profile,
        sourceAccountId: usd.id,
        destinationAccountId: cash.id,
        sent: Money.fromMinorUnits(Currency.usd, 10000),
        received: Money.fromMinorUnits(Currency.hkd, 80000),
        businessDate: BusinessDate('2026-01-10'),
      );
      report = (await runtime.reporting.incomeExpense(
        query('2026-01-10', '2026-01-10'),
      ) as Success<IncomeExpenseReport>).value;
      expect(report.totals.expense.minorUnits, 0);
      expect(
        report.totals.completeness.issues.single.resolution,
        FxResolution.ambiguous,
      );
    },
  );

  test('previous period is equal length and zero or incomplete comparisons are unavailable', () async {
    expect(
      query('2026-01-08', '2026-01-14').range.previous.start.value,
      '2026-01-01',
    );
    expect(
      query('2026-01-08', '2026-01-14').range.previous.end.value,
      '2026-01-07',
    );
    await entry(account: cash, category: food, amount: 100, date: '2026-01-01');
    await entry(account: cash, category: food, amount: 150, date: '2026-01-08');
    var report = (await runtime.reporting.incomeExpense(
      query('2026-01-08', '2026-01-14'),
    ) as Success<IncomeExpenseReport>).value;
    expect(report.comparison.expense.percentageChange, 50);
    expect(report.comparison.income.percentageChange, isNull);

    await entry(account: usd, category: food, amount: 100, date: '2026-01-09');
    report = (await runtime.reporting.incomeExpense(
      query('2026-01-08', '2026-01-14'),
    ) as Success<IncomeExpenseReport>).value;
    expect(report.comparison.expense.isComplete, isFalse);
    expect(report.comparison.expense.percentageChange, isNull);
  });

  test('history filters remain coherent and CSV is escaped, Unicode-safe and formula-safe', () async {
    final dangerous = await category('=SUM(1,2)\n"食物"', EntryKind.expense);
    final project = (await runtime.planning.createProject(
      profileId: profile,
      name: '@旅行',
    ) as Success<Project>).value;
    await entry(
      account: cash,
      category: dangerous,
      amount: 12345,
      date: '2026-01-10',
      note: '+公式, "引號"\n第二行',
      projectId: project.id,
    );
    await runtime.service.transfer(
      profileId: profile,
      sourceAccountId: cash.id,
      destinationAccountId: bank.id,
      sent: Money.fromMinorUnits(Currency.hkd, 500),
      businessDate: BusinessDate('2026-01-11'),
      note: '轉帳',
    );
    final expenseHistory = (await runtime.reporting.transactionHistory(
      TransactionHistoryQuery(
        profileId: profile,
        event: HistoryEventFilter.expense,
        projectId: project.id,
        text: '公式',
      ),
    ) as Success<List<LedgerHistoryItem>>).value;
    expect(expenseHistory, hasLength(1));
    expect(expenseHistory.single.transfer, isNull);
    final all = (await runtime.reporting.transactionHistory(
      TransactionHistoryQuery(profileId: profile),
    ) as Success<List<LedgerHistoryItem>>).value;
    expect(all, hasLength(2));

    final report = (await runtime.reporting.incomeExpense(
      query('2026-01-01', '2026-01-31'),
    ) as Success<IncomeExpenseReport>).value;
    final exporter = const CsvReportExporter();
    final reportCsv = exporter.incomeExpense(report).contents;
    expect(reportCsv, contains('"123.45"'));
    expect(reportCsv, contains('"\'=SUM(1,2)\n""食物"""'));
    expect(reportCsv, contains('"complete"'));

    final historyCsv = exporter
        .transactionHistory(
          items: all,
          accounts: {cash.id: cash, bank.id: bank},
          categories: {dangerous.id: dangerous},
          projects: {project.id: project},
        )
        .contents;
    expect(historyCsv, contains('"\'+公式, ""引號""\n第二行"'));
    expect(historyCsv, contains('"@旅行"'.replaceFirst('"@', '"\'@')));
    expect(historyCsv, contains('"transfer"'));
    expect(historyCsv, contains('"5.00"'));
  });
}
