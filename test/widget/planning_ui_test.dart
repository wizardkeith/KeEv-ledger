import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/planning/domain/budget.dart';
import 'package:ledger/features/planning/domain/project.dart';
import 'package:ledger/features/planning/presentation/planning_screens.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;
import 'package:ledger/localization/generated/app_localizations.dart';

void main() {
  late BookkeepingRuntime runtime;
  late LocalId profile;

  setUp(() async {
    runtime = BookkeepingRuntime(LedgerDatabase(NativeDatabase.memory()));
    profile = (await runtime.profile() as Success<LocalId>).value;
  });

  tearDown(() => runtime.close());

  Future<void> settleData(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pumpAndSettle();
  }

  Widget app(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );

  testWidgets('Budget essential flow creates and displays a local budget', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BudgetView(session: runtime),
          ),
        ),
      ),
    );
    await settleData(tester);
    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('budget-name')), 'Monthly');
    await tester.enterText(find.byKey(const Key('budget-amount')), '1000.00');
    await tester.tap(find.byKey(const Key('create-budget')));
    await settleData(tester);
    expect(find.text('Monthly'), findsOneWidget);
    final stored = (await runtime.planning.listBudgets(
      profile,
    ) as Success<List<Budget>>).value.single;
    expect(stored.amount.minorUnits, 100000);
  });

  testWidgets('Project essential flow creates and displays a local project', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(ProjectScreen(session: runtime)));
    await settleData(tester);
    await tester.tap(find.text('Add project'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('project-name')), 'Wedding');
    await tester.enterText(
      find.byKey(const Key('project-description')),
      'Personal event',
    );
    await tester.tap(find.byKey(const Key('save-project')));
    await settleData(tester);
    expect(find.text('Wedding'), findsOneWidget);
    expect(
      (await runtime.planning.listProjects(
        profile,
      ) as Success<List<Project>>).value.single.description,
      'Personal event',
    );
  });
}
