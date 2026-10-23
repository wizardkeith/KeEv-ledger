import '../../../core/result.dart';

/// Plain Dart domain values; platform widgets never enter the storage contract.
enum Appearance { system, light, dark }

class Preferences {
  const Preferences({this.localeTag, this.appearance = Appearance.system});
  final String? localeTag;
  final Appearance appearance;
}

abstract interface class PreferencesRepository {
  Future<Result<Preferences>> read();
  Future<Result<void>> write(Preferences value);
}
