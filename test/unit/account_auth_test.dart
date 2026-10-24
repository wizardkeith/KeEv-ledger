import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/bookkeeping_runtime.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/account/application/account_controller.dart';
import 'package:ledger/features/account/application/authentication_contracts.dart';
import 'package:ledger/features/account/domain/cloud_account.dart';
import 'package:ledger/features/app_lock/application/app_lock_contracts.dart';
import 'package:ledger/features/app_lock/application/app_lock_controller.dart';
import 'package:ledger/features/bookkeeping/domain/bookkeeping.dart';
import 'package:ledger/infrastructure/local/ledger_database.dart'
    show LedgerDatabase;

void main() {
  test('Local Only is the default and requires no gateway call', () async {
    final gateway = _FakeGateway();
    final controller = AccountController(
      gateway: gateway,
      sessionStore: _MemorySessionStore(),
    );
    await controller.initialize();
    expect(controller.state, AccountSessionState.localOnly);
    expect(gateway.restoreCalls, 0);
  });

  test('fake authentication transitions and securely stores session', () async {
    final store = _MemorySessionStore();
    final gateway = _FakeGateway()..signInResult = Success(_bundle());
    final controller = AccountController(gateway: gateway, sessionStore: store);
    await controller.initialize();
    controller.chooseCloudAccount();
    final result = await controller.signIn(AuthenticationProvider.apple);
    expect(result, isA<Success<void>>());
    expect(controller.state, AccountSessionState.authenticated);
    expect(controller.account?.id, 'account-1');
    expect(store.writes, 1);
    expect(store.value?.secrets.accessToken, 'access-secret');
  });

  test('cancellation and provider failure never authenticate', () async {
    for (final code in [
      FailureCode.cloudAuthenticationCancelled,
      FailureCode.authenticationProviderFailure,
    ]) {
      final controller = AccountController(
        gateway: _FakeGateway()..signInResult = Failure(code),
        sessionStore: _MemorySessionStore(),
      );
      await controller.initialize();
      final result = await controller.signIn(AuthenticationProvider.google);
      expect((result as Failure<void>).code, code);
      expect(controller.state, AccountSessionState.signedOut);
      expect(controller.account, isNull);
    }
  });

  test(
    'stored session restores through gateway; expiry requires reauth',
    () async {
      final stored = _bundle();
      final store = _MemorySessionStore()..value = stored;
      final gateway = _FakeGateway()..restoreResult = Success(stored);
      final restored = AccountController(gateway: gateway, sessionStore: store);
      await restored.initialize();
      expect(restored.state, AccountSessionState.authenticated);
      expect(gateway.restoreCalls, 1);

      final expiredStore = _MemorySessionStore()..value = stored;
      final expired = AccountController(
        gateway: _FakeGateway()
          ..restoreResult = const Failure(FailureCode.sessionExpired),
        sessionStore: expiredStore,
      );
      await expired.initialize();
      expect(expired.state, AccountSessionState.requiresReauthentication);
      expect(expiredStore.value, isNull);
    },
  );

  test('secure-store failure never reports authenticated', () async {
    final store = _MemorySessionStore()..failWrites = true;
    final gateway = _FakeGateway()..signInResult = Success(_bundle());
    final controller = AccountController(gateway: gateway, sessionStore: store);
    await controller.initialize();
    final result = await controller.signIn(AuthenticationProvider.apple);
    expect(
      (result as Failure<void>).code,
      FailureCode.secureSessionStorageUnavailable,
    );
    expect(controller.state, AccountSessionState.signedOut);
    expect(gateway.signOutCalls, 1);
  });

  test('logout clears cloud secrets without deleting local ledger', () async {
    final database = LedgerDatabase(NativeDatabase.memory());
    final runtime = BookkeepingRuntime(database);
    addTearDown(runtime.close);
    final profile = (await runtime.profile() as Success<LocalId>).value;
    final created = await runtime.service.createAccount(
      profileId: profile,
      name: 'Cash',
      kind: AccountKind.cash,
      currency: Currency.hkd,
      openingBalance: Money.zero(Currency.hkd),
      openingDate: BusinessDate('2026-09-21'),
    );
    expect(created, isA<Success<Account>>());

    final store = _MemorySessionStore();
    final gateway = _FakeGateway()..signInResult = Success(_bundle());
    final controller = AccountController(gateway: gateway, sessionStore: store);
    await controller.initialize();
    await controller.signIn(AuthenticationProvider.emailOtp);
    expect(await controller.signOut(), isA<Success<void>>());
    expect(store.value, isNull);
    expect(controller.state, AccountSessionState.signedOut);
    final accounts = await runtime.service.accounts.list(profile);
    expect((accounts as Success<List<Account>>).value, hasLength(1));
  });

  test('local app lock and cloud account states remain independent', () async {
    final lock = AppLockController(
      store: _LockStore(),
      pinDeriver: _PinDeriver(),
      biometrics: _NoBiometrics(),
      clock: const SystemClock(),
    );
    await lock.initialize();
    final account = AccountController(
      gateway: _FakeGateway()..signInResult = Success(_bundle()),
      sessionStore: _MemorySessionStore(),
    );
    await account.initialize();
    await account.signIn(AuthenticationProvider.apple);
    expect(account.state, AccountSessionState.authenticated);
    expect(lock.state, AppLockState.disabled);

    await lock.setupPin('2468', '2468');
    await account.signOut();
    expect(lock.state, AppLockState.unlocked);
    expect(account.state, AccountSessionState.signedOut);
  });

  test('cloud deletion failure keeps account and ledger; retry preserves device book', () async {
    final database = LedgerDatabase(NativeDatabase.memory());
    final runtime = BookkeepingRuntime(database);
    addTearDown(runtime.close);
    final profile = (await runtime.profile() as Success<LocalId>).value;
    expect(
      await runtime.service.createAccount(
        profileId: profile,
        name: 'Cash',
        kind: AccountKind.cash,
        currency: Currency.hkd,
        openingBalance: Money.zero(Currency.hkd),
        openingDate: BusinessDate('2026-09-21'),
      ),
      isA<Success<Account>>(),
    );
    final store = _MemorySessionStore();
    final gateway = _FakeGateway()
      ..signInResult = Success(_bundle())
      ..revokeResult = const Failure(FailureCode.backendUnavailable);
    final controller = AccountController(gateway: gateway, sessionStore: store);
    await controller.initialize();
    await controller.signIn(AuthenticationProvider.apple);
    expect(await controller.deleteAccount(), isA<Failure<void>>());
    expect(controller.account?.id, 'account-1');
    expect(store.value, isNotNull);
    gateway.revokeResult = const Success(null);
    expect(await controller.deleteAccount(), isA<Success<void>>());
    expect(controller.state, AccountSessionState.localOnly);
    expect(store.value, isNull);
    expect(
      (await runtime.service.accounts.list(
        profile,
      ) as Success<List<Account>>).value,
      hasLength(1),
    );
  });
}

AuthenticationBundle _bundle() => AuthenticationBundle(
  session: AuthenticatedSession(
    account: CloudAccount(
      id: 'account-1',
      identities: const [
        ProviderIdentity(
          provider: AuthenticationProvider.apple,
          subject: 'provider-subject',
        ),
      ],
      email: 'owner@example.invalid',
      createdAtUtc: DateTime.utc(2026, 9, 21),
    ),
    expiresAtUtc: DateTime.utc(2026, 9, 21, 13),
    canRefresh: true,
  ),
  secrets: const SessionSecrets(
    accessToken: 'access-secret',
    refreshToken: 'refresh-secret',
  ),
);

final class _MemorySessionStore implements SecureSessionStore {
  AuthenticationBundle? value;
  int writes = 0;
  bool failWrites = false;

  @override
  Future<Result<AuthenticationBundle?>> read() async => Success(value);

  @override
  Future<Result<void>> write(AuthenticationBundle next) async {
    if (failWrites) {
      return const Failure(FailureCode.secureSessionStorageUnavailable);
    }
    writes++;
    value = next;
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    value = null;
    return const Success(null);
  }
}

final class _FakeGateway implements AuthenticationGateway {
  Result<AuthenticationBundle> signInResult = const Failure(
    FailureCode.backendUnavailable,
  );
  Result<AuthenticationBundle> restoreResult = const Failure(
    FailureCode.sessionExpired,
  );
  int restoreCalls = 0;
  int signOutCalls = 0;
  Result<void> revokeResult = const Success(null);

  @override
  bool get isConfigured => true;

  @override
  Future<Result<AuthenticationBundle>> signIn(
    AuthenticationProvider provider,
  ) async => signInResult;

  @override
  Future<Result<void>> requestEmailOtp(String email) async =>
      const Success(null);

  @override
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async => signInResult;

  @override
  Future<Result<AuthenticationBundle>> restoreSession(
    SessionSecrets secrets,
  ) async {
    restoreCalls++;
    return restoreResult;
  }

  @override
  Future<Result<AuthenticationBundle>> refreshSession(
    SessionSecrets secrets,
  ) async => restoreResult;

  @override
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets) async =>
      Success(_bundle().session.account);

  @override
  Future<Result<void>> signOut(SessionSecrets secrets) async {
    signOutCalls++;
    return const Success(null);
  }

  @override
  Future<Result<void>> revokeAccount(SessionSecrets secrets) async =>
      revokeResult;
}

final class _LockStore implements AppLockSecureStore {
  String? value;
  @override
  Future<Result<String?>> read() async => Success(value);
  @override
  Future<Result<void>> write(String next) async {
    value = next;
    return const Success(null);
  }

  @override
  Future<Result<void>> delete() async {
    value = null;
    return const Success(null);
  }
}

final class _PinDeriver implements PinDeriver {
  @override
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async => List<int>.generate(
    32,
    (index) => (pin.codeUnitAt(index % pin.length) + salt[index % 16]) & 255,
  );

  @override
  List<int> randomSalt() => List<int>.generate(16, (index) => index + 1);
}

final class _NoBiometrics implements BiometricAuthenticator {
  @override
  Future<BiometricCapability> capability() async =>
      BiometricCapability.unavailable;
  @override
  Future<BiometricAuthenticationResult> authenticate(String reason) async =>
      BiometricAuthenticationResult.unavailable;
  @override
  Future<void> cancel() async {}
}
