import 'package:flutter/foundation.dart';

import '../../../core/result.dart';
import '../../../core/clock.dart';
import '../domain/cloud_account.dart';
import 'authentication_contracts.dart';
import 'cloud_backend_contracts.dart';

final class AccountController extends ChangeNotifier {
  AccountController({
    required AuthenticationGateway gateway,
    required SecureSessionStore sessionStore,
    Clock clock = const SystemClock(),
    AuthenticatedBackendApi? backend,
  }) : _gateway = gateway,
       _sessionStore = sessionStore,
       _clock = clock,
       _backend = backend;

  final AuthenticationGateway _gateway;
  final SecureSessionStore _sessionStore;
  final Clock _clock;
  final AuthenticatedBackendApi? _backend;

  AccountSessionState state = AccountSessionState.localOnly;
  AuthenticatedSession? session;
  SessionSecrets? _secrets;
  FailureCode? failure;
  bool deletingAccount = false;
  int _generation = 0;
  DateTime? _otpAvailableAtUtc;

  CloudAccount? get account => session?.account;
  bool get isCloudConfigured => _gateway.isConfigured;
  bool get canUseCloudBackup =>
      state == AccountSessionState.authenticated &&
      _backend != null &&
      _secrets != null;

  Future<Result<CloudBackupMetadata>> uploadBackup(CloudBackupUpload upload) {
    final secrets = _secrets, backend = _backend;
    return secrets == null || backend == null
        ? Future.value(const Failure(FailureCode.cloudAuthenticationRequired))
        : backend.uploadBackup(secrets, upload);
  }

  Future<Result<List<CloudBackupMetadata>>> listBackups() {
    final secrets = _secrets, backend = _backend;
    return secrets == null || backend == null
        ? Future.value(const Failure(FailureCode.cloudAuthenticationRequired))
        : backend.listBackups(secrets);
  }

  Future<Result<List<int>>> retrieveBackup(String id) {
    final secrets = _secrets, backend = _backend;
    return secrets == null || backend == null
        ? Future.value(const Failure(FailureCode.cloudAuthenticationRequired))
        : backend.retrieveBackup(secrets, id);
  }

  Future<Result<void>> deleteBackup(String id) {
    final secrets = _secrets, backend = _backend;
    return secrets == null || backend == null
        ? Future.value(const Failure(FailureCode.cloudAuthenticationRequired))
        : backend.deleteBackup(secrets, id);
  }

  Duration get otpCooldownRemaining {
    final available = _otpAvailableAtUtc;
    if (available == null) return Duration.zero;
    final remaining = available.difference(_clock.nowUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> initialize() async {
    final generation = ++_generation;
    final stored = await _sessionStore.read();
    if (generation != _generation) return;
    switch (stored) {
      case Failure<AuthenticationBundle?>(:final code):
        state = AccountSessionState.requiresReauthentication;
        failure = code;
      case Success<AuthenticationBundle?>(value: null):
        state = AccountSessionState.localOnly;
        failure = null;
      case Success<AuthenticationBundle?>(:final value):
        if (!_gateway.isConfigured) {
          session = value!.session;
          _secrets = value.secrets;
          state = AccountSessionState.temporarilyUnavailable;
          failure = FailureCode.cloudConfigurationUnavailable;
          notifyListeners();
          return;
        }
        final restored = await _gateway.restoreSession(value!.secrets);
        if (generation != _generation) return;
        if (restored case Success<AuthenticationBundle>(:final value)) {
          await _accept(value, generation);
        } else {
          await _handleSessionFailure(
            value,
            (restored as Failure<AuthenticationBundle>).code,
          );
        }
    }
    notifyListeners();
  }

  void chooseCloudAccount() {
    if (state != AccountSessionState.localOnly) return;
    state = AccountSessionState.signedOut;
    failure = null;
    notifyListeners();
  }

  void continueLocalOnly() {
    if (state == AccountSessionState.authenticated) return;
    state = AccountSessionState.localOnly;
    failure = null;
    notifyListeners();
  }

  Future<Result<void>> signIn(AuthenticationProvider provider) async {
    if (!_gateway.isConfigured) {
      failure = FailureCode.cloudConfigurationUnavailable;
      notifyListeners();
      return const Failure(FailureCode.cloudConfigurationUnavailable);
    }
    if (state == AccountSessionState.authenticating) {
      return const Failure(FailureCode.authenticationProviderFailure);
    }
    final generation = ++_generation;
    state = AccountSessionState.authenticating;
    failure = null;
    notifyListeners();
    final result = await _gateway.signIn(provider);
    if (generation != _generation) {
      return const Failure(FailureCode.authenticationStale);
    }
    return switch (result) {
      Success<AuthenticationBundle>(:final value) => await _accept(
        value,
        generation,
      ),
      Failure<AuthenticationBundle>(:final code) => _authenticationFailed(code),
    };
  }

  Future<Result<void>> requestEmailOtp(String email) async {
    if (!_gateway.isConfigured) {
      return const Failure(FailureCode.cloudConfigurationUnavailable);
    }
    if (otpCooldownRemaining > Duration.zero) {
      return const Failure(FailureCode.rateLimited);
    }
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      return const Failure(FailureCode.authenticationProviderFailure);
    }
    final result = await _gateway.requestEmailOtp(normalized);
    if (result is Success<void>) {
      _otpAvailableAtUtc = _clock.nowUtc().add(const Duration(seconds: 60));
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (!_gateway.isConfigured) {
      return const Failure(FailureCode.cloudConfigurationUnavailable);
    }
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return const Failure(FailureCode.invalidOtp);
    }
    final generation = ++_generation;
    state = AccountSessionState.authenticating;
    failure = null;
    notifyListeners();
    final result = await _gateway.verifyEmailOtp(email: normalized, otp: otp);
    if (generation != _generation) {
      return const Failure(FailureCode.authenticationStale);
    }
    return switch (result) {
      Success<AuthenticationBundle>(:final value) => await _accept(
        value,
        generation,
      ),
      Failure<AuthenticationBundle>(:final code) => _authenticationFailed(code),
    };
  }

  Future<Result<void>> refresh() async {
    final secrets = _secrets;
    if ((state != AccountSessionState.authenticated &&
            state != AccountSessionState.temporarilyUnavailable) ||
        secrets == null) {
      return const Failure(FailureCode.unauthorized);
    }
    if (!_gateway.isConfigured) {
      state = AccountSessionState.temporarilyUnavailable;
      failure = FailureCode.cloudConfigurationUnavailable;
      notifyListeners();
      return const Failure(FailureCode.cloudConfigurationUnavailable);
    }
    final generation = ++_generation;
    final result = await _gateway.refreshSession(secrets);
    if (generation != _generation) {
      return const Failure(FailureCode.authenticationStale);
    }
    return switch (result) {
      Success<AuthenticationBundle>(:final value) => await _accept(
        value,
        generation,
      ),
      Failure<AuthenticationBundle>(:final code) => await _refreshFailed(code),
    };
  }

  Future<Result<void>> signOut() async {
    final secrets = _secrets;
    final generation = ++_generation;
    if (secrets != null) await _gateway.signOut(secrets);
    final cleared = await _sessionStore.clear();
    if (generation != _generation) {
      return const Failure(FailureCode.authenticationStale);
    }
    if (cleared case Failure<void>(:final code)) {
      failure = code;
      notifyListeners();
      return Failure(code);
    }
    session = null;
    _secrets = null;
    state = AccountSessionState.signedOut;
    failure = null;
    notifyListeners();
    return const Success(null);
  }

  /// Deletes the cloud account. The device ledger and App Lock remain intact.
  /// A failed or interrupted server request never claims deletion succeeded.
  Future<Result<void>> deleteAccount() async {
    final secrets = _secrets;
    if (state != AccountSessionState.authenticated || secrets == null) {
      return const Failure(FailureCode.cloudAuthenticationRequired);
    }
    if (deletingAccount) return const Failure(FailureCode.authenticationStale);
    deletingAccount = true;
    failure = null;
    notifyListeners();
    final generation = _generation;
    try {
      final result = await _gateway.revokeAccount(secrets);
      if (generation != _generation) {
        return const Failure(FailureCode.authenticationStale);
      }
      if (result case Failure<void>(:final code)) {
        failure = code;
        notifyListeners();
        return Failure(code);
      }
      // Server has removed Auth last. Clear secure credentials before reporting
      // success; on a storage failure the next launch must not reuse this user.
      ++_generation;
      session = null;
      _secrets = null;
      state = AccountSessionState.localOnly;
      final cleared = await _sessionStore.clear();
      await _gateway.signOut(secrets);
      if (cleared is Failure<void>) {
        failure = cleared.code;
        notifyListeners();
        // Cloud deletion has already completed. The stale local credential
        // cannot restore a deleted Auth user; surface the cleanup warning.
        return const Success(null);
      }
      failure = null;
      notifyListeners();
      return const Success(null);
    } finally {
      deletingAccount = false;
      notifyListeners();
    }
  }

  Future<Result<void>> _accept(
    AuthenticationBundle bundle,
    int generation,
  ) async {
    final saved = await _sessionStore.write(bundle);
    if (generation != _generation) {
      return const Failure(FailureCode.authenticationStale);
    }
    if (saved case Failure<void>(:final code)) {
      await _gateway.signOut(bundle.secrets);
      return _authenticationFailed(code);
    }
    session = bundle.session;
    _secrets = bundle.secrets;
    state = AccountSessionState.authenticated;
    failure = null;
    notifyListeners();
    return const Success(null);
  }

  Result<void> _authenticationFailed(FailureCode code) {
    state = AccountSessionState.signedOut;
    failure = code;
    notifyListeners();
    return Failure(code);
  }

  Future<Result<void>> _refreshFailed(FailureCode code) async {
    final current = session;
    final secrets = _secrets;
    if (current != null && secrets != null) {
      await _handleSessionFailure(
        AuthenticationBundle(session: current, secrets: secrets),
        code,
      );
    }
    notifyListeners();
    return Failure(code);
  }

  Future<void> _handleSessionFailure(
    AuthenticationBundle previous,
    FailureCode code,
  ) async {
    if (_isPermanentSessionFailure(code)) {
      final cleared = await _sessionStore.clear();
      session = null;
      _secrets = null;
      state = AccountSessionState.requiresReauthentication;
      failure = cleared is Failure<void> ? cleared.code : code;
      return;
    } else {
      session = previous.session;
      _secrets = previous.secrets;
      state = AccountSessionState.temporarilyUnavailable;
    }
    failure = code;
  }

  bool _isPermanentSessionFailure(FailureCode code) =>
      code == FailureCode.sessionExpired || code == FailureCode.unauthorized;
}
