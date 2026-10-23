import 'dart:io';

import 'package:drift/drift.dart' show MigrationStrategy, QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/application/bookkeeping_service.dart';
import 'package:ledger/features/bookkeeping/data/drift_bookkeeping_repositories.dart';
import 'package:ledger/features/bookkeeping/data/drift_transfer_repository.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/local_profile/data/drift_local_profile_repository.dart';
import 'package:ledger/features/local_profile/domain/local_profile.dart'
    show LocalProfile;
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;

final class _Ids implements IdGenerator {
  var next = 1;
  @override
  LocalId generate() => LocalId(
    '00000000-0000-4000-8000-${(next++).toRadixString(16).padLeft(12, '0')}',
  );
}

final class _Clock implements Clock {
  var instant = DateTime.utc(2026, 9, 20, 12);
  @override
  DateTime nowUtc() => instant;
}

// This creates a real on-disk v1 database with the unchanged Phase 2A table.
final class _VersionOneDatabase extends LedgerDatabase {
  _VersionOneDatabase(QueryExecutor executor) : super(executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createTable(localProfiles));
}

void main() {
  final day = BusinessDate('2026-09-20');
  final opening = BusinessDate('2026-09-01');
  late Directory directory;
  late File file;
  late LedgerDatabase db;
  late _Ids ids;
  late _Clock clock;
  late BookkeepingService service;
  late LocalId profile;

  Future<void> reopen() async {
    await db.close();
    db = LedgerDatabase(NativeDatabase(file));
    service = BookkeepingService(
      profiles: DriftLocalProfileRepository(db, ids, clock),
      accounts: DriftAccountRepository(db),
      categories: DriftCategoryRepository(db),
      entries: DriftEntryRepository(db),
      transfers: DriftTransferRepository(db),
      ids: ids,
      clock: clock,
    );
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('keev-bookkeeping-');
    file = File('${directory.path}/ledger.sqlite');
    db = LedgerDatabase(NativeDatabase(file));
    ids = _Ids();
    clock = _Clock();
    final created = await DriftLocalProfileRepository(
      db,
      ids,
      clock,
    ).create(baseCurrency: Currency.hkd);
    profile = (created as Success<LocalProfile>).value.id;
    service = BookkeepingService(
      profiles: DriftLocalProfileRepository(db, ids, clock),
      accounts: DriftAccountRepository(db),
      categories: DriftCategoryRepository(db),
      entries: DriftEntryRepository(db),
      transfers: DriftTransferRepository(db),
      ids: ids,
      clock: clock,
    );
  });

  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  Future<Account> account({
    Currency currency = Currency.hkd,
    int amount = 10000,
  }) async {
    final result = await service.createAccount(
      profileId: profile,
      name: 'Wallet',
      kind: AccountKind.cash,
      currency: currency,
      openingBalance: Money.fromMinorUnits(currency, amount),
      openingDate: opening,
    );
    return (result as Success<Account>).value;
  }

  Future<Category> category(EntryKind kind) async {
    final result = await service.createCategory(
      profileId: profile,
      name: kind.name,
      kind: kind,
    );
    return (result as Success<Category>).value;
  }

  Future<BookkeepingEntry> record(
    Account a,
    Category c,
    EntryKind kind,
    int amount,
  ) async {
    final value = Money.fromMinorUnits(a.currency, amount);
    final result = kind == EntryKind.income
        ? await service.recordIncome(
            profileId: profile,
            accountId: a.id,
            categoryId: c.id,
            amount: value,
            businessDate: day,
          )
        : await service.recordExpense(
            profileId: profile,
            accountId: a.id,
            categoryId: c.id,
            amount: value,
            businessDate: day,
          );
    return (result as Success<BookkeepingEntry>).value;
  }

  test(
    'Account and category reload with opening balance, currency and ownership',
    () async {
      final a = await account(currency: Currency.jpy, amount: 500);
      final c = await category(EntryKind.expense);
      await reopen();
      final loaded = (await service.listAccounts(
        profile,
      ) as Success<List<Account>>).value.single;
      expect(loaded.id, a.id);
      expect(loaded.profileId, profile);
      expect(loaded.openingBalance, Money.fromMinorUnits(Currency.jpy, 500));
      expect(
        (await service.accountBalance(
          profile,
          a.id,
        ) as Success<Money>).value.minorUnits,
        500,
      );
      expect(
        (await service.listCategories(
          profile,
          kind: EntryKind.expense,
        ) as Success<List<Category>>).value.single.id,
        c.id,
      );
      expect(
        (await service.listCategories(
          profile,
          kind: EntryKind.income,
        ) as Success<List<Category>>).value,
        isEmpty,
      );
    },
  );

  test('Income and expense persist, balance derives on restart, history has stable order', () async {
    final a = await account();
    final income = await category(EntryKind.income);
    final expense = await category(EntryKind.expense);
    final first = await record(a, income, EntryKind.income, 125);
    await record(a, expense, EntryKind.expense, 75);
    await record(a, income, EntryKind.income, 25);
    await reopen();
    expect(
      (await service.accountBalance(
        profile,
        a.id,
      ) as Success<Money>).value.minorUnits,
      10075,
    );
    final history = (await service.history(
      profile,
    ) as Success<List<BookkeepingEntry>>).value;
    expect(history, hasLength(3));
    expect(
      history.map((e) => e.id.value).toList(),
      orderedEquals(
        history.map((e) => e.id.value).toList()..sort((a, b) => b.compareTo(a)),
      ),
    );
    expect(
      (await service.history(
        profile,
        accountId: a.id,
      ) as Success<List<BookkeepingEntry>>).value,
      hasLength(3),
    );
    expect(
      (await DriftEntryRepository(db).get(
        profile,
        first.id,
      ) as Success<BookkeepingEntry?>).value!.amount.minorUnits,
      125,
    );
  });

  test(
    'Rejects invalid currency, kind, date, and amount without partial writes',
    () async {
      final a = await account();
      final income = await category(EntryKind.income);
      final expense = await category(EntryKind.expense);
      Future<FailureCode> attempt(
        Category c,
        Money value,
        BusinessDate date,
      ) async {
        final r = await service.recordExpense(
          profileId: profile,
          accountId: a.id,
          categoryId: c.id,
          amount: value,
          businessDate: date,
        );
        return (r as Failure<BookkeepingEntry>).code;
      }

      expect(
        await attempt(income, Money.fromMinorUnits(Currency.hkd, 1), day),
        FailureCode.categoryKindMismatch,
      );
      expect(
        await attempt(expense, Money.fromMinorUnits(Currency.jpy, 1), day),
        FailureCode.currencyMismatch,
      );
      expect(
        await attempt(
          expense,
          Money.fromMinorUnits(Currency.hkd, 1),
          BusinessDate('2026-08-31'),
        ),
        FailureCode.dateBeforeOpening,
      );
      await expectLater(
        service.recordExpense(
          profileId: profile,
          accountId: a.id,
          categoryId: expense.id,
          amount: Money.zero(Currency.hkd),
          businessDate: day,
        ),
        throwsArgumentError,
      );
      expect(
        (await service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value,
        isEmpty,
      );
      expect(
        (await service.accountBalance(
          profile,
          a.id,
        ) as Success<Money>).value.minorUnits,
        10000,
      );
      expect(
        (await service.createAccount(
          profileId: ids.generate(),
          name: 'No owner',
          kind: AccountKind.cash,
          currency: Currency.hkd,
          openingBalance: Money.zero(Currency.hkd),
          openingDate: opening,
        ) as Failure<Account>).code,
        FailureCode.profileNotFound,
      );
    },
  );

  test('Archive blocks new use, deletion tombstones preserve references and revise balance', () async {
    final a = await account();
    final expense = await category(EntryKind.expense);
    final entry = await record(a, expense, EntryKind.expense, 30);
    clock.instant = clock.instant.add(const Duration(seconds: 1));
    expect(
      await service.deleteEntry(profile, entry.id),
      isA<Success<BookkeepingEntry>>(),
    );
    expect(
      (await service.history(profile) as Success<List<BookkeepingEntry>>).value,
      isEmpty,
    );
    expect(
      (await service.accountBalance(
        profile,
        a.id,
      ) as Success<Money>).value.minorUnits,
      10000,
    );
    expect(
      (await db.select(db.bookkeepingTransactions).get()).single.deletedAtUtc,
      isNotNull,
    );
    expect(
      await service.archiveCategory(profile, expense.id),
      isA<Success<Category>>(),
    );
    expect(
      (await service.listCategories(profile) as Success<List<Category>>).value,
      isEmpty,
    );
    expect(
      (await service.recordExpense(
        profileId: profile,
        accountId: a.id,
        categoryId: expense.id,
        amount: Money.fromMinorUnits(Currency.hkd, 1),
        businessDate: day,
      ) as Failure<BookkeepingEntry>).code,
      FailureCode.categoryArchived,
    );
    expect(
      await service.archiveAccount(profile, a.id),
      isA<Success<Account>>(),
    );
    expect(
      (await service.listAccounts(profile) as Success<List<Account>>).value,
      isEmpty,
    );
    expect(
      (await service.accountBalance(
        profile,
        a.id,
      ) as Success<Money>).value.minorUnits,
      10000,
    );
  });

  test('SQLite foreign keys and amount CHECK reject invalid direct writes', () async {
    await account();
    final tx = db.bookkeepingTransactions;
    expect(tx.actualTableName, 'bookkeeping_transactions');
    await expectLater(
      db.customInsert(
        "INSERT INTO categories (id,profile_id,name,kind,is_archived,created_at_utc,updated_at_utc) VALUES ('00000000-0000-4000-8000-000000000099','00000000-0000-4000-8000-000000000098','Food','expense',0,1,1)",
      ),
      throwsA(isA<SqliteException>()),
    );
    final a = await account();
    final c = await category(EntryKind.expense);
    await expectLater(
      db.customInsert(
        "INSERT INTO bookkeeping_transactions (id,profile_id,account_id,category_id,kind,amount_minor_units,currency_code,business_date,created_at_utc,updated_at_utc) VALUES ('00000000-0000-4000-8000-000000000099','${profile.value}','${a.id.value}','${c.id.value}','expense',0,'HKD','2026-09-20',1,1)",
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(await db.select(tx).get(), isEmpty);
  });

  test('v1 on-disk profile migrates to current schema, preserves identity and reopens', () async {
    await db.close();
    await file.delete();
    final v1 = _VersionOneDatabase(NativeDatabase(file));
    final v1Id = (await DriftLocalProfileRepository(v1, _Ids(), clock).create(
      baseCurrency: Currency.jpy,
    ) as Success<LocalProfile>).value.id.value;
    expect(
      (await v1.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      1,
    );
    await v1.close();
    db = LedgerDatabase(NativeDatabase(file));
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      db.schemaVersion,
    );
    expect(
      (await db.select(db.localProfiles).get()).single.baseCurrencyCode,
      'JPY',
    );
    expect((await db.select(db.localProfiles).get()).single.id, v1Id);
    expect(await db.select(db.accounts).get(), isEmpty);
    await reopen();
    expect(
      (await db.select(db.localProfiles).get()).single.baseCurrencyCode,
      'JPY',
    );
    expect((await db.select(db.localProfiles).get()).single.id, v1Id);
  });

  test('Large integer and credit-card balances remain exact', () async {
    final big = Money.maxMinorUnits - 100;
    final credit = (await service.createAccount(
      profileId: profile,
      name: 'Credit',
      kind: AccountKind.creditCard,
      currency: Currency.hkd,
      openingBalance: Money.fromMinorUnits(Currency.hkd, -500),
      openingDate: opening,
    ) as Success<Account>).value;
    final expense = await category(EntryKind.expense);
    await record(credit, expense, EntryKind.expense, 250);
    expect(
      (await service.accountBalance(
        profile,
        credit.id,
      ) as Success<Money>).value.minorUnits,
      -750,
    );
    final high = await account(amount: big);
    final income = await category(EntryKind.income);
    await record(high, income, EntryKind.income, 75);
    await reopen();
    expect(
      (await service.accountBalance(
        profile,
        high.id,
      ) as Success<Money>).value.minorUnits,
      big + 75,
    );
  });

  test('Multi-write failure rolls back earlier account insertion', () async {
    final unit = DriftLocalUnitOfWork(db);
    final r = await unit.run(() async {
      final first = await service.createAccount(
        profileId: profile,
        name: 'One',
        kind: AccountKind.cash,
        currency: Currency.hkd,
        openingBalance: Money.zero(Currency.hkd),
        openingDate: opening,
      );
      expect(first, isA<Success<Account>>());
      return service.createAccount(
        profileId: LocalId('00000000-0000-4000-8000-000000000099'),
        name: 'Invalid',
        kind: AccountKind.cash,
        currency: Currency.hkd,
        openingBalance: Money.zero(Currency.hkd),
        openingDate: opening,
      );
    });
    expect(r, isA<Failure<Account>>());
    expect(
      (await service.listAccounts(profile) as Success<List<Account>>).value,
      isEmpty,
    );
  });
}
