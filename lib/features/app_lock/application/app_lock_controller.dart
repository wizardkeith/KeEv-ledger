import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../domain/app_lock.dart';
import 'app_lock_contracts.dart';

enum AppLockState { loading, disabled, locked, unlocked, configurationError }

final class AppLockController extends ChangeNotifier {
  AppLockController({
    required AppLockSecureStore store,
    required PinDeriver pinDeriver,
    required BiometricAuthenticator biometrics,
    required Clock clock,
  }) : _store = store,
       _pinDeriver = pinDeriver,
       _biometrics = biometrics,
       _clock = clock;

  final AppLockSecureStore _store;
  final PinDeriver _pinDeriver;
  final BiometricAuthenticator _biometrics;
  final Clock _clock;

  AppLockState state = AppLockState.loading;
  BiometricCapability biometricCapability = BiometricCapability.unavailable;
  FailureCode? failure;
  AppLockRecord? _record;
  bool busy = false;
  bool _biometricPromptActive = false;
  int _generation = 0;

  bool get isEnabled => _record != null;
  bool get biometricsEnabled => _record?.biometricsEnabled ?? false;
  DateTime? get throttleUntilUtc => _record?.throttleUntilUtc;

  Duration get throttleRemaining {
    final until = _record?.throttleUntilUtc;
    if (until == null) return Duration.zero;
    final remaining = until.difference(_clock.nowUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> initialize() async {
    final stored = await _store.read();
    biometricCapability = await _biometrics.capability();
    switch (stored) {
      case Failure<String?>(:final code):
        failure = code;
        state = AppLockState.configurationError;
      case Success<String?>(value: null):
        _record = null;
        failure = null;
        state = AppLockState.disabled;
      case Success<String?>(:final value):
        try {
          _record = AppLockRecord.decode(value!);
          failure = null;
          state = AppLockState.locked;
        } on FormatException {
          _record = null;
          failure = FailureCode.lockConfigurationInvalid;
          state = AppLockState.configurationError;
        }
    }
    notifyListeners();
  }

  Future<Result<void>> setupPin(String pin, String confirmation) async {
    if (state != AppLockState.disabled) {
      return const Failure(FailureCode.lockAuthenticationRequired);
    }
    final validation = _validateNewPin(pin, confirmation);
    if (validation != null) return Failure(validation);
    final generation = _generation;
    _setBusy(true);
    final salt = _pinDeriver.randomSalt();
    final verifier = await _pinDeriver.derive(
      pin: pin,
      salt: salt,
      iterations: appLockKdfIterations,
    );
    if (generation != _generation) return _finishStale();
    final record = AppLockRecord(
      version: appLockRecordVersion,
      kdf: appLockKdfName,
      iterations: appLockKdfIterations,
      salt: salt,
      verifier: verifier,
      biometricsEnabled: false,
      failedAttempts: 0,
    );
    final saved = await _store.write(record.encode());
    if (saved is Failure<void>) return _finishFailure(saved.code);
    _record = record;
    state = AppLockState.unlocked;
    failure = null;
    _setBusy(false);
    return const Success(null);
  }

  Future<Result<void>> unlockWithPin(String pin) async {
    if (state != AppLockState.locked || busy) {
      return const Failure(FailureCode.lockAuthenticationRequired);
    }
    final generation = _generation;
    _setBusy(true);
    final verified = await _authenticatePin(pin, generation);
    if (verified is Failure<void>) return _finishFailure(verified.code);
    if (generation != _generation || state != AppLockState.locked) {
      return _finishStale();
    }
    state = AppLockState.unlocked;
    failure = null;
    _setBusy(false);
    return const Success(null);
  }

  Future<Result<void>> unlockWithBiometrics(String reason) async {
    final record = _record;
    if (state != AppLockState.locked ||
        record == null ||
        !record.biometricsEnabled ||
        biometricCapability != BiometricCapability.available ||
        _biometricPromptActive ||
        busy) {
      return const Failure(FailureCode.biometricUnavailable);
    }
    final generation = _generation;
    _biometricPromptActive = true;
    _setBusy(true);
    final result = await _biometrics.authenticate(reason);
    _biometricPromptActive = false;
    if (generation != _generation || state != AppLockState.locked) {
      return _finishStale();
    }
    if (result != BiometricAuthenticationResult.success) {
      return _finishFailure(_biometricFailure(result));
    }
    final reset = record.copyWith(failedAttempts: 0, clearThrottle: true);
    final saved = await _store.write(reset.encode());
    if (saved is Failure<void>) return _finishFailure(saved.code);
    _record = reset;
    state = AppLockState.unlocked;
    failure = null;
    _setBusy(false);
    return const Success(null);
  }

  Future<Result<void>> changePin({
    required String currentPin,
    required String newPin,
    required String confirmation,
  }) async {
    if (state != AppLockState.unlocked || busy) {
      return const Failure(FailureCode.lockAuthenticationRequired);
    }
    final validation = _validateNewPin(newPin, confirmation);
    if (validation != null) return Failure(validation);
    final generation = _generation;
    _setBusy(true);
    final authenticated = await _authenticatePin(currentPin, generation);
    if (authenticated is Failure<void>) {
      return _finishFailure(authenticated.code);
    }
    if (generation != _generation || state != AppLockState.unlocked) {
      return _finishStale();
    }
    final salt = _pinDeriver.randomSalt();
    final verifier = await _pinDeriver.derive(
      pin: newPin,
      salt: salt,
      iterations: appLockKdfIterations,
    );
    if (generation != _generation || state != AppLockState.unlocked) {
      return _finishStale();
    }
    final replacement = AppLockRecord(
      version: appLockRecordVersion,
      kdf: appLockKdfName,
      iterations: appLockKdfIterations,
      salt: salt,
      verifier: verifier,
      biometricsEnabled: _record!.biometricsEnabled,
      failedAttempts: 0,
    );
    final saved = await _store.write(replacement.encode());
    if (saved is Failure<void>) return _finishFailure(saved.code);
    _record = replacement;
    failure = null;
    _setBusy(false);
    return const Success(null);
  }

  Future<Result<void>> setBiometrics({
    required bool enabled,
    required String currentPin,
  }) async {
    if (state != AppLockState.unlocked || busy) {
      return const Failure(FailureCode.lockAuthenticationRequired);
    }
    if (enabled && biometricCapability != BiometricCapability.available) {
      return const Failure(FailureCode.biometricUnavailable);
    }
    final generation = _generation;
    _setBusy(true);
    final authenticated = await _authenticatePin(currentPin, generation);
    if (authenticated is Failure<void>) {
      return _finishFailure(authenticated.code);
    }
    if (generation != _generation || state != AppLockState.unlocked) {
      return _finishStale();
    }
    final replacement = _record!.copyWith(biometricsEnabled: enabled);
    final saved = await _store.write(replacement.encode());
    if (saved is Failure<void>) return _finishFailure(saved.code);
    _record = replacement;
    failure = null;
    _setBusy(false);
    return const Success(null);
  }

  Future<Result<void>> disable(String currentPin) async {
    if (state != AppLockState.unlocked || busy) {
      return const Failure(FailureCode.lockAuthenticationRequired);
    }
    final generation = _generation;
    _setBusy(true);
    final authenticated = await _authenticatePin(currentPin, generation);
    if (authenticated is Failure<void>) {
      return _finishFailure(authenticated.code);
    }
    if (generation != _generation || state != AppLockState.unlocked) {
      return _finishStale();
    }
    final deleted = await _store.delete();
    if (deleted is Failure<void>) return _finishFailure(deleted.code);
    _record = null;
    state = AppLockState.disabled;
    failure = null;
    _setBusy(false);
    return const Success(null);
  }

  void lock() {
    if (_record == null) return;
    _generation++;
    _biometricPromptActive = false;
    busy = false;
    failure = null;
    state = AppLockState.locked;
    unawaited(_biometrics.cancel());
    notifyListeners();
  }

  Future<Result<void>> _authenticatePin(String pin, int generation) async {
    final record = _record;
    if (record == null) {
      return const Failure(FailureCode.lockConfigurationInvalid);
    }
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      return const Failure(FailureCode.invalidPin);
    }
    final until = record.throttleUntilUtc;
    if (until != null && _clock.nowUtc().isBefore(until)) {
      return const Failure(FailureCode.lockThrottled);
    }
    final candidate = await _pinDeriver.derive(
      pin: pin,
      salt: record.salt,
      iterations: record.iterations,
    );
    if (generation != _generation) {
      return const Failure(FailureCode.authenticationStale);
    }
    if (_constantTimeEqual(candidate, record.verifier)) {
      final reset = record.copyWith(failedAttempts: 0, clearThrottle: true);
      final saved = await _store.write(reset.encode());
      if (saved is Failure<void>) return Failure(saved.code);
      _record = reset;
      return const Success(null);
    }
    final attempts = record.failedAttempts + 1;
    final delay = switch (attempts) {
      3 => const Duration(seconds: 5),
      4 => const Duration(seconds: 15),
      >= 5 => const Duration(seconds: 60),
      _ => Duration.zero,
    };
    final failed = record.copyWith(
      failedAttempts: attempts,
      throttleUntilUtc: delay == Duration.zero
          ? null
          : _clock.nowUtc().add(delay),
      clearThrottle: delay == Duration.zero,
    );
    final saved = await _store.write(failed.encode());
    if (saved is Failure<void>) return Failure(saved.code);
    _record = failed;
    return Failure(
      delay == Duration.zero
          ? FailureCode.incorrectPin
          : FailureCode.lockThrottled,
    );
  }

  FailureCode? _validateNewPin(String pin, String confirmation) {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) return FailureCode.invalidPin;
    if (pin != confirmation) return FailureCode.pinMismatch;
    return null;
  }

  bool _constantTimeEqual(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }

  FailureCode _biometricFailure(BiometricAuthenticationResult result) =>
      switch (result) {
        BiometricAuthenticationResult.cancelled =>
          FailureCode.biometricCancelled,
        BiometricAuthenticationResult.unavailable =>
          FailureCode.biometricUnavailable,
        BiometricAuthenticationResult.notEnrolled =>
          FailureCode.biometricNotEnrolled,
        BiometricAuthenticationResult.temporarilyLocked =>
          FailureCode.biometricTemporarilyLocked,
        BiometricAuthenticationResult.permanentlyLocked =>
          FailureCode.biometricPermanentlyLocked,
        _ => FailureCode.biometricFailed,
      };

  Result<void> _finishFailure(FailureCode code) {
    failure = code;
    _setBusy(false);
    return Failure(code);
  }

  Result<void> _finishStale() =>
      _finishFailure(FailureCode.authenticationStale);

  void clearFailure() {
    failure = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    busy = value;
    notifyListeners();
  }
}
