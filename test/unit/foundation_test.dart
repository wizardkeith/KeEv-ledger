import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/settings/application/settings_controller.dart';
import 'package:ledger/features/settings/domain/preferences.dart';
import 'package:ledger/features/settings/data/session_preferences.dart';
import 'package:ledger/localization/generated/app_localizations.dart';
import 'package:ledger/localization/locale_resolution.dart';

class RejectingPreferences implements PreferencesRepository {
  @override
  Future<Result<Preferences>> read() async => const Success(Preferences());
  @override
  Future<Result<void>> write(Preferences value) async =>
      const Failure(FailureCode.preferencesUnavailable);
}

void main() {
  test('ARB key parity and ICU placeholder parity', () {
    final root = Directory('lib/localization/arb');
    final base = jsonDecode(
      File('${root.path}/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    Set<String> keys(Map<String, dynamic> d) =>
        d.keys.where((k) => !k.startsWith('@')).toSet();
    Set<String> placeholders(String s) =>
        RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!).toSet();
    for (final file in root.listSync().whereType<File>()) {
      final d = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(keys(d), keys(base), reason: file.path);
      for (final k in keys(base)) {
        expect(d[k], isNotEmpty);
        expect(
          placeholders(d[k] as String),
          placeholders(base[k] as String),
          reason: '${file.path}:$k',
        );
      }
    }
  });
  test('Script-aware locale resolution and fallback', () {
    expect(resolveLocale([const Locale('zh', 'TW')]), const Locale('zh', 'HK'));
    expect(
      resolveLocale([
        const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'CN',
        ),
      ]),
      const Locale('zh', 'HK'),
    );
    expect(
      resolveLocale([
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ]),
      const Locale('zh', 'CN'),
    );
    expect(resolveLocale([const Locale('zh', 'SG')]), const Locale('zh', 'CN'));
    expect(
      resolveLocale([const Locale('fr'), const Locale('ja')]),
      const Locale('ja'),
    );
    expect(resolveLocale([const Locale('fr')]), const Locale('zh', 'HK'));
    expect(resolveLocale(null), const Locale('zh', 'HK'));
  });
  for (final locale in supportedLocales)
    test('Generated localization loads $locale', () async {
      final l = await AppLocalizations.delegate.load(locale);
      expect(l.phaseLabel(1), contains('1'));
      expect(l.home, isNotEmpty);
    });
  test('Rejected preference write preserves previous state', () async {
    final c = SettingsController(RejectingPreferences());
    addTearDown(c.dispose);
    await c.load();
    await c.setTheme(ThemeMode.dark);
    expect(c.themeMode, ThemeMode.system);
    expect(c.failure, FailureCode.preferencesUnavailable);
    expect(c.busy, isFalse);
  });
  test('Session state does not pretend to survive a restart', () async {
    final c = SettingsController(SessionPreferences());
    addTearDown(c.dispose);
    await c.setLocale(const Locale('th'));
    await c.setTheme(ThemeMode.dark);
    expect(c.locale, const Locale('th'));
    expect(c.themeMode, ThemeMode.dark);
    final next = SettingsController(SessionPreferences());
    addTearDown(next.dispose);
    await next.load();
    expect(next.locale, isNull);
    expect(next.themeMode, ThemeMode.system);
  });
}
