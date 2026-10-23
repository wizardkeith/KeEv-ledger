// Optional evidence utility. Fonts are loaded for capture only, never by the app.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/app.dart';
import 'package:ledger/app/environment.dart';
import 'package:ledger/features/settings/application/settings_controller.dart';
import 'package:ledger/features/settings/data/session_preferences.dart';

import '../test/widget/app_test.dart' as helpers;

void main() {
  testWidgets('Capture rendered shell for review', (tester) async {
    const fontPath = String.fromEnvironment(
      'CAPTURE_FONT',
      defaultValue: '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    );
    await tester.runAsync(() async {
      final loader = FontLoader('Roboto')
        ..addFont(
          Future.value(
            ByteData.sublistView(await File(fontPath).readAsBytes()),
          ),
        );
      for (final entry in [
        ('Noto Sans CJK HK', const String.fromEnvironment('CAPTURE_CJK_FONT')),
        ('Noto Sans CJK SC', const String.fromEnvironment('CAPTURE_SC_FONT')),
        ('Noto Sans CJK JP', const String.fromEnvironment('CAPTURE_JP_FONT')),
        ('Noto Sans Thai', const String.fromEnvironment('CAPTURE_THAI_FONT')),
      ]) {
        if (entry.$2.isNotEmpty) {
          final fallback = FontLoader(entry.$1)
            ..addFont(
              Future.value(
                ByteData.sublistView(await File(entry.$2).readAsBytes()),
              ),
            );
          await fallback.load();
        }
      }
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = SettingsController(SessionPreferences());
    addTearDown(c.dispose);
    final appLock = await helpers.testAppLock();
    addTearDown(appLock.dispose);
    final account = await helpers.testAccountController();
    addTearDown(account.dispose);
    await c.setLocale(const Locale('en'));
    const key = Key('capture');
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: KeEvApp(
          controller: c,
          configuration: const AppConfiguration(AppEnvironment.development),
          appLockController: appLock,
          accountController: account,
        ),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final f = File('docs/evidence/phase_1/screenshots/$name.png');
        await f.parent.create(recursive: true);
        await f.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/brand/keev-logo-original.png'),
        tester.element(find.byType(Image)),
      ),
    );
    await tester.pumpAndSettle();
    await capture('onboarding-en');
    await helpers.enterLocal(tester);
    await capture('home-light-en');
    for (final locale in [
      const Locale('zh', 'HK'),
      const Locale('zh', 'CN'),
      const Locale('ja'),
      const Locale('th'),
    ]) {
      await c.setLocale(locale);
      await tester.pumpAndSettle();
      await capture('home-light-$locale');
    }
    await c.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    await c.setTheme(ThemeMode.dark);
    await tester.pumpAndSettle();
    await capture('home-dark-en');
    await helpers.tapKey(tester, 'nav-4');
    await capture('more-dark-en');
    await c.setLocale(const Locale('th'));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    await helpers.tapKey(tester, 'nav-0');
    await capture('home-th-200');
    expect(tester.takeException(), isNull);
  });
}
