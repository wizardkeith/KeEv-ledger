import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/app_lock/application/app_lock_contracts.dart';
import 'package:ledger/features/app_lock/application/app_lock_controller.dart';
import 'package:ledger/features/app_lock/infrastructure/pbkdf2_pin_deriver.dart';

void main() {
  late MemoryLockStore store;
  late FakeBiometrics biometrics;
  late FakeClock clock;
  late AppLockController controller;

  setUp(() async {
    store = MemoryLockStore();
    biometrics = FakeBiometrics();
    clock = FakeClock(DateTime.utc(2026, 9, 21));
    controller = makeController(store, biometrics, clock);
    await controller.initialize();
  });

  tearDown(() => controller.dispose());

  test('PIN setup requires confirmation and stores no raw PIN', () async {
    expect(await controller.setupPin('1234', '4321'), isA<Failure<void>>());
    expect(store.value, isNull);
    expect(await controller.setupPin('1234', '1234'), isA<Success<void>>());
    expect(controller.state, AppLockState.unlocked);
    expect(store.value, isNot(contains('1234')));
    controller.lock();
    expect(await controller.unlockWithPin('9999'), isA<Failure<void>>());
    expect(controller.state, AppLockState.locked);
    expect(await controller.unlockWithPin('1234'), isA<Success<void>>());
    expect(controller.state, AppLockState.unlocked);
  });

  test('PBKDF2 verifier changes with salt and is fixed length', () async {
    final deriver = Pbkdf2PinDeriver(random: Random(1));
    final first = await deriver.derive(
      pin: '1234',
      salt: List<int>.filled(16, 1),
      iterations: 1000,
    );
    final second = await deriver.derive(
      pin: '1234',
      salt: List<int>.filled(16, 2),
      iterations: 1000,
    );
    expect(first, hasLength(32));
    expect(second, hasLength(32));
    expect(first, isNot(second));
  });

  test(
    'change PIN invalidates old PIN and disable requires authentication',
    () async {
      await controller.setupPin('1234', '1234');
      expect(
        await controller.changePin(
          currentPin: '9999',
          newPin: '5678',
          confirmation: '5678',
        ),
        isA<Failure<void>>(),
      );
      expect(
        await controller.changePin(
          currentPin: '1234',
          newPin: '5678',
          confirmation: '5678',
        ),
        isA<Success<void>>(),
      );
      controller.lock();
      expect(await controller.unlockWithPin('1234'), isA<Failure<void>>());
      expect(await controller.unlockWithPin('5678'), isA<Success<void>>());
      expect(await controller.disable('9999'), isA<Failure<void>>());
      expect(controller.isEnabled, isTrue);
      expect(await controller.disable('5678'), isA<Success<void>>());
      expect(controller.state, AppLockState.disabled);
      expect(store.value, isNull);
    },
  );

  test(
    'throttle survives controller rebuild and expires on fake clock',
    () async {
      await controller.setupPin('1234', '1234');
      controller.lock();
      await controller.unlockWithPin('9999');
      await controller.unlockWithPin('9999');
      final third = await controller.unlockWithPin('9999');
      expect((third as Failure<void>).code, FailureCode.lockThrottled);

      controller.dispose();
      controller = makeController(store, biometrics, clock);
      await controller.initialize();
      expect(controller.state, AppLockState.locked);
      final throttled = await controller.unlockWithPin('1234');
      expect((throttled as Failure<void>).code, FailureCode.lockThrottled);
      clock.advance(const Duration(seconds: 6));
      expect(await controller.unlockWithPin('1234'), isA<Success<void>>());
      expect(controller.throttleRemaining, Duration.zero);
    },
  );

  test(
    'biometric success unlocks; failure and cancellation preserve PIN fallback',
    () async {
      await controller.setupPin('1234', '1234');
      expect(
        await controller.setBiometrics(enabled: true, currentPin: '1234'),
        isA<Success<void>>(),
      );
      controller.lock();
      biometrics.next = BiometricAuthenticationResult.failed;
      expect(
        await controller.unlockWithBiometrics('Unlock'),
        isA<Failure<void>>(),
      );
      expect(controller.state, AppLockState.locked);
      biometrics.next = BiometricAuthenticationResult.cancelled;
      await controller.unlockWithBiometrics('Unlock');
      expect(controller.state, AppLockState.locked);
      expect(await controller.unlockWithPin('1234'), isA<Success<void>>());
      controller.lock();
      biometrics.next = BiometricAuthenticationResult.success;
      expect(
        await controller.unlockWithBiometrics('Unlock'),
        isA<Success<void>>(),
      );
      expect(controller.state, AppLockState.unlocked);
    },
  );

  test(
    'only one biometric prompt runs and stale success cannot unlock',
    () async {
      await controller.setupPin('1234', '1234');
      await controller.setBiometrics(enabled: true, currentPin: '1234');
      controller.lock();
      biometrics.pending = Completer<BiometricAuthenticationResult>();
      final first = controller.unlockWithBiometrics('Unlock');
      final duplicate = await controller.unlockWithBiometrics('Unlock');
      expect(
        (duplicate as Failure<void>).code,
        FailureCode.biometricUnavailable,
      );
      controller.lock();
      biometrics.pending!.complete(BiometricAuthenticationResult.success);
      final stale = await first;
      expect((stale as Failure<void>).code, FailureCode.authenticationStale);
      expect(controller.state, AppLockState.locked);
      expect(biometrics.cancelCount, greaterThan(0));
    },
  );

  test(
    'corrupt, missing and failed secure storage never grant access',
    () async {
      controller.dispose();
      store.value = '{broken';
      controller = makeController(store, biometrics, clock);
      await controller.initialize();
      expect(controller.state, AppLockState.configurationError);

      controller.dispose();
      store = MemoryLockStore()..failRead = true;
      controller = makeController(store, biometrics, clock);
      await controller.initialize();
      expect(controller.state, AppLockState.configurationError);
    },
  );

  test(
    'storage write failure does not create or replace a credential',
    () async {
      store.failNextWrite = true;
      final failed = await controller.setupPin('1234', '1234');
      expect(
        (failed as Failure<void>).code,
        FailureCode.secureStorageUnavailable,
      );
      expect(controller.state, AppLockState.disabled);
      expect(store.value, isNull);

      await controller.setupPin('1234', '1234');
      final original = store.value;
      store.failNextWrite = true;
      final change = await controller.changePin(
        currentPin: '1234',
        newPin: '5678',
        confirmation: '5678',
      );
      expect(change, isA<Failure<void>>());
      expect(store.value, original);
    },
  );

  test(
    'lock disabled is unaffected; enabled background-style lock is explicit',
    () async {
      controller.lock();
      expect(controller.state, AppLockState.disabled);
      await controller.setupPin('1234', '1234');
      controller.lock();
      expect(controller.state, AppLockState.locked);
    },
  );
}

AppLockController makeController(
  MemoryLockStore store,
  FakeBiometrics biometrics,
  FakeClock clock,
) => AppLockController(
  store: store,
  pinDeriver: FakePinDeriver(),
  biometrics: biometrics,
  clock: clock,
);

final class MemoryLockStore implements AppLockSecureStore {
  String? value;
  bool failRead = false, failNextWrite = false, failDelete = false;

  @override
  Future<Result<String?>> read() async => failRead
      ? const Failure(FailureCode.secureStorageUnavailable)
      : Success(value);

  @override
  Future<Result<void>> write(String next) async {
    if (failNextWrite) {
      failNextWrite = false;
      return const Failure(FailureCode.secureStorageUnavailable);
    }
    value = next;
    return const Success(null);
  }

  @override
  Future<Result<void>> delete() async {
    if (failDelete) {
      return const Failure(FailureCode.secureStorageUnavailable);
    }
    value = null;
    return const Success(null);
  }
}

final class FakePinDeriver implements PinDeriver {
  int saltSeed = 0;

  @override
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    final total = pin.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return List<int>.generate(
      32,
      (index) => (total + salt[index % salt.length] + index) & 0xff,
      growable: false,
    );
  }

  @override
  List<int> randomSalt() => List<int>.generate(
    16,
    (index) => (index + ++saltSeed) & 0xff,
    growable: false,
  );
}

final class FakeBiometrics implements BiometricAuthenticator {
  BiometricCapability available = BiometricCapability.available;
  BiometricAuthenticationResult next = BiometricAuthenticationResult.success;
  Completer<BiometricAuthenticationResult>? pending;
  int promptCount = 0, cancelCount = 0;

  @override
  Future<BiometricCapability> capability() async => available;

  @override
  Future<BiometricAuthenticationResult> authenticate(String reason) {
    promptCount++;
    return pending?.future ?? Future.value(next);
  }

  @override
  Future<void> cancel() async => cancelCount++;
}

final class FakeClock implements Clock {
  FakeClock(this.value);
  DateTime value;
  @override
  DateTime nowUtc() => value;
  void advance(Duration duration) => value = value.add(duration);
}
