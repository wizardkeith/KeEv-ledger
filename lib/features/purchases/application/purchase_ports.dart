import '../domain/purchase.dart';

abstract interface class StoreGateway {
  Stream<StoreTransaction> get updates;
  Future<bool> isAvailable();
  Future<StoreProductCatalogue> loadProducts(Set<String> ids);
  Future<void> buy(StoreProduct product, String opaqueAccountId);
  Future<void> restore(String opaqueAccountId);
  Future<bool> complete(StoreTransaction transaction);
}

abstract interface class PurchaseVerificationGateway {
  Future<VerificationResult> verify(
    StoreTransaction transaction,
    String accountId,
  );
}

abstract interface class EntitlementRemoteStore {
  Future<VerifiedEntitlement?> refresh(String accountId);
}

/// The production client cannot verify Apple or Play server state in 8A.
final class UnavailablePurchaseVerifier implements PurchaseVerificationGateway {
  const UnavailablePurchaseVerifier();
  @override
  Future<VerificationResult> verify(
    StoreTransaction transaction,
    String accountId,
  ) async => const VerificationResult(VerificationOutcome.unavailable);
}

abstract interface class PurchaseJournal {
  Future<Map<String, StoreTransaction>> readPending();
  Future<void> put(StoreTransaction transaction);
  Future<void> remove(String key);
}

abstract interface class EntitlementCache {
  Future<VerifiedEntitlement?> read(String accountId);
  Future<void> write(VerifiedEntitlement value);
  Future<void> remove(String accountId);
}

final class PurchaseCatalogue {
  const PurchaseCatalogue(this.productIds);
  final Set<String> productIds;
  bool get configured => productIds.isNotEmpty;
}
