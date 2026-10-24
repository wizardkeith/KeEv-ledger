import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/purchase.dart';
import '../domain/account_binding.dart';
import 'purchase_ports.dart';

/// One app-lifetime owner of the purchase stream and verification journal.
final class PurchaseController extends ChangeNotifier {
  PurchaseController({
    required StoreGateway store,
    required PurchaseVerificationGateway verifier,
    required PurchaseJournal journal,
    required PurchaseCatalogue catalogue,
    required String? Function() accountId,
    EntitlementCache? cache,
    EntitlementRemoteStore? entitlementRemote,
    this.purchaseEnabled = false,
  }) : _store = store,
       _verifier = verifier,
       _journal = journal,
       _cache = cache,
       _entitlementRemote = entitlementRemote,
       catalogue = catalogue,
       _accountId = accountId;

  final StoreGateway _store;
  final PurchaseVerificationGateway _verifier;
  final PurchaseJournal _journal;
  final EntitlementCache? _cache;
  final EntitlementRemoteStore? _entitlementRemote;
  final String? Function() _accountId;
  final PurchaseCatalogue catalogue;

  /// Defaults off; release opt-in requires live store/backend acceptance.
  final bool purchaseEnabled;
  StreamSubscription<StoreTransaction>? _subscription;
  final Set<String> _processing = {};
  final Set<String> _processed = {};
  final Map<String, String> _initiatedAccount = {};
  String? _restoreBindingAccount;
  Future<void>? _restore;
  bool _initiating = false;
  bool storeAvailable = false;
  bool loading = false;
  List<StoreProduct> products = const [];
  Set<String> missingProductIds = const {};
  PurchaseFailure? failure;
  EntitlementStatus status = EntitlementStatus.unknown;
  VerifiedEntitlement? _verified;
  String? _verifiedAccount;
  DateTime? _lastForegroundRefresh;

  void resumed() {
    final now = DateTime.now();
    if (_lastForegroundRefresh != null &&
        now.difference(_lastForegroundRefresh!) < const Duration(minutes: 5))
      return;
    _lastForegroundRefresh = now;
    unawaited(refreshEntitlements());
  }

  bool get adFree =>
      _verifiedAccount == _accountId() &&
      (_verified?.permitsAdsRemoval ?? false);
  bool get busy => _initiating || _restore != null || loading;

  Future<void> start() async {
    if (_subscription != null) return;
    _subscription = _store.updates.listen(
      (event) {
        unawaited(handle(event));
      },
      onError: (Object _) {
        failure = PurchaseFailure.storeError;
        notifyListeners();
      },
    );
    unawaited(_loadAndRefreshEntitlements());
    // Startup recovery is independent of product loading and ledger bootstrap.
    try {
      final pending = await _journal.readPending();
      for (final transaction in pending.values) {
        await handle(transaction);
      }
    } on Object {
      failure = PurchaseFailure.verificationUnavailable;
      notifyListeners();
    }
  }

  void accountChanged() {
    _initiatedAccount.clear();
    _restoreBindingAccount = null;
    _verified = null;
    _verifiedAccount = null;
    status = EntitlementStatus.unknown;
    notifyListeners();
    unawaited(_loadAndRefreshEntitlements());
    unawaited(retryPending());
  }

  Future<void> _loadAndRefreshEntitlements() async {
    await _readCached();
    await refreshEntitlements();
  }

  Future<void> refreshEntitlements() async {
    final account = _accountId();
    if (account == null || _entitlementRemote == null) return;
    try {
      final verified = await _entitlementRemote.refresh(account);
      if (_accountId() != account ||
          verified == null ||
          verified.accountId != account)
        return;
      _verified = verified.permitsAdsRemoval ? verified : null;
      _verifiedAccount = _verified == null ? null : account;
      status = verified.status;
      if (_verified != null) {
        await _cache?.write(verified);
      } else {
        await _cache?.remove(account);
      }
      notifyListeners();
    } on Object {
      // Keep only the bounded previously verified cache on backend outage.
    }
  }

  Future<void> _readCached() async {
    final account = _accountId();
    if (account == null || _cache == null) return;
    try {
      final cached = await _cache.read(account);
      if (_accountId() != account || cached == null || _verified != null)
        return;
      _verified = cached;
      _verifiedAccount = account;
      status = cached.status;
      notifyListeners();
    } on Object {
      // Cache failure never blocks bookkeeping.
    }
  }

  Future<void> retryPending() async {
    try {
      for (final transaction in (await _journal.readPending()).values) {
        await handle(transaction);
      }
    } on Object {
      failure = PurchaseFailure.verificationUnavailable;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    if (loading || !catalogue.configured) {
      if (!catalogue.configured) failure = PurchaseFailure.productUnavailable;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      storeAvailable = await _store.isAvailable();
      final result = storeAvailable
          ? await _store.loadProducts(catalogue.productIds)
          : const StoreProductCatalogue(products: [], missingProductIds: {});
      products = result.products;
      missingProductIds = result.missingProductIds;
      failure = !storeAvailable
          ? PurchaseFailure.storeUnavailable
          : result.incomplete
          ? PurchaseFailure.catalogueIncomplete
          : products.isEmpty
          ? PurchaseFailure.productUnavailable
          : null;
    } on Object {
      failure = PurchaseFailure.storeUnavailable;
      products = const [];
      missingProductIds = const {};
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> buy(StoreProduct product) async {
    if (!purchaseEnabled) {
      failure = PurchaseFailure.verificationUnavailable;
      notifyListeners();
      return;
    }
    final account = _accountId();
    if (_initiating || _restore != null) return;
    if (account == null) {
      failure = PurchaseFailure.accountMismatch;
      notifyListeners();
      return;
    }
    if (!storeAvailable || !catalogue.productIds.contains(product.id)) {
      failure = PurchaseFailure.productUnavailable;
      notifyListeners();
      return;
    }
    _initiating = true;
    _initiatedAccount[product.id] = account;
    failure = null;
    notifyListeners();
    try {
      await _store.buy(product, account);
    } on Object {
      _initiatedAccount.remove(product.id);
      failure = PurchaseFailure.storeError;
    } finally {
      _initiating = false;
      notifyListeners();
    }
  }

  Future<void> restore() => _restore ??= _restoreOnce().whenComplete(() {
    _restore = null;
    notifyListeners();
  });

  Future<void> _restoreOnce() async {
    if (_accountId() == null) {
      failure = PurchaseFailure.accountMismatch;
      notifyListeners();
      return;
    }
    failure = null;
    _restoreBindingAccount = _accountId();
    notifyListeners();
    try {
      await _store.restore(_restoreBindingAccount!); // Same trusted verifier.
    } on Object {
      failure = PurchaseFailure.storeError;
      notifyListeners();
    }
  }

  Future<void> handle(StoreTransaction transaction) async {
    if (transaction.status == StoreEventStatus.pending) {
      status = EntitlementStatus.pendingVerification;
      failure = PurchaseFailure.pending;
      notifyListeners();
      return;
    }
    if (transaction.status == StoreEventStatus.cancelled ||
        transaction.status == StoreEventStatus.failed) {
      failure = transaction.status == StoreEventStatus.cancelled
          ? PurchaseFailure.cancelled
          : PurchaseFailure.storeError;
      notifyListeners();
      return;
    }
    if (transaction.id.isEmpty ||
        transaction.verificationData.isEmpty ||
        !catalogue.productIds.contains(transaction.productId)) {
      failure = PurchaseFailure.verificationRejected;
      notifyListeners();
      return;
    }
    if (_processed.contains(transaction.key) ||
        !_processing.add(transaction.key))
      return;
    try {
      final previous = (await _journal.readPending())[transaction.key];
      final binding = PurchaseAccountBinding.resolve(
        store: transaction.accountId,
        journal: previous?.accountId,
        initiated: _initiatedAccount[transaction.productId],
        restore: _restoreBindingAccount,
      );
      final originalAccount = binding.accountId;
      final account = _accountId();
      if (originalAccount == null) {
        // A redelivery after process death cannot be attributed from the
        // generic store callback. Save its proof, then require explicit
        // restore under the intended account for trusted server binding.
        await _journal.put(transaction);
        failure = PurchaseFailure.accountMismatch;
        return;
      }
      final bound = StoreTransaction(
        platform: transaction.platform,
        id: transaction.id,
        productId: transaction.productId,
        verificationData: transaction.verificationData,
        pendingCompletion: transaction.pendingCompletion,
        status: transaction.status,
        packageId: transaction.packageId,
        accountId: originalAccount,
      );
      // Preserve the strongest account evidence before returning a mismatch.
      // This prevents a restore under B from poisoning a store-bound A purchase.
      await _journal.put(bound);
      if (binding.conflict || account != originalAccount) {
        failure = PurchaseFailure.accountMismatch;
        return;
      }
      if (account == null) {
        failure = PurchaseFailure.accountMismatch;
        return;
      }
      // This write must succeed before any store completion. Persist the token
      // so an interrupted app can retry verification with the same identity.
      status = EntitlementStatus.pendingVerification;
      notifyListeners();
      VerificationResult result;
      try {
        result = await _verifier.verify(bound, account);
      } on Object {
        result = const VerificationResult(VerificationOutcome.unavailable);
      }
      if (_accountId() != account) {
        failure = PurchaseFailure.accountMismatch;
        return;
      }
      switch (result.outcome) {
        case VerificationOutcome.verified:
          final verified = result.entitlement;
          if (verified == null ||
              verified.accountId != account ||
              verified.verifiedAtUtc == null ||
              verified.expiresAtUtc == null ||
              verified.status != EntitlementStatus.active &&
                  verified.status != EntitlementStatus.gracePeriod) {
            failure = PurchaseFailure.verificationRejected;
            return;
          }
          _verified = verified;
          _verifiedAccount = account;
          status = verified.status;
          failure = null;
          if (_cache != null) {
            try {
              await _cache.write(verified);
            } on Object {
              // The trusted result remains valid in memory this session.
            }
          }
        case VerificationOutcome.inactive:
          _verified = null;
          _verifiedAccount = null;
          status = EntitlementStatus.inactive;
          failure = null;
          try {
            await _cache?.remove(account);
          } on Object {
            // Fail closed on this session; next launch must reverify.
          }
        case VerificationOutcome.pending:
          status = EntitlementStatus.pendingVerification;
          failure = PurchaseFailure.pending;
        case VerificationOutcome.rejected:
          failure = PurchaseFailure.verificationRejected;
        case VerificationOutcome.accountMismatch:
          failure = PurchaseFailure.accountMismatch;
        case VerificationOutcome.unavailable:
          status = EntitlementStatus.verificationUnavailable;
          failure = PurchaseFailure.verificationUnavailable;
      }
      // Store completion acknowledges safe durable receipt, never grants
      // Premium. Unverified transactions remain in the retry journal.
      if (bound.pendingCompletion &&
          result.outcome != VerificationOutcome.unavailable &&
          result.outcome != VerificationOutcome.pending &&
          result.outcome != VerificationOutcome.accountMismatch &&
          !(bound.platform == StoreKind.google &&
              result.acknowledgementPending)) {
        try {
          if (!await _store.complete(bound)) {
            failure = PurchaseFailure.completionFailed;
            return;
          }
        } on Object {
          failure = PurchaseFailure.completionFailed;
          return;
        }
      }
      if (!result.acknowledgementPending &&
          (result.outcome == VerificationOutcome.verified ||
              result.outcome == VerificationOutcome.inactive ||
              result.outcome == VerificationOutcome.rejected)) {
        await _journal.remove(bound.key);
        _processed.add(bound.key);
      }
    } on Object {
      failure = PurchaseFailure.verificationUnavailable;
    } finally {
      _processing.remove(transaction.key);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
