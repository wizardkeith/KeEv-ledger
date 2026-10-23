// dart format width=80
// ignore_for_file: unused_local_variable, unused_import,prefer_const_constructors,avoid_dynamic_calls
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = LedgerDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test(
    'migration from v1 to v2 preserves local identity and timestamps',
    () async {
      const oldLocalProfilesData = [
        v1.LocalProfilesData(
          slot: 1,
          id: 'c64019ee-74e2-4492-b170-45bf48c8f601',
          baseCurrencyCode: 'JPY',
          createdAtUtc: 100,
          updatedAtUtc: 200,
        ),
      ];
      const expectedNewLocalProfilesData = [
        v2.LocalProfilesData(
          slot: 1,
          id: 'c64019ee-74e2-4492-b170-45bf48c8f601',
          baseCurrencyCode: 'JPY',
          createdAtUtc: 100,
          updatedAtUtc: 200,
        ),
      ];

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: LedgerDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.localProfiles, oldLocalProfilesData);
        },
        validateItems: (newDb) async {
          expect(
            expectedNewLocalProfilesData,
            await newDb.select(newDb.localProfiles).get(),
          );
        },
      );
    },
  );

  test('migration from v3 to v4 preserves all bookkeeping records', () async {
    const profileId = 'c64019ee-74e2-4492-b170-45bf48c8f601';
    const accountA = '00000000-0000-4000-8000-000000000001';
    const accountB = '00000000-0000-4000-8000-000000000002';
    const categoryId = '00000000-0000-4000-8000-000000000003';
    const entryId = '00000000-0000-4000-8000-000000000004';
    const transferId = '00000000-0000-4000-8000-000000000005';
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: LedgerDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.localProfiles,
          const v3.LocalProfilesData(
            slot: 1,
            id: profileId,
            baseCurrencyCode: 'HKD',
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insertAll(oldDb.accounts, const [
          v3.AccountsData(
            id: accountA,
            profileId: profileId,
            name: 'Cash',
            kind: 'cash',
            currencyCode: 'HKD',
            openingMinorUnits: 10000,
            openingDate: '2026-01-01',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
          v3.AccountsData(
            id: accountB,
            profileId: profileId,
            name: 'Bank',
            kind: 'bank',
            currencyCode: 'HKD',
            openingMinorUnits: 0,
            openingDate: '2026-01-01',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        ]);
        batch.insert(
          oldDb.categories,
          const v3.CategoriesData(
            id: categoryId,
            profileId: profileId,
            name: 'Food',
            kind: 'expense',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insert(
          oldDb.bookkeepingTransactions,
          const v3.BookkeepingTransactionsData(
            id: entryId,
            profileId: profileId,
            accountId: accountA,
            categoryId: categoryId,
            kind: 'expense',
            amountMinorUnits: 125,
            currencyCode: 'HKD',
            businessDate: '2026-01-02',
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insert(
          oldDb.transfers,
          const v3.TransfersData(
            id: transferId,
            profileId: profileId,
            sourceAccountId: accountA,
            destinationAccountId: accountB,
            sourceMinorUnits: 250,
            sourceCurrencyCode: 'HKD',
            destinationMinorUnits: 250,
            destinationCurrencyCode: 'HKD',
            businessDate: '2026-01-03',
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
      },
      validateItems: (newDb) async {
        expect(
          (await newDb.select(newDb.localProfiles).get()).single.id,
          profileId,
        );
        expect(await newDb.select(newDb.accounts).get(), hasLength(2));
        expect(
          (await newDb.select(newDb.categories).get()).single.id,
          categoryId,
        );
        final entry =
            (await newDb.select(newDb.bookkeepingTransactions).get()).single;
        expect(entry.id, entryId);
        expect(entry.projectId, null);
        expect(
          (await newDb.select(newDb.transfers).get()).single.id,
          transferId,
        );
        expect(await newDb.select(newDb.projects).get(), isEmpty);
        expect(await newDb.select(newDb.budgets).get(), isEmpty);
      },
    );
  });

  test('migration from v4 to v5 preserves Phase 3B data and reopens', () async {
    const profile = 'c64019ee-74e2-4492-b170-45bf48c8f601';
    const account = '00000000-0000-4000-8000-000000000011';
    const destination = '00000000-0000-4000-8000-000000000012';
    const category = '00000000-0000-4000-8000-000000000013';
    const project = '00000000-0000-4000-8000-000000000014';
    const entry = '00000000-0000-4000-8000-000000000015';
    const transfer = '00000000-0000-4000-8000-000000000016';
    const budget = '00000000-0000-4000-8000-000000000017';
    await verifier.testWithDataIntegrity(
      oldVersion: 4,
      newVersion: 5,
      createOld: v4.DatabaseAtV4.new,
      createNew: v5.DatabaseAtV5.new,
      openTestedDatabase: LedgerDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.localProfiles,
          const v4.LocalProfilesData(
            slot: 1,
            id: profile,
            baseCurrencyCode: 'HKD',
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insertAll(oldDb.accounts, const [
          v4.AccountsData(
            id: account,
            profileId: profile,
            name: 'Cash',
            kind: 'cash',
            currencyCode: 'HKD',
            openingMinorUnits: 1000,
            openingDate: '2026-01-01',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
          v4.AccountsData(
            id: destination,
            profileId: profile,
            name: 'Bank',
            kind: 'bank',
            currencyCode: 'HKD',
            openingMinorUnits: 0,
            openingDate: '2026-01-01',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        ]);
        batch.insert(
          oldDb.categories,
          const v4.CategoriesData(
            id: category,
            profileId: profile,
            name: 'Food',
            kind: 'expense',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insert(
          oldDb.projects,
          const v4.ProjectsData(
            id: project,
            profileId: profile,
            name: 'Trip',
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insert(
          oldDb.bookkeepingTransactions,
          const v4.BookkeepingTransactionsData(
            id: entry,
            profileId: profile,
            accountId: account,
            categoryId: category,
            projectId: project,
            kind: 'expense',
            amountMinorUnits: 100,
            currencyCode: 'HKD',
            businessDate: '2026-09-01',
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insert(
          oldDb.transfers,
          const v4.TransfersData(
            id: transfer,
            profileId: profile,
            sourceAccountId: account,
            destinationAccountId: destination,
            sourceMinorUnits: 50,
            sourceCurrencyCode: 'HKD',
            destinationMinorUnits: 50,
            destinationCurrencyCode: 'HKD',
            businessDate: '2026-09-02',
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
        batch.insert(
          oldDb.budgets,
          const v4.BudgetsData(
            id: budget,
            profileId: profile,
            name: 'Food budget',
            amountMinorUnits: 10000,
            currencyCode: 'HKD',
            month: '2026-09',
            categoryId: category,
            warningThresholdPercent: 80,
            isArchived: 0,
            createdAtUtc: 100,
            updatedAtUtc: 100,
          ),
        );
      },
      validateItems: (newDb) async {
        expect(
          (await newDb.select(newDb.localProfiles).get()).single.id,
          profile,
        );
        expect(await newDb.select(newDb.accounts).get(), hasLength(2));
        expect(
          (await newDb.select(newDb.categories).get()).single.id,
          category,
        );
        expect((await newDb.select(newDb.projects).get()).single.id, project);
        expect(
          (await newDb.select(newDb.bookkeepingTransactions).get()).single.id,
          entry,
        );
        expect((await newDb.select(newDb.transfers).get()).single.id, transfer);
        expect((await newDb.select(newDb.budgets).get()).single.id, budget);
        expect(await newDb.select(newDb.receiptAttachments).get(), isEmpty);
      },
    );
  });

  test(
    'migration from v5 to v6 preserves ledger and starts sync disabled',
    () async {
      const profile = 'c64019ee-74e2-4492-b170-45bf48c8f601';
      const accountA = '00000000-0000-4000-8000-000000000021';
      const accountB = '00000000-0000-4000-8000-000000000022';
      const category = '00000000-0000-4000-8000-000000000023';
      const project = '00000000-0000-4000-8000-000000000024';
      const entry = '00000000-0000-4000-8000-000000000025';
      const transfer = '00000000-0000-4000-8000-000000000026';
      const budget = '00000000-0000-4000-8000-000000000027';
      const receipt = '00000000-0000-4000-8000-000000000028';

      await verifier.testWithDataIntegrity(
        oldVersion: 5,
        newVersion: 6,
        createOld: v5.DatabaseAtV5.new,
        createNew: v6.DatabaseAtV6.new,
        openTestedDatabase: LedgerDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(
            oldDb.localProfiles,
            const v5.LocalProfilesData(
              slot: 1,
              id: profile,
              baseCurrencyCode: 'HKD',
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          );
          batch.insertAll(oldDb.accounts, const [
            v5.AccountsData(
              id: accountA,
              profileId: profile,
              name: 'Cash',
              kind: 'cash',
              currencyCode: 'HKD',
              openingMinorUnits: 1000,
              openingDate: '2026-01-01',
              isArchived: 0,
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
            v5.AccountsData(
              id: accountB,
              profileId: profile,
              name: 'Bank',
              kind: 'bank',
              currencyCode: 'HKD',
              openingMinorUnits: 0,
              openingDate: '2026-01-01',
              isArchived: 0,
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          ]);
          batch.insert(
            oldDb.categories,
            const v5.CategoriesData(
              id: category,
              profileId: profile,
              name: 'Food',
              kind: 'expense',
              isArchived: 0,
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          );
          batch.insert(
            oldDb.projects,
            const v5.ProjectsData(
              id: project,
              profileId: profile,
              name: 'Trip',
              isArchived: 0,
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          );
          batch.insert(
            oldDb.bookkeepingTransactions,
            const v5.BookkeepingTransactionsData(
              id: entry,
              profileId: profile,
              accountId: accountA,
              categoryId: category,
              projectId: project,
              kind: 'expense',
              amountMinorUnits: 100,
              currencyCode: 'HKD',
              businessDate: '2026-09-01',
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          );
          batch.insert(
            oldDb.transfers,
            const v5.TransfersData(
              id: transfer,
              profileId: profile,
              sourceAccountId: accountA,
              destinationAccountId: accountB,
              sourceMinorUnits: 50,
              sourceCurrencyCode: 'HKD',
              destinationMinorUnits: 50,
              destinationCurrencyCode: 'HKD',
              businessDate: '2026-09-02',
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          );
          batch.insert(
            oldDb.budgets,
            const v5.BudgetsData(
              id: budget,
              profileId: profile,
              name: 'Food budget',
              amountMinorUnits: 10000,
              currencyCode: 'HKD',
              month: '2026-09',
              categoryId: category,
              warningThresholdPercent: 80,
              isArchived: 0,
              createdAtUtc: 100,
              updatedAtUtc: 100,
            ),
          );
          batch.insert(
            oldDb.receiptAttachments,
            const v5.ReceiptAttachmentsData(
              id: receipt,
              profileId: profile,
              transactionId: entry,
              storageKey: 'receipts/example.jpg',
              mimeType: 'image/jpeg',
              byteSize: 128,
              sha256Hex:
                  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
              position: 0,
              createdAtUtc: 100,
            ),
          );
        },
        validateItems: (newDb) async {
          expect(await newDb.select(newDb.accounts).get(), hasLength(2));
          expect(await newDb.select(newDb.categories).get(), hasLength(1));
          expect(await newDb.select(newDb.projects).get(), hasLength(1));
          expect(
            await newDb.select(newDb.bookkeepingTransactions).get(),
            hasLength(1),
          );
          expect(await newDb.select(newDb.transfers).get(), hasLength(1));
          expect(await newDb.select(newDb.budgets).get(), hasLength(1));
          expect(
            await newDb.select(newDb.receiptAttachments).get(),
            hasLength(1),
          );
          final link = (await newDb.select(newDb.syncLinkStates).get()).single;
          expect(link.state, 'unlinked');
          expect(link.syncEnabled, 0);
          expect(link.cloudAccountId, equals(null));
          expect(await newDb.select(newDb.syncOutbox).get(), isEmpty);
          expect(
            await newDb.select(newDb.syncDeviceStates).get(),
            hasLength(1),
          );
        },
      );
    },
  );

  test('migration from v6 to v7 preserves pending outbox identity', () async {
    const mutation = '11111111-1111-4111-8111-111111111111';
    const entity = '22222222-2222-4222-8222-222222222222';
    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: 7,
      createOld: v6.DatabaseAtV6.new,
      createNew: v7.DatabaseAtV7.new,
      openTestedDatabase: LedgerDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.syncOutbox,
          const v6.SyncOutboxCompanion(
            mutationId: Value(mutation),
            entityType: Value('account'),
            entityId: Value(entity),
            operation: Value('update'),
            baseServerVersion: Value(3),
            payloadJson: Value('{"name":"Offline"}'),
            state: Value('pending'),
            createdAtUtc: Value(10),
          ),
        );
      },
      validateItems: (newDb) async {
        final row = await newDb.customSelect(
          'SELECT mutation_id, base_server_version, attempt_count, state '
          'FROM sync_outbox',
        ).getSingle();
        expect(row.read<String>('mutation_id'), mutation);
        expect(row.read<int>('base_server_version'), 3);
        expect(row.read<int>('attempt_count'), 0);
        expect(row.read<String>('state'), 'pending');
        expect(
          await newDb
              .customSelect('SELECT * FROM sync_receipt_spool_entries')
              .get(),
          isEmpty,
        );
        expect(
          await newDb.customSelect('SELECT * FROM sync_attachment_cleanup').get(),
          isEmpty,
        );
      },
    );
  });
}
