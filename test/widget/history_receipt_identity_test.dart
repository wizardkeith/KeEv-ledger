import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/bookkeeping/presentation/history_view.dart';
import 'package:ledger/features/receipts/domain/receipt_attachment.dart';
import 'package:ledger/features/receipts/application/receipt_contracts.dart';
import 'package:ledger/features/receipts/data/drift_receipt_repository.dart';
import 'package:ledger/features/receipts/infrastructure/local_receipt_file_store.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;
import 'package:ledger/localization/generated/app_localizations.dart';

void main() {
  late Directory directory;
  late LedgerDatabase db;
  late LocalReceiptFileStore files;
  late BookkeepingRuntime runtime;
  late LocalId profile;
  late Account account;
  late Category category;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('keev-history-receipts-');
    db = LedgerDatabase(NativeDatabase.memory());
    files = LocalReceiptFileStore(
      directoryProvider: () async => Directory('${directory.path}/owned'),
    );
    runtime = BookkeepingRuntime(db, receiptFileStore: files);
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
  });

  tearDown(() async {
    await runtime.close();
    await directory.delete(recursive: true);
  });

  Future<BookkeepingEntry> transaction(String note, String date) async =>
      (await runtime.service.recordExpense(
        profileId: profile,
        accountId: account.id,
        categoryId: category.id,
        amount: Money.fromMinorUnits(Currency.hkd, 100),
        businessDate: BusinessDate(date),
        note: note,
      ) as Success<BookkeepingEntry>).value;

  Future<ReceiptAttachment> attach(BookkeepingEntry entry, String name) async {
    final source = File('${directory.path}/$name.png');
    final pixels = image.Image(width: 8, height: 8);
    image.fill(pixels, color: image.ColorRgb8(120, 20, 180));
    await source.writeAsBytes(image.encodePng(pixels));
    // Seed real receipt metadata and the processed file without the runtime's
    // sync spool, which requires native path_provider in a widget test.
    final id = SecureUuidV4Generator().generate();
    final stored = (await files.importImage(
      source,
      id.value,
    ) as Success<StoredReceiptFile>).value;
    return (await DriftReceiptAttachmentRepository(db).create(
      ReceiptAttachment(
        id: id,
        profileId: profile,
        transactionId: entry.id,
        storageKey: stored.storageKey,
        mimeType: 'image/jpeg',
        byteSize: stored.byteSize,
        sha256Hex: stored.sha256Hex,
        position: 0,
        createdAtUtc: DateTime.utc(2026, 9, 24),
      ),
    ) as Success<ReceiptAttachment>).value;
  }

  Future<void> flush(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pumpAndSettle();
  }

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HistoryView(session: runtime)),
      ),
    );
    await flush(tester);
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('history-note-search')), text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await flush(tester);
  }

  Finder row(BookkeepingEntry entry) =>
      find.byKey(ValueKey('history-entry-${entry.id.value}'));
  Finder receiptIcon(BookkeepingEntry entry) => find.descendant(
    of: row(entry),
    matching: find.byIcon(Icons.receipt_long_outlined),
  );

  testWidgets('filter removes an attached row without leaking its receipt', (
    tester,
  ) async {
    final a = await transaction('A receipt', '2026-09-22');
    final b = await transaction('B empty', '2026-09-21');
    await tester.runAsync(() => attach(a, 'a'));
    await mount(tester);
    expect(receiptIcon(a), findsOneWidget);
    expect(receiptIcon(b), findsNothing);

    await search(tester, 'B empty');
    expect(row(a), findsNothing);
    expect(row(b), findsOneWidget);
    expect(receiptIcon(b), findsNothing);
    expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
  });

  testWidgets('filtered receipt appears and opens its own file after reorder', (
    tester,
  ) async {
    final a = await transaction('A empty', '2026-09-22');
    final b = await transaction('B receipt', '2026-09-21');
    final c = await transaction('C receipt', '2026-09-20');
    final bReceipt = (await tester.runAsync(() => attach(b, 'b')))!;
    final cReceipt = (await tester.runAsync(() => attach(c, 'c')))!;
    await mount(tester);
    expect(receiptIcon(a), findsNothing);

    // B moves into A's visible slot; clearing and filtering again reorders
    // the same stateful rows. Each opened file must still belong to its row.
    await search(tester, 'B receipt');
    expect(receiptIcon(b), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(receiptIcon(b));
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await flush(tester);
    final bImage = tester.widget<Image>(find.byType(Image).last);
    expect(
      (bImage.image as FileImage).file.path,
      endsWith(bReceipt.storageKey),
    );
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();

    await search(tester, '');
    expect(row(a), findsOneWidget);
    await search(tester, 'C receipt');
    expect(receiptIcon(c), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(receiptIcon(c));
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await flush(tester);
    final cImage = tester.widget<Image>(find.byType(Image).last);
    expect(
      (cImage.image as FileImage).file.path,
      endsWith(cReceipt.storageKey),
    );
    expect(
      (cImage.image as FileImage).file.path,
      isNot(endsWith(bReceipt.storageKey)),
    );
  });
}
