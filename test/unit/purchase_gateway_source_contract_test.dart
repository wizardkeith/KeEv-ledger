import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source guard for native adapter paths. Runtime integration still requires
/// resolved official packages and sandbox store callbacks.
void main() {
  final source = File(
    'lib/features/purchases/infrastructure/flutter_store_gateway.dart',
  ).readAsStringSync();
  test('StoreKit 2 and Play callbacks extract opaque account bindings', () {
    expect(source, contains('SK2PurchaseDetails(:final appAccountToken)'));
    expect(source, contains('billingClientPurchase.obfuscatedAccountId'));
    expect(
      source,
      contains('restorePurchases(applicationUserName: opaqueAccountId)'),
    );
  });
  test('store period and selected Play offer come from native metadata', () {
    expect(
      source,
      matches(RegExp(r'sk2Product\.subscription\?\.subscriptionPeriod')),
    );
    expect(source, contains('offer.pricingPhases.reversed'));
    expect(source, contains('phase.billingPeriod'));
    expect(source, contains('offerToken: product.offerId'));
    expect(source, isNot(contains('billingDescription: product.description')));
  });
  test('missing configured product identifiers survive the adapter', () {
    expect(source, contains('response.notFoundIDs'));
    expect(source, contains('missingProductIds:'));
  });
}
