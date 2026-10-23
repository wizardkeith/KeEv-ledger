import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/purchases/application/purchase_controller.dart';
import 'package:ledger/features/purchases/application/purchase_ports.dart';
import 'package:ledger/features/purchases/application/purchase_ads_entitlement.dart';
import 'package:ledger/features/purchases/domain/purchase.dart';
import 'package:ledger/features/purchases/domain/account_binding.dart';

const product = StoreProduct(
  id: 'test.owner.supplied',
  title: 'Test',
  description: 'Store period',
  localizedPrice: '¥500',
  currencyCode: 'JPY',
  period: SubscriptionPeriod(1, SubscriptionPeriodUnit.month),
);
const purchase = StoreTransaction(
  platform: StoreKind.apple,
  id: 'txn-1',
  productId: 'test.owner.supplied',
  status: StoreEventStatus.purchased,
  verificationData: 'opaque-proof',
  pendingCompletion: true,
  accountId: 'account-a',
);

final class FakeStore implements StoreGateway {
  final events = StreamController<StoreTransaction>.broadcast(sync: true);
  Future<void> dispose() => events.close();
  int completions = 0, buys = 0, restores = 0;
  String? restoredAccount;
  Set<String> missingIds = {};
  @override
  Stream<StoreTransaction> get updates => events.stream;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<StoreProductCatalogue> loadProducts(Set<String> ids) async =>
      StoreProductCatalogue(products: [product], missingProductIds: missingIds);
  @override
  Future<void> buy(StoreProduct product, String opaqueAccountId) async {
    buys++;
  }

  @override
  Future<void> restore(String opaqueAccountId) async {
    restores++;
    restoredAccount = opaqueAccountId;
  }

  @override
  Future<bool> complete(StoreTransaction transaction) async {
    completions++;
    return true;
  }
}

final class MemoryJournal implements PurchaseJournal {
  final pending = <String, StoreTransaction>{};
  @override
  Future<Map<String, StoreTransaction>> readPending() async => Map.of(pending);
  @override
  Future<void> put(StoreTransaction transaction) async {
    pending[transaction.key] = transaction;
  }

  @override
  Future<void> remove(String key) async {
    pending.remove(key);
  }
}

final class MemoryEntitlements implements EntitlementCache {
  final values = <String, VerifiedEntitlement>{};
  @override
  Future<VerifiedEntitlement?> read(String accountId) async =>
      values[accountId];
  @override
  Future<void> write(VerifiedEntitlement value) async {
    values[value.accountId] = value;
  }

  @override
  Future<void> remove(String accountId) async {
    values.remove(accountId);
  }
}

final class FakeVerifier implements PurchaseVerificationGateway {
  VerificationOutcome outcome = VerificationOutcome.unavailable;
  bool acknowledgementPending = false;
  int calls = 0;
  @override
  Future<VerificationResult> verify(
    StoreTransaction transaction,
    String accountId,
  ) async {
    calls++;
    return VerificationResult(
      outcome,
      acknowledgementPending: acknowledgementPending,
      entitlement: outcome == VerificationOutcome.verified
          ? VerifiedEntitlement(
              accountId: accountId,
              status: EntitlementStatus.active,
              adFree: true,
              verifiedAtUtc: DateTime.now().toUtc(),
              expiresAtUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
            )
          : null,
    );
  }
}

final class FakeEntitlementRemote implements EntitlementRemoteStore {
  final values = <String, VerifiedEntitlement>{};
  bool offline = false;
  @override
  Future<VerifiedEntitlement?> refresh(String accountId) async {
    if (offline) throw StateError('offline');
    return values[accountId];
  }
}

void main() {
  late FakeStore store;
  late FakeVerifier verifier;
  late MemoryJournal journal;
  late String? account;
  late PurchaseController controller;
  setUp(() {
    store = FakeStore();
    verifier = FakeVerifier();
    journal = MemoryJournal();
    account = 'account-a';
    controller = PurchaseController(
      store: store,
      verifier: verifier,
      journal: journal,
      catalogue: const PurchaseCatalogue({'test.owner.supplied'}),
      accountId: () => account,
      purchaseEnabled: true,
    );
  });
  tearDown(() async {
    controller.dispose();
    await store.dispose();
  });

  test(
    'pending purchase and production unavailable verifier never unlock',
    () async {
      await controller.handle(
        const StoreTransaction(
          platform: StoreKind.apple,
          id: 'txn-1',
          productId: 'test.owner.supplied',
          status: StoreEventStatus.pending,
          verificationData: '',
          pendingCompletion: false,
        ),
      );
      expect(controller.adFree, false);
      await controller.handle(purchase);
      expect(controller.adFree, false);
      expect(journal.pending, contains(purchase.key));
      expect(store.completions, 0); // Server unavailable: keep transaction unfinished.
    },
  );

  test(
    'verified result removes ads, completes once, duplicate callback ignored',
    () async {
      verifier.outcome = VerificationOutcome.verified;
      await controller.handle(purchase);
      await controller.handle(purchase);
      expect(PurchaseAdsEntitlement(controller).adsAllowed, false);
      expect(store.completions, 1);
      expect(verifier.calls, 1);
      expect(journal.pending, isEmpty);
      account = 'account-b';
      controller.accountChanged();
      expect(controller.adFree, false);
    },
  );

  test('wrong account cannot take a previously bound transaction', () async {
    journal.pending[purchase.key] = purchase;
    account = 'account-b';
    verifier.outcome = VerificationOutcome.verified;
    await controller.handle(purchase);
    expect(verifier.calls, 0);
    expect(controller.adFree, false);
    expect(journal.pending, contains(purchase.key));
  });

  test(
    'restore uses same trusted verifier; missing verifier fails closed',
    () async {
      await controller.start();
      await controller.restore();
      await controller.handle(
        const StoreTransaction(
          platform: StoreKind.apple,
          id: 'txn-2',
          productId: 'test.owner.supplied',
          status: StoreEventStatus.restored,
          verificationData: 'opaque-proof',
          pendingCompletion: true,
        ),
      );
      expect(store.restores, 1);
      expect(store.restoredAccount, 'account-a');
      expect(controller.adFree, false);
      expect(journal.pending, contains('apple:txn-2'));
    },
  );

  test('production purchase disabled even with store product', () async {
    final production = PurchaseController(
      store: store,
      verifier: const UnavailablePurchaseVerifier(),
      journal: journal,
      catalogue: const PurchaseCatalogue({'test.owner.supplied'}),
      accountId: () => account,
    );
    await production.loadProducts();
    expect(production.products.single.localizedPrice, '¥500');
    await production.buy(product);
    expect(store.buys, 0);
    production.dispose();
  });

  test('store binding A survives wrong-account restore under B', () async {
    account = 'account-b';
    await controller.restore();
    await controller.handle(
      StoreTransaction(
        platform: StoreKind.apple,
        id: 'restored-a',
        productId: product.id,
        status: StoreEventStatus.restored,
        verificationData: 'proof-a',
        pendingCompletion: true,
        accountId: 'account-a',
      ),
    );
    expect(journal.pending['apple:restored-a']?.accountId, 'account-a');
    expect(controller.failure, PurchaseFailure.accountMismatch);
    expect(verifier.calls, 0);
    expect(controller.adFree, false);
    account = 'account-a';
    verifier.outcome = VerificationOutcome.verified;
    controller.accountChanged();
    await Future<void>.delayed(Duration.zero);
    await controller.retryPending();
    expect(controller.adFree, true);
  });

  test('store, journal, initiated, restore binding precedence', () {
    expect(
      PurchaseAccountBinding.resolve(
        store: 'A',
        journal: 'B',
        initiated: 'C',
        restore: 'D',
      ).accountId,
      'A',
    );
    expect(
      PurchaseAccountBinding.resolve(store: 'A', journal: 'B').conflict,
      true,
    );
    expect(
      PurchaseAccountBinding.resolve(journal: 'B', initiated: 'C').accountId,
      'B',
    );
    expect(
      PurchaseAccountBinding.resolve(initiated: 'C', restore: 'D').accountId,
      'C',
    );
    expect(PurchaseAccountBinding.resolve(restore: 'D').accountId, 'D');
    expect(
      PurchaseAccountBinding.resolve(store: 'A', journal: 'A').conflict,
      false,
    );
  });

  test('partial catalogue exposes missing configured products', () async {
    store.missingIds = {'missing.product'};
    await controller.loadProducts();
    expect(controller.products.single.id, product.id);
    expect(controller.missingProductIds, contains('missing.product'));
    expect(controller.failure, PurchaseFailure.catalogueIncomplete);
  });

  test('subscription period parses store metadata, not description', () {
    expect(
      SubscriptionPeriod.fromAppleUnitName(1, 'month')?.unit,
      SubscriptionPeriodUnit.month,
    );
    expect(SubscriptionPeriod.fromAppleUnitName(2, 'week')?.value, 2);
    expect(SubscriptionPeriod.fromAppleUnitName(1, 'unknown'), isNull);
    expect(SubscriptionPeriod.fromPlayIso8601('P3M')?.value, 3);
    expect(
      SubscriptionPeriod.fromPlayIso8601('P3M')?.unit,
      SubscriptionPeriodUnit.month,
    );
    expect(
      SubscriptionPeriod.fromPlayIso8601('P1Y')?.unit,
      SubscriptionPeriodUnit.year,
    );
    expect(SubscriptionPeriod.fromPlayIso8601('bad'), isNull);
    expect(product.period?.unit, SubscriptionPeriodUnit.month);
    expect(product.description, isNot(product.period.toString()));
  });

  test('backend refresh grants adFree, account switch does not inherit', () async {
    final remote = FakeEntitlementRemote();
    remote.values['account-a'] = VerifiedEntitlement(
      accountId: 'account-a', status: EntitlementStatus.active, adFree: true,
      verifiedAtUtc: DateTime.now().toUtc(),
      expiresAtUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
    );
    final refreshed = PurchaseController(
      store: store, verifier: verifier, journal: journal,
      catalogue: const PurchaseCatalogue({'test.owner.supplied'}),
      accountId: () => account, entitlementRemote: remote,
    );
    await refreshed.refreshEntitlements();
    expect(refreshed.adFree, true);
    account = 'account-b';
    refreshed.accountChanged();
    expect(refreshed.adFree, false);
    await refreshed.refreshEntitlements();
    expect(refreshed.adFree, false);
    refreshed.dispose();
  });

  test('Google backend acknowledgement pending retains journal and avoids client completion', () async {
    verifier.outcome = VerificationOutcome.verified;
    verifier.acknowledgementPending = true;
    const google = StoreTransaction(
      platform: StoreKind.google,id:'google-1',productId:'test.owner.supplied',
      status:StoreEventStatus.purchased,verificationData:'opaque-proof',
      pendingCompletion:true,accountId:'account-a',
    );
    await controller.handle(google);
    expect(controller.adFree, true);
    expect(store.completions, 0);
    expect(journal.pending, contains(google.key));
    verifier.acknowledgementPending = false;
    await controller.retryPending();
    expect(store.completions, 1);
    expect(journal.pending, isEmpty);
  });

  test('pending verification persists across controller restart', () async {
    await controller.handle(purchase);
    expect(journal.pending, contains(purchase.key));
    final recovered = PurchaseController(
      store: store,
      verifier: verifier,
      journal: journal,
      catalogue: const PurchaseCatalogue({'test.owner.supplied'}),
      accountId: () => account,
      purchaseEnabled: true,
    );
    verifier.outcome = VerificationOutcome.verified;
    await recovered.start();
    expect(recovered.adFree, true);
    recovered.dispose();
  });

  test(
    'offline verified cache is account scoped, unverified purchase cannot fill it',
    () async {
      final cache = MemoryEntitlements();
      final now = DateTime.now().toUtc();
      cache.values['account-a'] = VerifiedEntitlement(
        accountId: 'account-a',
        status: EntitlementStatus.active,
        adFree: true,
        verifiedAtUtc: now,
        expiresAtUtc: now.add(const Duration(days: 1)),
      );
      final cached = PurchaseController(
        store: store,
        verifier: const UnavailablePurchaseVerifier(),
        journal: journal,
        catalogue: const PurchaseCatalogue({'test.owner.supplied'}),
        accountId: () => account,
        cache: cache,
      );
      await cached.start();
      expect(cached.adFree, true);
      account = 'account-b';
      cached.accountChanged();
      await Future<void>.delayed(Duration.zero);
      expect(cached.adFree, false);
      cached.dispose();
    },
  );
}
