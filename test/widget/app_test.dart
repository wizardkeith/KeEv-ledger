import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart';
import 'package:ledger/app/app.dart';
import 'package:ledger/app/environment.dart';
import 'package:ledger/design_system/theme.dart';
import 'package:ledger/features/settings/application/settings_controller.dart';
import 'package:ledger/features/settings/data/session_preferences.dart';
import 'package:ledger/localization/locale_resolution.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/app_lock/application/app_lock_contracts.dart';
import 'package:ledger/features/app_lock/application/app_lock_controller.dart';
import 'package:ledger/features/account/application/account_controller.dart';
import 'package:ledger/features/account/application/authentication_contracts.dart';
import 'package:ledger/features/account/infrastructure/unavailable_authentication_gateway.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) {
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      f,
      250,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<SettingsController> start(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double scale = 1,
  Brightness brightness = Brightness.light,
  AppLockController? appLock,
  AccountController? account,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  final c = SettingsController(SessionPreferences());
  final runtime = BookkeepingRuntime(LedgerDatabase(NativeDatabase.memory()));
  final lock = appLock ?? await testAppLock();
  final cloudAccount = account ?? await testAccountController();
  addTearDown(runtime.close);
  addTearDown(lock.dispose);
  addTearDown(cloudAccount.dispose);
  await c.setLocale(locale);
  addTearDown(c.dispose);
  await tester.pumpWidget(
    KeEvApp(
      controller: c,
      bookkeepingRuntime: runtime,
      configuration: const AppConfiguration(AppEnvironment.development),
      appLockController: lock,
      accountController: cloudAccount,
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> enterLocal(WidgetTester tester) async {
  await tapKey(tester, 'onboarding-continue');
  await tapKey(tester, 'accept-preview');
  await tapKey(tester, 'start-local');
}

void main() {
  testWidgets(
    'enabled startup gates content and lifecycle re-locks with cover',
    (tester) async {
      final lock = await testAppLock();
      await lock.setupPin('1234', '1234');
      lock.lock();
      await start(tester, appLock: lock);
      expect(find.byKey(const Key('app-lock-screen')), findsOneWidget);
      expect(find.byKey(const Key('nav-0')), findsNothing);
      await tester.enterText(find.byKey(const Key('unlock-pin')), '1234');
      await tester.tap(find.byKey(const Key('unlock-with-pin')));
      await tester.pumpAndSettle();
      await enterLocal(tester);
      expect(find.byKey(const Key('nav-0')), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(
        find.text(
          'Financial details are hidden while KeEv Ledger is inactive.',
        ),
        findsOneWidget,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(lock.state, AppLockState.locked);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-lock-screen')), findsOneWidget);
    },
  );

  testWidgets(
    'settings can enable PIN lock and Lock Now without cloud identity',
    (tester) async {
      final lock = await testAppLock();
      await start(tester, appLock: lock);
      await enterLocal(tester);
      await tapKey(tester, 'nav-4');
      await tapKey(tester, 'route-settings');
      await tapKey(tester, 'route-app-lock');
      await tapKey(tester, 'enable-app-lock');
      await tester.enterText(find.byKey(const Key('pin-field-0')), '2468');
      await tester.enterText(find.byKey(const Key('pin-field-1')), '2468');
      await tester.tap(find.byKey(const Key('confirm-pin-action')));
      await tester.pumpAndSettle();
      expect(find.text('App Lock is enabled'), findsOneWidget);
      await tapKey(tester, 'lock-now');
      expect(lock.state, AppLockState.locked);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-lock-screen')), findsOneWidget);
    },
  );

  testWidgets('cloud account foundation preserves honest Local Only UI', (
    tester,
  ) async {
    await start(tester);
    await enterLocal(tester);
    await tapKey(tester, 'nav-4');
    await tapKey(tester, 'route-authentication');
    expect(find.text('Local Only'), findsWidgets);
    expect(
      find.textContaining('No account or network connection is required'),
      findsOneWidget,
    );
    await tapKey(tester, 'explore-cloud-account');
    expect(
      find.text(
        'Cloud sign-in is not configured in this build. Local Only remains available.',
      ),
      findsWidgets,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.descendant(
              of: find.byKey(const Key('sign-in-apple')),
              matching: find.byType(OutlinedButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('Onboarding, development legal content and account-free entry', (
    tester,
  ) async {
    await start(tester);
    await tapKey(tester, 'onboarding-continue');
    await tester.scrollUntilVisible(
      find.byKey(const Key('start-local')),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('start-local')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );
    for (final key in ['privacy-link', 'terms-link']) {
      await tapKey(tester, key);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('DEVELOPMENT CONTENT'), findsWidgets);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    }
    await tapKey(tester, 'accept-preview');
    await tapKey(tester, 'start-local');
    expect(find.byKey(const Key('nav-0')), findsOneWidget);
    await tapKey(tester, 'nav-add');
    expect(find.byKey(const Key('quick-amount')), findsOneWidget);
    await back(tester);
  });
  testWidgets('Navigation, language and light/dark/system controls work', (
    tester,
  ) async {
    final c = await start(tester);
    await enterLocal(tester);
    for (final i in [1, 3, 4]) await tapKey(tester, 'nav-$i');
    for (final page in [
      'accounts',
      'projects',
      'reports',
      'backup',
      'authentication',
      'premium',
    ]) {
      await tapKey(tester, 'route-$page');
      expect(find.byType(AppBar), findsOneWidget);
      await back(tester);
    }
    await tapKey(tester, 'route-settings');
    await tapKey(tester, 'route-appearance');
    await tapKey(tester, 'theme-dark');
    expect(
      Theme.of(tester.element(find.byType(ListView).last)).brightness,
      Brightness.dark,
    );
    await tapKey(tester, 'theme-light');
    expect(c.themeMode, ThemeMode.light);
    await tapKey(tester, 'theme-system');
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(ListView).last)).brightness,
      Brightness.dark,
    );
    await back(tester);
    await tapKey(tester, 'route-language');
    for (final pair in [
      ('ja', '言語'),
      ('th', 'ภาษา'),
      ('zh_HK', '語言'),
      ('zh_CN', '语言'),
      ('en', 'Language'),
    ]) {
      await tapKey(tester, 'locale-${pair.$1}');
      expect(find.text(pair.$2), findsOneWidget);
    }
  });
  for (final locale in supportedLocales) {
    for (final brightness in Brightness.values) {
      testWidgets('200% all routes $locale $brightness', (tester) async {
        await start(tester, locale: locale, scale: 2, brightness: brightness);
        expect(tester.takeException(), isNull);
        await enterLocal(tester);
        for (final i in [0, 1, 3, 4]) {
          await tapKey(tester, 'nav-$i');
          expect(tester.takeException(), isNull);
        }
        for (final page in [
          'accounts',
          'projects',
          'reports',
          'backup',
          'authentication',
          'premium',
          'settings',
        ]) {
          await tapKey(tester, 'route-$page');
          expect(tester.takeException(), isNull);
          if (page == 'settings') {
            for (final sub in ['language', 'appearance']) {
              await tapKey(tester, 'route-$sub');
              expect(tester.takeException(), isNull);
              await back(tester);
            }
          }
          await back(tester);
        }
        await tapKey(tester, 'nav-add');
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Navigation semantics, target sizes and contrast', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    try {
      await start(tester);
      await enterLocal(tester);
      expect(
        tester.getSemantics(find.byKey(const Key('nav-add'))),
        matchesSemantics(
          label: 'Add',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    } finally {
      h.dispose();
    }
  });
  test('Brand action contrast meets 4.5:1', () {
    for (final brightness in Brightness.values) {
      final s = keevTheme(brightness).colorScheme;
      final a = s.primary.computeLuminance(),
          b = s.onPrimary.computeLuminance();
      expect(
        ((a > b ? a : b) + 0.05) / ((a < b ? a : b) + 0.05),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}

Future<AppLockController> testAppLock() async {
  final controller = AppLockController(
    store: _MemoryLockStore(),
    pinDeriver: _FastPinDeriver(),
    biometrics: _NoBiometrics(),
    clock: const SystemClock(),
  );
  await controller.initialize();
  return controller;
}

Future<AccountController> testAccountController() async {
  final controller = AccountController(
    gateway: const UnavailableAuthenticationGateway(),
    sessionStore: _MemorySessionStore(),
  );
  await controller.initialize();
  return controller;
}

final class _MemorySessionStore implements SecureSessionStore {
  AuthenticationBundle? value;

  @override
  Future<Result<AuthenticationBundle?>> read() async => Success(value);

  @override
  Future<Result<void>> write(AuthenticationBundle next) async {
    value = next;
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    value = null;
    return const Success(null);
  }
}

final class _MemoryLockStore implements AppLockSecureStore {
  String? value;
  @override
  Future<Result<String?>> read() async => Success(value);
  @override
  Future<Result<void>> write(String next) async {
    value = next;
    return const Success(null);
  }

  @override
  Future<Result<void>> delete() async {
    value = null;
    return const Success(null);
  }
}

final class _FastPinDeriver implements PinDeriver {
  int seed = 0;
  @override
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    final sum = pin.codeUnits.fold<int>(0, (a, b) => a + b);
    return List<int>.generate(
      32,
      (index) => (sum + salt[index % 16] + index) & 255,
    );
  }

  @override
  List<int> randomSalt() => List<int>.generate(16, (index) => index + ++seed);
}

final class _NoBiometrics implements BiometricAuthenticator {
  @override
  Future<BiometricCapability> capability() async =>
      BiometricCapability.unavailable;
  @override
  Future<BiometricAuthenticationResult> authenticate(String reason) async =>
      BiometricAuthenticationResult.unavailable;
  @override
  Future<void> cancel() async {}
}
