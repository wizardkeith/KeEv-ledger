import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import '../application/purchase_ports.dart';
import '../domain/purchase.dart';

/// Only this adapter knows Flutter StoreKit / Billing types.
final class FlutterStoreGateway implements StoreGateway {
  FlutterStoreGateway({InAppPurchase? plugin})
    : _plugin = plugin ?? InAppPurchase.instance;
  final InAppPurchase _plugin;
  final Map<String, ProductDetails> _products = {};
  String _productKey(String id, String? offer) => '$id:${offer ?? ''}';
  final Map<String, PurchaseDetails> _transactions = {};

  @override
  Stream<StoreTransaction> get updates =>
      _plugin.purchaseStream.expand((batch) => batch.map(_mapPurchase));

  StoreTransaction _mapPurchase(PurchaseDetails purchase) {
    final proof = purchase.verificationData.serverVerificationData;
    // Play may omit an order ID for some subscription updates; the opaque
    // token digest is stable for journal deduplication without exposing it.
    final id =
        purchase.purchaseID ??
        (Platform.isAndroid && proof.isNotEmpty
            ? sha256
                  .convert(utf8.encode('${purchase.productID}:$proof'))
                  .toString()
            : '');
    final transaction = StoreTransaction(
      platform: Platform.isIOS ? StoreKind.apple : StoreKind.google,
      id: id,
      productId: purchase.productID,
      status: switch (purchase.status) {
        PurchaseStatus.pending => StoreEventStatus.pending,
        PurchaseStatus.purchased => StoreEventStatus.purchased,
        PurchaseStatus.restored => StoreEventStatus.restored,
        PurchaseStatus.error => StoreEventStatus.failed,
        PurchaseStatus.canceled => StoreEventStatus.cancelled,
      },
      verificationData: proof,
      pendingCompletion: purchase.pendingCompletePurchase,
      accountId: switch (purchase) {
        SK2PurchaseDetails(:final appAccountToken) => appAccountToken,
        GooglePlayPurchaseDetails(:final billingClientPurchase) =>
          billingClientPurchase.obfuscatedAccountId,
        _ => null,
      },
      packageId: purchase is GooglePlayPurchaseDetails
          ? purchase.billingClientPurchase.packageName
          : null,
    );
    if (id.isNotEmpty) _transactions[transaction.key] = purchase;
    return transaction;
  }

  @override
  Future<bool> isAvailable() => _plugin.isAvailable();

  @override
  Future<StoreProductCatalogue> loadProducts(Set<String> ids) async {
    final response = await _plugin.queryProductDetails(ids);
    if (response.error != null) throw StateError('Store product query failed');
    _products.clear();
    final products = <StoreProduct>[];
    for (final product in response.productDetails) {
      SubscriptionPeriod? period;
      String? offerToken;
      String price = product.price;
      if (product is AppStoreProduct2Details) {
        final subscription =
            product.sk2Product.subscription?.subscriptionPeriod;
        if (subscription != null) {
          period = SubscriptionPeriod.fromAppleUnitName(
            subscription.value,
            subscription.unit.name,
          );
        }
      } else if (product is GooglePlayProductDetails) {
        final offers = product.productDetails.subscriptionOfferDetails;
        final index = product.subscriptionIndex;
        if (offers != null &&
            index != null &&
            index >= 0 &&
            index < offers.length) {
          final offer = offers[index];
          offerToken = offer.offerIdToken;
          // The recurring phase, rather than a free trial, defines the
          // subscription's displayed renewal price and billing period.
          for (final phase in offer.pricingPhases.reversed) {
            if (phase.recurrenceMode.name == 'infiniteRecurring') {
              period = SubscriptionPeriod.fromPlayIso8601(phase.billingPeriod);
              price = phase.formattedPrice;
              break;
            }
          }
        }
      }
      _products[_productKey(product.id, offerToken)] = product;
      products.add(
        StoreProduct(
          id: product.id,
          title: product.title,
          description: product.description,
          localizedPrice: price,
          currencyCode: product.currencyCode,
          period: period,
          offerId: offerToken,
        ),
      );
    }
    return StoreProductCatalogue(
      products: products,
      missingProductIds: {
        ...response.notFoundIDs,
        ...ids.difference(products.map((p) => p.id).toSet()),
      },
    );
  }

  @override
  Future<void> buy(StoreProduct product, String opaqueAccountId) async {
    final details = _products[_productKey(product.id, product.offerId)];
    if (details == null) throw StateError('Product not returned by store');
    await _plugin.buyNonConsumable(
      purchaseParam: details is GooglePlayProductDetails
          ? GooglePlayPurchaseParam(
              productDetails: details,
              applicationUserName: opaqueAccountId,
              offerToken: product.offerId,
            )
          : PurchaseParam(
              productDetails: details,
              applicationUserName: opaqueAccountId,
            ),
    );
  }

  @override
  Future<void> restore(String opaqueAccountId) =>
      _plugin.restorePurchases(applicationUserName: opaqueAccountId);

  @override
  Future<bool> complete(StoreTransaction transaction) async {
    final details = _transactions[transaction.key];
    // After process death the store redelivers unfinished purchases; the
    // journal retries verification independently while awaiting redelivery.
    if (details == null) return false;
    if (transaction.platform == StoreKind.google) {
      // The trusted backend has already acknowledged Play before the
      // controller reaches this point. Calling completePurchase with a stale
      // client wrapper would send a second acknowledgement.
      _transactions.remove(transaction.key);
      return true;
    }
    if (details.pendingCompletePurchase)
      await _plugin.completePurchase(details);
    _transactions.remove(transaction.key);
    return true;
  }
}
