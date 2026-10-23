import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/design_system/components.dart';
import 'package:ledger/design_system/theme.dart';

import 'app_test.dart' as appHelpers;

void main() {
  const cases = <(Locale, String)>[
    (Locale('en'), KeEvTypography.latin),
    (Locale('zh', 'HK'), KeEvTypography.hongKong),
    (Locale('zh', 'CN'), KeEvTypography.simplified),
    (Locale('ja'), KeEvTypography.japanese),
    (Locale('th'), KeEvTypography.thai),
  ];

  test(
    'Every selected production font has a real Flutter asset declaration',
    () async {
      final manifest = jsonDecode(
        await rootBundle.loadString('FontManifest.json'),
      ) as List<dynamic>;
      for (final (_, family) in cases) {
        final entry = manifest.cast<Map<String, dynamic>>().singleWhere(
          (item) => item['family'] == family,
        );
        final fonts = entry['fonts'] as List<dynamic>;
        expect(
          fonts,
          hasLength(1),
          reason: '$family must not bundle duplicates',
        );
        final path = (fonts.single as Map<String, dynamic>)['asset'] as String;
        final bytes = await rootBundle.load(path);
        expect(bytes.lengthInBytes, greaterThan(100000), reason: path);
        expect(bytes.getUint32(0), 0x00010000, reason: '$path is a TTF');
      }
    },
  );

  for (final (locale, family) in cases) {
    test('Theme $locale prioritizes its independent locale font', () {
      for (final brightness in Brightness.values) {
        final theme = keevTheme(brightness, locale: locale);
        expect(theme.textTheme.bodyMedium?.fontFamily, family);
        expect(theme.textTheme.titleLarge?.fontFamily, family);
        expect(theme.textTheme.labelLarge?.fontFamily, family);
        expect(theme.textTheme.headlineMedium?.fontFamily, family);
        expect(
          theme.textTheme.bodyMedium?.fontFamilyFallback,
          isNot(contains(family)),
        );
        expect(
          KeEvTypography.financialAmount(
            theme.textTheme,
            large: true,
          )?.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });
  }

  test('HK and mainland primary fonts remain distinct', () {
    expect(
      KeEvTypography.familyFor(const Locale('zh', 'HK')),
      isNot(KeEvTypography.familyFor(const Locale('zh', 'CN'))),
    );
  });

  testWidgets('Switching live app locale updates the shell font', (
    tester,
  ) async {
    final controller = await appHelpers.start(tester);
    await appHelpers.enterLocal(tester);
    for (final (locale, family) in cases) {
      await controller.setLocale(locale);
      await tester.pumpAndSettle();
      final theme = Theme.of(tester.element(find.byKey(const Key('nav-add'))));
      expect(theme.textTheme.labelSmall?.fontFamily, family);
      expect(theme.textTheme.bodyMedium?.fontFamily, family);
    }
  });

  const mixedLines = [
    'HK\$ 12,580.50 餐飲',
    '支付寶 Alipay ¥1,280',
    'Amazon JP ¥8,900',
    'ร้านอาหาร HK\$350',
    '東京 Metro ¥220',
    'KeEv Ledger 交易紀錄',
    'Visa •••• 1234',
    'USD 1,250.75',
    'THB 3,450.00',
    'HK\$ 9,999,999,999,999.99 餐飲',
  ];

  for (final (locale, family) in cases) {
    for (final brightness in Brightness.values) {
      testWidgets('Bundled $family mixed scripts at 200% $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: keevTheme(brightness, locale: locale),
            home: Scaffold(
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final line in mixedLines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
        );
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.byType(Scaffold)))
              .textTheme
              .bodyMedium
              ?.fontFamily,
          family,
        );
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.byType(KeEvAmountText), 200);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('HK\$ 9,999,999,999,999.99'), findsOneWidget);
      });
    }
  }
}
