import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/local_profile/data/drift_local_profile_repository.dart';
import 'package:ledger/features/local_profile/domain/local_profile.dart'
    as domain;
import 'package:ledger/infrastructure/local/ledger_database.dart';

final class TestClock implements Clock {
  TestClock(this.instant);
  final DateTime instant;
  @override
  DateTime nowUtc() => instant;
}

final class TestIds implements IdGenerator {
  TestIds(this.id);
  final LocalId id;
  @override
  LocalId generate() => id;
}

void main() {
  final id = LocalId('c64019ee-74e2-4492-b170-45bf48c8f601');
  final instant = DateTime.utc(2026, 9, 20, 12, 0);

  Future<(Directory, LedgerDatabase)> openFile() async {
    final dir = await Directory.systemTemp.createTemp('keev-ledger-db-test-');
    final db = LedgerDatabase(
      NativeDatabase(File('${dir.path}/ledger.sqlite')),
    );
    addTearDown(() async {
      await db.close();
      if (await dir.exists()) await dir.delete(recursive: true);
    });
    return (dir, db);
  }

  test('Empty file creates current schema with FK enforcement', () async {
    final (dir, db) = await openFile();
    final repo = DriftLocalProfileRepository(
      db,
      TestIds(id),
      TestClock(instant),
    );
    final result = await repo.read();
    expect(result, isA<Success<domain.LocalProfile?>>());
    expect((result as Success<domain.LocalProfile?>).value, isNull);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
    final foreignKeys = await db
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(foreignKeys.read<int>('foreign_keys'), 1);
    expect(await File('${dir.path}/ledger.sqlite').exists(), isTrue);
  });

  test(
    'Local profile persists offline with stable ID and UTC timestamps',
    () async {
      final (dir, db) = await openFile();
      final repo = DriftLocalProfileRepository(
        db,
        TestIds(id),
        TestClock(instant),
      );
      final created = await repo.create(baseCurrency: Currency.jpy);
      expect(created, isA<Success<domain.LocalProfile>>());
      expect((created as Success<domain.LocalProfile>).value.id, id);
      await db.close();
      final reopened = LedgerDatabase(
        NativeDatabase(File('${dir.path}/ledger.sqlite')),
      );
      addTearDown(reopened.close);
      final loaded = await DriftLocalProfileRepository(
        reopened,
        TestIds(id),
        TestClock(instant),
      ).read();
      expect(loaded, isA<Success<domain.LocalProfile?>>());
      final profile = (loaded as Success<domain.LocalProfile?>).value!;
      expect(profile.id, id);
      expect(profile.baseCurrency, Currency.jpy);
      expect(profile.createdAtUtc, instant);
      expect(profile.updatedAtUtc, instant);
      expect(profile.createdAtUtc.isUtc, isTrue);
    },
  );

  test('Singleton constraint preserves the existing identity', () async {
    final (_, db) = await openFile();
    final repo = DriftLocalProfileRepository(
      db,
      TestIds(id),
      TestClock(instant),
    );
    expect(
      await repo.create(baseCurrency: Currency.hkd),
      isA<Success<domain.LocalProfile>>(),
    );
    final duplicate = await repo.create(baseCurrency: Currency.usd);
    expect(duplicate, isA<Failure<domain.LocalProfile>>());
    expect(
      (duplicate as Failure<domain.LocalProfile>).code,
      FailureCode.localProfileAlreadyExists,
    );
    expect(
      ((await repo.read()) as Success<domain.LocalProfile?>)
          .value!
          .baseCurrency,
      Currency.hkd,
    );
    expect(await db.select(db.localProfiles).get(), hasLength(1));
  });

  test(
    'SQLite constraints reject invalid currency, slot and timestamps',
    () async {
      final (_, db) = await openFile();
      await db.customSelect('SELECT * FROM local_profiles').get();
      for (final (slot, currency, created, updated) in [
        (2, 'HKD', 1, 1),
        (1, 'XXX', 1, 1),
        (1, 'HKD', 2, 1),
      ]) {
        await expectLater(
          db.customInsert(
            'INSERT INTO local_profiles '
            '(slot, id, base_currency_code, created_at_utc, updated_at_utc) '
            "VALUES ($slot, '${id.value}', '$currency', $created, $updated)",
          ),
          throwsA(isA<SqliteException>()),
        );
      }
      expect(await db.select(db.localProfiles).get(), isEmpty);
    },
  );

  test('Typed failure and exception both roll back all prior writes', () async {
    final (_, db) = await openFile();
    final repo = DriftLocalProfileRepository(
      db,
      TestIds(id),
      TestClock(instant),
    );
    final unit = DriftLocalUnitOfWork(db);
    final failed = await unit.run(() async {
      final first = await repo.create(baseCurrency: Currency.hkd);
      if (first is Failure<domain.LocalProfile>) return first;
      return repo.create(baseCurrency: Currency.usd);
    });
    expect(failed, isA<Failure<domain.LocalProfile>>());
    expect(
      ((await repo.read()) as Success<domain.LocalProfile?>).value,
      isNull,
    );
    await expectLater(
      unit.run<domain.LocalProfile>(() async {
        expect(
          await repo.create(baseCurrency: Currency.hkd),
          isA<Success<domain.LocalProfile>>(),
        );
        // Represents a later command failure after an earlier successful write.
        throw StateError('second write failed');
      }),
      throwsStateError,
    );
    expect(
      ((await repo.read()) as Success<domain.LocalProfile?>).value,
      isNull,
    );
    final committed = await unit.run(
      () => repo.create(baseCurrency: Currency.hkd),
    );
    expect(committed, isA<Success<domain.LocalProfile>>());
    expect(await db.select(db.localProfiles).get(), hasLength(1));
  });
}
