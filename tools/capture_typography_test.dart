// Optional Phase 1A headless preview; loads the exact bundled production fonts.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/design_system/components.dart';
import 'package:ledger/design_system/theme.dart';

void main() {
  testWidgets('Capture official fonts with mixed scripts in all locales', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final (family, file) in [
        ('Plus Jakarta Sans', 'PlusJakartaSans.ttf'),
        ('Noto Sans HK', 'NotoSansHK.ttf'),
        ('Noto Sans SC', 'NotoSansSC.ttf'),
        ('Noto Sans JP', 'NotoSansJP.ttf'),
        ('Noto Sans Thai', 'NotoSansThai.ttf'),
      ]) {
        final loader = FontLoader(family)
          ..addFont(rootBundle.load('assets/fonts/$file'));
        await loader.load();
      }
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    const key = Key('phase1a-capture');
    const lines = [
      'HK\$ 12,580.50 餐飲',
      '支付寶 Alipay ¥1,280',
      'Amazon JP ¥8,900',
      'ร้านอาหาร HK\$350',
      '東京 Metro ¥220',
      'KeEv Ledger 交易紀錄',
      'Visa •••• 1234',
      'USD 1,250.75',
      'THB 3,450.00',
    ];
    Future<void> capture(String name) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('docs/evidence/phase_1a/screenshots/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    for (final (locale, label) in [
      (const Locale('en'), 'en'),
      (const Locale('zh', 'HK'), 'zh-HK'),
      (const Locale('zh', 'CN'), 'zh-CN'),
      (const Locale('ja'), 'ja'),
      (const Locale('th'), 'th'),
    ]) {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: keevTheme(brightness, locale: locale),
              home: Scaffold(
                body: SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        '$label · $brightness',
                        style: keevTheme(
                          brightness,
                          locale: locale,
                        ).textTheme.headlineSmall,
                      ),
                      for (final line in lines)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Text(line),
                        ),
                      const KeEvAmountText(
                        formattedAmount: 'HK\$ 9,999,999,999,999.99',
                        semanticLabel: 'large balance',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await capture('$label-${brightness.name}-top');
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        await capture('$label-${brightness.name}-bottom');
        expect(tester.takeException(), isNull);
      }
    }
  });
}
