import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/bookkeeping/domain/transfer.dart';
import 'package:ledger/features/bookkeeping/application/bookkeeping_service.dart';
import 'package:ledger/features/bookkeeping/presentation/quick_add_screen.dart';
import 'package:ledger/features/bookkeeping/presentation/history_view.dart';
import 'package:ledger/features/planning/domain/project.dart';
import 'package:ledger/features/voice/application/voice_recognition.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;
import 'package:ledger/localization/generated/app_localizations.dart';

void main() {
  late BookkeepingRuntime runtime;
  late FakeVoiceRecognizer voice;
  late LocalId profile;
  late Account cash, bank, usd;
  late Category food;
  late Project trip;

  setUp(() async {
    voice = FakeVoiceRecognizer();
    runtime = BookkeepingRuntime(
      LedgerDatabase(NativeDatabase.memory()),
      voiceRecognizer: voice,
    );
    profile = (await runtime.profile() as Success<LocalId>).value;
    final day = BusinessDate('2020-01-01');
    Future<Account> account(String name, Currency currency) async =>
        (await runtime.service.createAccount(
          profileId: profile,
          name: name,
          kind: AccountKind.bank,
          currency: currency,
          openingBalance: Money.zero(currency),
          openingDate: day,
        ) as Success<Account>).value;
    cash = await account('Cash', Currency.hkd);
    bank = await account('Bank', Currency.hkd);
    usd = await account('USD wallet', Currency.usd);
    food = (await runtime.service.createCategory(
      profileId: profile,
      name: 'Food',
      kind: EntryKind.expense,
    ) as Success<Category>).value;
    await runtime.service.createCategory(
      profileId: profile,
      name: 'Pay',
      kind: EntryKind.income,
    );
    trip = (await runtime.planning.createProject(
      profileId: profile,
      name: 'Japan Trip',
    ) as Success<Project>).value;
  });
  tearDown(() => runtime.close());

  Future<void> openAdd(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('open-add')));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-amount')), findsOneWidget);
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
        home: Scaffold(
          body: Center(
            child: FilledButton(
              key: const Key('open-add'),
              onPressed: () =>
                  Navigator.of(
                    tester.element(find.byKey(const Key('open-add'))),
                  ).push(
                    MaterialPageRoute<bool>(
                      builder: (_) => QuickAddScreen(session: runtime),
                    ),
                  ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-add')));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await tester.pumpAndSettle();
    assert(find.byType(QuickAddScreen).evaluate().isNotEmpty);
  }

  Future<void> choose(WidgetTester tester, String key, String label) async {
    final field = find.byKey(Key(key));
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Voice suggests a draft, protects edits, and never saves without Save',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byKey(const Key('voice-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('voice-disclosure-continue')));
      await tester.pump();
      voice.emit('今日午餐八十五蚊', isFinal: false);
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('quick-amount')))
            .controller!
            .text,
        '85.00',
      );
      expect(find.text('Food'), findsWidgets);
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value,
        isEmpty,
      );
      await tester.enterText(find.byKey(const Key('quick-amount')), '95.00');
      voice.emit('今日午餐八十蚊', isFinal: true);
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('quick-amount')))
            .controller!
            .text,
        '95.00',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('quick-save')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value.single.amount.minorUnits,
        9500,
      );
    },
  );

  testWidgets('Cancelled and failed speech preserve the manual draft', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byKey(const Key('quick-amount')), '42.00');
    await tester.tap(find.byKey(const Key('voice-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice-disclosure-continue')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('voice-cancel')));
    await tester.pump();
    voice.emit('午餐八十五蚊', isFinal: true);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('quick-amount')))
          .controller!
          .text,
      '42.00',
    );
    await tester.tap(find.byKey(const Key('voice-start')));
    await tester.pump();
    voice.fail(FailureCode.speechRecognitionFailed);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('quick-amount')))
          .controller!
          .text,
      '42.00',
    );
    expect(find.textContaining('draft was kept'), findsOneWidget);
  });

  testWidgets(
    'Expense and income save after persistence, with amount-first form',
    (tester) async {
      await mount(tester);
      expect(find.byKey(const Key('quick-amount')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('quick-amount')), '12.34');
      await choose(tester, 'quick-category', 'Food');
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.tap(
        find.byKey(const Key('quick-save')),
      ); // Fast repeated tap must not create a duplicate.
      await tester.pumpAndSettle();
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value.single.amount.minorUnits,
        1234,
      );
      expect(find.text('Saved on this device'), findsOneWidget);
      await openAdd(tester);
      await tester.tap(find.text('Income').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('quick-amount')), '5');
      await choose(tester, 'quick-category', 'Pay');
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value,
        hasLength(2),
      );
    },
  );

  testWidgets('Expense may be assigned to an optional Project', (tester) async {
    await mount(tester);
    await tester.enterText(find.byKey(const Key('quick-amount')), '25.00');
    await choose(tester, 'quick-category', 'Food');
    await choose(tester, 'quick-project', 'Japan Trip');
    await tester.ensureVisible(find.byKey(const Key('quick-save')));
    await tester.tap(find.byKey(const Key('quick-save')));
    await tester.pumpAndSettle();
    final saved = (await runtime.service.history(
      profile,
    ) as Success<List<BookkeepingEntry>>).value.single;
    expect(saved.projectId, trip.id);
  });

  testWidgets(
    'Same and cross currency Quick Add transfers save one event each',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Transfer').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('quick-amount')), '10.00');
      await choose(tester, 'quick-destination', 'Bank · HKD');
      expect(find.byKey(const Key('quick-received')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(
        (await runtime.service.historyEvents(
          profile,
        ) as Success<List<LedgerHistoryItem>>).value.length,
        1,
      );
      await openAdd(tester);
      await tester.tap(find.text('Transfer').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('quick-amount')), '780.00');
      await choose(tester, 'quick-destination', 'USD wallet');
      expect(find.byKey(const Key('quick-received')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('quick-received')), '100.00');
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(
        (await runtime.service.transfers.history(
          profile,
        ) as Success<List<LedgerTransfer>>).value.length,
        2,
      );
      expect(
        (await runtime.service.accountBalance(
          profile,
          usd.id,
        ) as Success<Money>).value.minorUnits,
        10000,
      );
      expect(
        (await runtime.service.accountBalance(
          profile,
          cash.id,
        ) as Success<Money>).value.minorUnits,
        -79000,
      );
      expect(
        (await runtime.service.accountBalance(
          profile,
          bank.id,
        ) as Success<Money>).value.minorUnits,
        1000,
      );
    },
  );

  testWidgets(
    'Validation and typed persistence failure do not report success',
    (tester) async {
      await mount(tester);
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('positive amount'), findsWidgets);
      await tester.enterText(find.byKey(const Key('quick-amount')), '10.00');
      await choose(tester, 'quick-category', 'Food');
      await runtime.service.archiveCategory(profile, food.id);
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(find.text('Saved on this device'), findsNothing);
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value,
        isEmpty,
      );
    },
  );
  testWidgets('Quick Add controls stay usable at 200% text scaling', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Transfer').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('quick-save')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('quick-save')), findsOneWidget);
  });
  testWidgets(
    'Fresh local profile can create account and category before saving',
    (tester) async {
      await runtime.close();
      runtime = BookkeepingRuntime(
        LedgerDatabase(NativeDatabase.memory()),
        voiceRecognizer: voice,
      );
      profile = (await runtime.profile() as Success<LocalId>).value;
      await mount(tester);
      await tester.enterText(find.byKey(const Key('quick-amount')), '12.50');
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('account-name')),
        'New wallet',
      );
      await tester.tap(find.byKey(const Key('create-account')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
      });
      await tester.pumpAndSettle();
      expect(find.textContaining('New wallet'), findsWidgets);
      await tester.ensureVisible(find.text('Add category'));
      await tester.tap(find.text('Add category'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('category-name')), 'Food');
      await tester.tap(find.byKey(const Key('create-category')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
      });
      await tester.pumpAndSettle();
      await choose(tester, 'quick-category', 'Food');
      await tester.ensureVisible(find.byKey(const Key('quick-save')));
      await tester.tap(find.byKey(const Key('quick-save')));
      await tester.pumpAndSettle();
      expect(
        (await runtime.service.history(
          profile,
        ) as Success<List<BookkeepingEntry>>).value.single.amount.minorUnits,
        1250,
      );
    },
  );
  testWidgets(
    'Cross-currency history shows one event and both amounts at 200%',
    (tester) async {
      expect(
        await runtime.service.transfer(
          profileId: profile,
          sourceAccountId: cash.id,
          destinationAccountId: usd.id,
          sent: Money.fromMinorUnits(Currency.hkd, 78000),
          received: Money.fromMinorUnits(Currency.usd, 10000),
          businessDate: BusinessDate('2026-09-20'),
        ),
        isA<Success<LedgerTransfer>>(),
      );
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HistoryView(session: runtime)),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
      });
      await tester.pumpAndSettle();
      expect(find.textContaining('Cash → USD wallet'), findsOneWidget);
      expect(find.text('HKD 780.00'), findsOneWidget);
      expect(find.text('USD 100.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('history builds only viewport cards for a synthetic ledger', (
    tester,
  ) async {
    for (var i = 0; i < 80; i++) {
      expect(
        await runtime.service.recordExpense(
          profileId: profile,
          accountId: cash.id,
          categoryId: food.id,
          amount: Money.fromMinorUnits(Currency.hkd, i + 1),
          businessDate: BusinessDate('2026-09-20'),
        ),
        isA<Success<BookkeepingEntry>>(),
      );
    }
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
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await tester.pumpAndSettle();
    expect(find.byType(Card).evaluate().length, lessThan(80));
    expect(tester.takeException(), isNull);
  });
}

final class FakeVoiceRecognizer implements VoiceRecognizer {
  VoiceTranscriptCallback? transcript;
  VoiceStatusCallback? status;
  VoiceErrorCallback? error;

  @override
  Future<Result<String>> start({
    required String uiLocaleTag,
    required VoiceTranscriptCallback onTranscript,
    required VoiceStatusCallback onStatus,
    required VoiceErrorCallback onError,
  }) async {
    transcript = onTranscript;
    status = onStatus;
    error = onError;
    onStatus(VoiceRecognitionStatus.listening);
    return const Success('zh_HK');
  }

  void emit(String text, {required bool isFinal}) =>
      transcript?.call(VoiceTranscript(text, isFinal: isFinal));

  void fail(FailureCode code) => error?.call(code);

  @override
  Future<void> stop() async => status?.call(VoiceRecognitionStatus.processing);

  @override
  Future<void> cancel() async {}
}
