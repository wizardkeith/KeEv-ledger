import '../../../core/result.dart';
import '../domain/preferences.dart';

/// Explicit session-only UI state. Phase 2 provides durable storage.
class SessionPreferences implements PreferencesRepository {
  Preferences _value = const Preferences();
  @override
  Future<Result<Preferences>> read() async => Success(_value);
  @override
  Future<Result<void>> write(Preferences value) async {
    _value = value;
    return const Success(null);
  }
}
