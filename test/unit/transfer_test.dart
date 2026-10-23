import 'dart:io';

import 'package:drift/drift.dart'
    show MigrationStrategy, QueryExecutor, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/application/bookkeeping_service.dart';
import 'package:ledger/features/bookkeeping/application/money_input.dart';
import 'package:ledger/features/bookkeeping/data/drift_bookkeeping_repositories.dart';
import 'package:ledger/features/bookkeeping/data/drift_transfer_repository.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/bookkeeping/domain/transfer.dart';
import 'package:ledger/features/local_profile/data/drift_local_profile_repository.dart';
import 'package:ledger/features/local_profile/domain/local_profile.dart'
    show LocalProfile;
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;

class _V2Database extends LedgerDatabase {
  _V2Database(QueryExecutor executor) : super(executor);
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createTable(localProfiles);
      await m.createTable(accounts);
      await m.createTable(categories);
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
      await customStatement(
        'CREATE INDEX history_profile_date_id ON '
        'bookkeeping_transactions (profile_id, business_date, id)',
      );
    },
  );
}

class _Ids implements IdGenerator {
  int next = 1;
  @override
  LocalId generate() => LocalId(
    '11111111-1111-4111-8111-${(next++).toRadixString(16).padLeft(12, '0')}',
  );
}

class _Clock implements Clock {
  DateTime current = DateTime.utc(2026, 9, 20, 12);
  @override
  DateTime nowUtc() => current;
}

void main() {
  late Directory directory;
  late File file;
  late LedgerDatabase db;
  late _Ids ids;
  late _Clock clock;
  late LocalId profile;
  late BookkeepingService service;
  final day = BusinessDate('2026-09-20');

  BookkeepingService wire() => BookkeepingService(
    profiles: DriftLocalProfileRepository(db, ids, clock),
    accounts: DriftAccountRepository(db),
    categories: DriftCategoryRepository(db),
    entries: DriftEntryRepository(db),
    transfers: DriftTransferRepository(db),
    ids: ids,
    clock: clock,
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('keev-transfer-');
    file = File('${directory.path}/ledger.sqlite');
    db = LedgerDatabase(NativeDatabase(file));
    ids = _Ids();
    clock = _Clock();
    profile = (await DriftLocalProfileRepository(
      db,
      ids,
      clock,
    ).create(baseCurrency: Currency.hkd) as Success<LocalProfile>).value.id;
    service = wire();
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });
  Future<Account> makeAccount(
    String name,
    Currency currency, {
    AccountKind kind = AccountKind.bank,
    int opening = 0,
  }) async => (await service.createAccount(
    profileId: profile,
    name: name,
    kind: kind,
    currency: currency,
    openingBalance: Money.fromMinorUnits(currency, opening),
    openingDate: BusinessDate('2026-09-01'),
  ) as Success<Account>).value;
  Future<Category> makeCategory(EntryKind kind) async =>
      (await service.createCategory(
        profileId: profile,
        name: kind.name,
        kind: kind,
      ) as Success<Category>).value;
  Future<int> balance(Account account) async => (await service.accountBalance(
    profile,
    account.id,
  ) as Success<Money>).value.minorUnits;
  Future<void> reopen() async {
    await db.close();
    db = LedgerDatabase(NativeDatabase(file));
    service = wire();
  }

  test(
    'Same-currency transfer is one event and balances survive restart',
    () async {
      final cash = await makeAccount('Cash', Currency.hkd, opening: 100000);
      final bank = await makeAccount('Bank', Currency.hkd);
      final r = await service.transfer(
        profileId: profile,
        sourceAccountId: cash.id,
        destinationAccountId: bank.id,
        sent: Money.fromMinorUnits(Currency.hkd, 12345),
        businessDate: day,
        note: 'Move',
      );
      final transfer = (r as Success<LedgerTransfer>).value;
      expect(transfer.sent, transfer.received);
      expect(transfer.impliedSourceToDestinationRate, isNull);
      expect(await balance(cash), 87655);
      expect(await balance(bank), 12345);
      expect(await db.select(db.bookkeepingTransactions).get(), isEmpty);
      expect(
        (await service.historyEvents(
          profile,
        ) as Success<List<LedgerHistoryItem>>).value.single.transfer?.id,
        transfer.id,
      );
      await reopen();
      expect(await balance(cash), 87655);
      expect(await balance(bank), 12345);
      expect(
        (await service.historyEvents(
          profile,
        ) as Success<List<LedgerHistoryItem>>).value.single.transfer?.note,
        'Move',
      );
    },
  );

  test('Cross-currency transfer persists both amounts and exact source-to-destination rate', () async {
    final hkd = await makeAccount('HK', Currency.hkd, opening: 100000);
    final usd = await makeAccount('US', Currency.usd);
    final result = await service.transfer(
      profileId: profile,
      sourceAccountId: hkd.id,
      destinationAccountId: usd.id,
      sent: Money.fromMinorUnits(Currency.hkd, 78000),
      received: Money.fromMinorUnits(Currency.usd, 10000),
      businessDate: day,
    );
    final t = (result as Success<LedgerTransfer>).value;
    expect(t.impliedSourceToDestinationRate!.numerator, BigInt.from(5));
    expect(t.impliedSourceToDestinationRate!.denominator, BigInt.from(39));
    expect(t.impliedSourceToDestinationRate!.convert(t.sent), t.received);
    await reopen();
    expect(await balance(hkd), 22000);
    expect(await balance(usd), 10000);
    final loaded = (await service.historyEvents(
      profile,
    ) as Success<List<LedgerHistoryItem>>).value.single.transfer!;
    expect(loaded.sent, Money.fromMinorUnits(Currency.hkd, 78000));
    expect(loaded.received, Money.fromMinorUnits(Currency.usd, 10000));
    expect(loaded.sourceAccountId, hkd.id);
    expect(loaded.destinationAccountId, usd.id);
  });

  test('Rejects same account, missing received amount, zero, wrong account currency and archive', () async {
    final hkd = await makeAccount('HK', Currency.hkd);
    final usd = await makeAccount('US', Currency.usd);
    Future<FailureCode> send(
      LocalId source,
      LocalId target,
      Money sent, {
      Money? received,
    }) async => (await service.transfer(
      profileId: profile,
      sourceAccountId: source,
      destinationAccountId: target,
      sent: sent,
      received: received,
      businessDate: day,
    ) as Failure<LedgerTransfer>).code;
    expect(
      await send(hkd.id, hkd.id, Money.fromMinorUnits(Currency.hkd, 100)),
      FailureCode.sameAccount,
    );
    expect(
      await send(hkd.id, usd.id, Money.fromMinorUnits(Currency.hkd, 100)),
      FailureCode.receivedAmountRequired,
    );
    expect(
      await send(
        hkd.id,
        usd.id,
        Money.zero(Currency.hkd),
        received: Money.fromMinorUnits(Currency.usd, 10),
      ),
      FailureCode.invalidAmount,
    );
    expect(
      await send(
        hkd.id,
        usd.id,
        Money.fromMinorUnits(Currency.usd, 10),
        received: Money.fromMinorUnits(Currency.usd, 10),
      ),
      FailureCode.currencyMismatch,
    );
    expect(
      await service.archiveAccount(profile, hkd.id),
      isA<Success<Account>>(),
    );
    expect(
      await send(
        hkd.id,
        usd.id,
        Money.fromMinorUnits(Currency.hkd, 100),
        received: Money.fromMinorUnits(Currency.usd, 10),
      ),
      FailureCode.accountArchived,
    );
    expect(await db.select(db.transfers).get(), isEmpty);
  });

  test('One atomic transfer rolls back when a later write in the same operation fails', () async {
    final a = await makeAccount('A', Currency.hkd);
    final b = await makeAccount('B', Currency.hkd);
    final unit = DriftLocalUnitOfWork(db);
    final result = await unit.run(() async {
      final first = await service.transfer(
        profileId: profile,
        sourceAccountId: a.id,
        destinationAccountId: b.id,
        sent: Money.fromMinorUnits(Currency.hkd, 100),
        businessDate: day,
      );
      expect(first, isA<Success<LedgerTransfer>>());
      return service.createAccount(
        profileId: LocalId('11111111-1111-4111-8111-000000000099'),
        name: 'Invalid',
        kind: AccountKind.cash,
        currency: Currency.hkd,
        openingBalance: Money.zero(Currency.hkd),
        openingDate: day,
      );
    });
    expect(result, isA<Failure<Account>>());
    expect(await db.select(db.transfers).get(), isEmpty);
    expect(await balance(a), 0);
    expect(await balance(b), 0);
  });

  test('Credit card payment is a transfer without duplicate expense', () async {
    final bank = await makeAccount('Bank', Currency.hkd, opening: 20000);
    final card = await makeAccount(
      'Card',
      Currency.hkd,
      kind: AccountKind.creditCard,
    );
    final expense = await makeCategory(EntryKind.expense);
    expect(
      await service.recordExpense(
        profileId: profile,
        accountId: card.id,
        categoryId: expense.id,
        amount: Money.fromMinorUnits(Currency.hkd, 5000),
        businessDate: day,
      ),
      isA<Success<BookkeepingEntry>>(),
    );
    expect(await balance(card), -5000);
    expect(
      await service.transfer(
        profileId: profile,
        sourceAccountId: bank.id,
        destinationAccountId: card.id,
        sent: Money.fromMinorUnits(Currency.hkd, 5000),
        businessDate: day,
      ),
      isA<Success<LedgerTransfer>>(),
    );
    expect(await balance(bank), 15000);
    expect(await balance(card), 0);
    final events = (await service.historyEvents(
      profile,
    ) as Success<List<LedgerHistoryItem>>).value;
    expect(
      events.where((e) => e.entry?.kind == EntryKind.expense),
      hasLength(1),
    );
    expect(events.where((e) => e.transfer != null), hasLength(1));
  });

  test('Transfer tombstone removes both balance effects together', () async {
    final a = await makeAccount('A', Currency.hkd, opening: 1000);
    final b = await makeAccount('B', Currency.hkd);
    final t = (await service.transfer(
      profileId: profile,
      sourceAccountId: a.id,
      destinationAccountId: b.id,
      sent: Money.fromMinorUnits(Currency.hkd, 250),
      businessDate: day,
    ) as Success<LedgerTransfer>).value;
    clock.current = clock.current.add(const Duration(seconds: 1));
    expect(
      await service.deleteTransfer(profile, t.id),
      isA<Success<LedgerTransfer>>(),
    );
    expect(await balance(a), 1000);
    expect(await balance(b), 0);
    expect(
      (await db.select(db.transfers).get()).single.deletedAtUtc,
      isNotNull,
    );
    expect(
      (await service.historyEvents(
        profile,
      ) as Success<List<LedgerHistoryItem>>).value,
      isEmpty,
    );
  });

  test('Money input enforces precision without floating point', () {
    expect(
      (MoneyInput.parsePositive(
        '123.45',
        Currency.hkd,
      ) as Success<Money>).value.minorUnits,
      12345,
    );
    expect(
      (MoneyInput.parsePositive(
        '123',
        Currency.jpy,
      ) as Success<Money>).value.minorUnits,
      123,
    );
    for (final value in ['0', '-1', '1.234', 'abc', ''])
      expect(
        MoneyInput.parsePositive(value, Currency.hkd),
        isA<Failure<Money>>(),
      );
    expect(
      MoneyInput.parsePositive('1.0', Currency.jpy),
      isA<Failure<Money>>(),
    );
    expect(
      MoneyInput.parsePositive('92233720368547759', Currency.hkd),
      isA<Failure<Money>>(),
    );
  });

  test('Real v2 file migrates without losing profile, account, category or expense', () async {
    await db.close();
    await file.delete();
    db = _V2Database(NativeDatabase(file));
    service = wire();
    profile = (await DriftLocalProfileRepository(
      db,
      ids,
      clock,
    ).create(baseCurrency: Currency.hkd) as Success<LocalProfile>).value.id;
    final oldId = profile.value;
    const oldAccountId = '11111111-1111-4111-8111-000000000081';
    const oldCategoryId = '11111111-1111-4111-8111-000000000082';
    // Seed the historical file directly. Current repositories require sync
    // tables that did not exist in schema v2.
    await db.customInsert(
      'INSERT INTO accounts (id,profile_id,name,kind,currency_code,'
      'opening_minor_units,opening_date,created_at_utc,updated_at_utc) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        oldAccountId,
        oldId,
        'Old',
        'bank',
        'HKD',
        1000,
        '2026-09-01',
        1,
        1,
      ].map(Variable.new).toList(),
    );
    await db.customInsert(
      'INSERT INTO categories (id,profile_id,name,kind,created_at_utc,'
      'updated_at_utc) VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        oldCategoryId,
        oldId,
        'expense',
        'expense',
        1,
        1,
      ].map(Variable.new).toList(),
    );
    const entryId = '11111111-1111-4111-8111-000000000099';
    await db.customInsert(
      'INSERT INTO bookkeeping_transactions '
      '(id,profile_id,account_id,category_id,kind,amount_minor_units,'
      'currency_code,business_date,created_at_utc,updated_at_utc) VALUES '
      "('$entryId','${profile.value}','$oldAccountId','$oldCategoryId',"
      "'expense',125,'HKD','${day.value}',1,1)",
    );
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      2,
    );
    await reopen();
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      db.schemaVersion,
    );
    final a = (await service.listAccounts(
      profile,
    ) as Success<List<Account>>).value.single;
    expect((await db.select(db.localProfiles).get()).single.id, oldId);
    expect((await db.select(db.accounts).get()).single.id, oldAccountId);
    expect((await db.select(db.categories).get()).single.id, oldCategoryId);
    expect(
      (await db.select(db.bookkeepingTransactions).get()).single.id,
      entryId,
    );
    expect(await db.select(db.transfers).get(), isEmpty);
    expect(await balance(a), 875);
    await reopen();
    expect(await balance(a), 875);
  });
}
