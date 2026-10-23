import 'package:flutter/foundation.dart';

import '../../ads/application/ads_contracts.dart';
import 'purchase_controller.dart';

final class PurchaseAdsEntitlement implements AdsEntitlement, Listenable {
  const PurchaseAdsEntitlement(this.purchases);
  final PurchaseController purchases;
  @override
  bool get adsAllowed => !purchases.adFree;
  @override
  void addListener(VoidCallback listener) => purchases.addListener(listener);
  @override
  void removeListener(VoidCallback listener) =>
      purchases.removeListener(listener);
}
