import 'package:flutter/widgets.dart';

const supportedLocales = [
  Locale('zh', 'HK'),
  Locale('zh', 'CN'),
  Locale('en'),
  Locale('ja'),
  Locale('th'),
];
Locale resolveLocale(List<Locale>? preferred) {
  for (final locale in preferred ?? <Locale>[]) {
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant') return supportedLocales[0];
      if (locale.scriptCode == 'Hans') return supportedLocales[1];
      return const ['CN', 'SG'].contains(locale.countryCode)
          ? supportedLocales[1]
          : supportedLocales[0];
    }
    for (final supported in supportedLocales.skip(2)) {
      if (locale.languageCode == supported.languageCode) return supported;
    }
  }
  return supportedLocales.first;
}
