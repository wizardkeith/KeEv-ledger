import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../domain/preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);
  final PreferencesRepository _repository;
  Preferences _preferences = const Preferences();
  FailureCode? failure;
  bool busy = false;

  Locale? get locale {
    final tag = _preferences.localeTag;
    if (tag == null) return null;
    final parts = tag.split('-');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  ThemeMode get themeMode => switch (_preferences.appearance) {
    Appearance.system => ThemeMode.system,
    Appearance.light => ThemeMode.light,
    Appearance.dark => ThemeMode.dark,
  };

  Future<void> load() async {
    switch (await _repository.read()) {
      case Success<Preferences>(:final value):
        _preferences = value;
        failure = null;
      case Failure<Preferences>(:final code):
        failure = code;
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? value) => _save(
    Preferences(
      localeTag: value?.toLanguageTag(),
      appearance: _preferences.appearance,
    ),
  );

  Future<void> setTheme(ThemeMode value) => _save(
    Preferences(
      localeTag: _preferences.localeTag,
      appearance: switch (value) {
        ThemeMode.system => Appearance.system,
        ThemeMode.light => Appearance.light,
        ThemeMode.dark => Appearance.dark,
      },
    ),
  );

  Future<void> _save(Preferences value) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    switch (await _repository.write(value)) {
      case Success<void>():
        _preferences = value;
        failure = null;
      case Failure<void>(:final code):
        failure = code;
    }
    busy = false;
    notifyListeners();
  }
}
