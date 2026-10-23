import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/receipts/application/receipt_contracts.dart';
import 'package:ledger/features/receipts/application/receipt_service.dart';
import 'package:ledger/features/receipts/data/drift_receipt_repository.dart';
import 'package:ledger/features/receipts/domain/receipt_attachment.dart';
import 'package:ledger/features/receipts/infrastructure/local_receipt_file_store.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 21, 12);
}

final class _CancelledPicker implements ReceiptImageAcquirer {
  @override
  Future<Result<AcquiredReceipt?>> acquire(
    ReceiptAcquisitionSource source,
  ) async => const Success(null);
  @override
  Future<Result<AcquiredReceipt?>> recoverInterrupted() async =>
      const Success(null);
}

final class _FailOnceRepository implements ReceiptAttachmentRepository {
  _FailOnceRepository(this.delegate);
  final ReceiptAttachmentRepository delegate;
  bool fail = true;
  @override
  Future<Result<ReceiptAttachment>> create(ReceiptAttachment value) {
    if (fail) {
      fail = false;
      return Future.value(const Failure(FailureCode.localStoreUnavailable));
    }
    return delegate.create(value);
  }

  @override
  Future<Result<List<ReceiptAttachment>>> list(
    LocalId profileId,
    LocalId transactionId,
  ) => delegate.list(profileId, transactionId);
  @override
  Future<Result<List<ReceiptAttachment>>> listAll(LocalId profileId) =>
      delegate.listAll(profileId);
  @override
  Future<Result<ReceiptAttachment>> remove(
    LocalId profileId,
    LocalId attachmentId,
  ) => delegate.remove(profileId, attachmentId);
}

void main() {
  late Directory root;
  late LedgerDatabase db;
  late BookkeepingRuntime runtime;
  late LocalId profile;
  late Account account;
  late Category category;
  late LocalReceiptFileStore store;
  late ReceiptService receipts;

  Future<File> validImage([String name = 'source.png']) async {
    final value = image.Image(width: 2400, height: 1200);
    image.fill(value, color: image.ColorRgb8(245, 245, 245));
    final file = File('${root.path}/$name');
    await file.writeAsBytes(image.encodePng(value));
    return file;
  }

  ReceiptService makeService(ReceiptAttachmentRepository repository) =>
      ReceiptService(
        bookkeeping: runtime.service,
        repository: repository,
        files: store,
        acquirer: _CancelledPicker(),
        ids: SecureUuidV4Generator(),
        clock: _Clock(),
      );

  setUp(() async {
    root = await Directory.systemTemp.createTemp('keev-receipts-');
    db = LedgerDatabase(NativeDatabase.memory());
    runtime = BookkeepingRuntime(db);
    profile = (await runtime.profile() as Success<LocalId>).value;
    account = (await runtime.service.createAccount(
      profileId: profile,
      name: 'Cash',
      kind: AccountKind.cash,
      currency: Currency.hkd,
      openingBalance: Money.zero(Currency.hkd),
      openingDate: BusinessDate('2026-01-01'),
    ) as Success<Account>).value;
    category = (await runtime.service.createCategory(
      profileId: profile,
      name: 'Food',
      kind: EntryKind.expense,
    ) as Success<Category>).value;
    store = LocalReceiptFileStore(
      directoryProvider: () async => Directory('${root.path}/owned'),
    );
    receipts = makeService(DriftReceiptAttachmentRepository(db));
  });

  tearDown(() async {
    await runtime.close();
    await root.delete(recursive: true);
  });

  Future<BookkeepingEntry> entry() async =>
      (await runtime.service.recordExpense(
        profileId: profile,
        accountId: account.id,
        categoryId: category.id,
        amount: Money.fromMinorUnits(Currency.hkd, 1234),
        businessDate: BusinessDate('2026-09-21'),
      ) as Success<BookkeepingEntry>).value;

  test('processed file and stable metadata persist and reload', () async {
    final saved = await receipts.recordExpenseWithReceipts(
      profileId: profile,
      accountId: account.id,
      categoryId: category.id,
      amount: Money.fromMinorUnits(Currency.hkd, 1234),
      businessDate: BusinessDate('2026-09-21'),
      receiptSources: [await validImage()],
    );
    final transaction = (saved as Success<BookkeepingEntry>).value;
    final rows = (await receipts.list(
      profile,
      transaction.id,
    ) as Success<List<ReceiptAttachment>>).value;
    expect(rows, hasLength(1));
    expect(rows.single.transactionId, transaction.id);
    expect(
      rows.single.byteSize,
      lessThanOrEqualTo(maximumProcessedReceiptBytes),
    );
    expect(rows.single.sha256Hex, hasLength(64));
    final file = (await receipts.resolve(rows.single) as Success<File>).value;
    expect(await file.exists(), isTrue);
    expect(image.decodeJpg(await file.readAsBytes())!.width, 2048);
    expect(
      await receipts.remove(profile, rows.single.id),
      isA<Success<void>>(),
    );
    expect(await file.exists(), isFalse);
    expect(
      (await receipts.list(
        profile,
        transaction.id,
      ) as Success<List<ReceiptAttachment>>).value,
      isEmpty,
    );
  });

  test('five-attachment limit is authoritative in repository', () async {
    final transaction = await entry();
    for (var index = 0; index < 5; index++) {
      expect(
        await receipts.attach(
          profileId: profile,
          transactionId: transaction.id,
          source: await validImage('source-$index.png'),
        ),
        isA<Success<ReceiptAttachment>>(),
      );
    }
    final sixth = await receipts.attach(
      profileId: profile,
      transactionId: transaction.id,
      source: await validImage('sixth.png'),
    );
    expect((sixth as Failure).code, FailureCode.attachmentLimitReached);
  });

  test(
    'invalid, missing and oversized sources fail without a durable file',
    () async {
      final transaction = await entry();
      final invalid = File('${root.path}/invalid.jpg')
        ..writeAsStringSync('no image');
      expect(
        (await receipts.attach(
          profileId: profile,
          transactionId: transaction.id,
          source: invalid,
        ) as Failure).code,
        FailureCode.attachmentInvalidImage,
      );
      expect(
        (await receipts.attach(
          profileId: profile,
          transactionId: transaction.id,
          source: File('${root.path}/missing.png'),
        ) as Failure).code,
        FailureCode.attachmentNotFound,
      );
      final bounded = LocalReceiptFileStore(
        directoryProvider: () async => Directory('${root.path}/bounded'),
        maximumSourceBytes: 2,
      );
      expect(
        (await bounded.importImage(
          await validImage('large.png'),
          account.id.value,
        ) as Failure).code,
        FailureCode.attachmentTooLarge,
      );
    },
  );

  test('reconciliation removes staging/orphans and missing metadata', () async {
    final transaction = await entry();
    final attached = (await receipts.attach(
      profileId: profile,
      transactionId: transaction.id,
      source: await validImage(),
    ) as Success<ReceiptAttachment>).value;
    final owned = Directory('${root.path}/owned');
    await File('${owned.path}/${attached.storageKey}').delete();
    await File('${owned.path}/00000000-0000-4000-8000-000000000099.pending')
        .writeAsString('partial');
    await File('${owned.path}/00000000-0000-4000-8000-000000000098.jpg')
        .writeAsString('orphan');
    final result = (await receipts.reconcile(
      profile,
    ) as Success<ReceiptReconciliation>).value;
    expect(result.removedStaging, 1);
    expect(result.removedOrphans, 1);
    expect(result.missingReferences, contains(attached.storageKey));
    expect(
      (await receipts.list(
        profile,
        transaction.id,
      ) as Success<List<ReceiptAttachment>>).value,
      isEmpty,
    );
  });

  test(
    'DB failure cleans file, tombstones entry, and retry has one active entry',
    () async {
      final failing = makeService(
        _FailOnceRepository(DriftReceiptAttachmentRepository(db)),
      );
      final source = await validImage();
      final failed = await failing.recordExpenseWithReceipts(
        profileId: profile,
        accountId: account.id,
        categoryId: category.id,
        amount: Money.fromMinorUnits(Currency.hkd, 100),
        businessDate: BusinessDate('2026-09-21'),
        receiptSources: [source],
      );
      expect(failed, isA<Failure<BookkeepingEntry>>());
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value,
        isEmpty,
      );
      final retried = await failing.recordExpenseWithReceipts(
        profileId: profile,
        accountId: account.id,
        categoryId: category.id,
        amount: Money.fromMinorUnits(Currency.hkd, 100),
        businessDate: BusinessDate('2026-09-21'),
        receiptSources: [source],
      );
      expect(retried, isA<Success<BookkeepingEntry>>());
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value,
        hasLength(1),
      );
      expect(
        await failing.acquirer.acquire(ReceiptAcquisitionSource.camera),
        isA<Success<AcquiredReceipt?>>(),
      );
    },
  );
}
