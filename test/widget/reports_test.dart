import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/features/reports/presentation/reports_screen.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;
import 'package:ledger/localization/generated/app_localizations.dart';

void main() {
  late BookkeepingRuntime runtime;

  setUp(() async {
    runtime = BookkeepingRuntime(LedgerDatabase(NativeDatabase.memory()));
    final profile = (await runtime.profile() as Success<LocalId>).value;
    final now = DateTime.now();
    final day = BusinessDate(
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-15',
    );
    final account = (await runtime.service.createAccount(
      profileId: profile,
      name: 'Wallet',
      kind: AccountKind.cash,
      currency: Currency.hkd,
      openingBalance: Money.zero(Currency.hkd),
      openingDate: BusinessDate('2020-01-01'),
    ) as Success<Account>).value;
    final category = (await runtime.service.createCategory(
      profileId: profile,
      name: 'Food',
      kind: EntryKind.expense,
    ) as Success<Category>).value;
    await runtime.service.recordExpense(
      profileId: profile,
      accountId: account.id,
      categoryId: category.id,
      amount: Money.fromMinorUnits(Currency.hkd, 12345),
      businessDate: day,
    );
  });

  tearDown(() => runtime.close());

  testWidgets(
    'Reports screen shows shared totals and prepares the same CSV locally',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: ReportsScreen(session: runtime),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Income & Expense Report'), findsOneWidget);
      expect(find.textContaining('HKD 123.45'), findsWidgets);
      expect(tester.takeException(), isNull);

      final button = find.text('Prepare CSV');
      await tester.scrollUntilVisible(
        button,
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('CSV prepared locally'), findsOneWidget);
      expect(find.textContaining('"Expense","HKD","123.45"'), findsOneWidget);
    },
  );
}
