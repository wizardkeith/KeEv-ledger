import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/result.dart';
import '../application/app_lock_contracts.dart';

const _appLockKey = 'keev.local_app_lock.v1';

final class FlutterSecureLockStore implements AppLockSecureStore {
  const FlutterSecureLockStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<Result<String?>> read() async {
    try {
      return Success(await _storage.read(key: _appLockKey));
    } on Object {
      return const Failure(FailureCode.secureStorageUnavailable);
    }
  }

  @override
  Future<Result<void>> write(String value) async {
    try {
      await _storage.write(key: _appLockKey, value: value);
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.secureStorageUnavailable);
    }
  }

  @override
  Future<Result<void>> delete() async {
    try {
      await _storage.delete(key: _appLockKey);
      return const Success(null);
    } on Object {
      return const Failure(FailureCode.secureStorageUnavailable);
    }
  }
}
