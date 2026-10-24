enum StoreKind { apple, google }

enum StoreEventStatus { pending, purchased, restored, cancelled, failed }

enum EntitlementStatus {
  unknown,
  inactive,
  pendingVerification,
  active,
  gracePeriod,
  billingRetry,
  expired,
  revoked,
  verificationUnavailable,
}

enum PurchaseFailure {
  storeUnavailable,
  productUnavailable,
  catalogueIncomplete,
  cancelled,
  pending,
  storeError,
  verificationUnavailable,
  verificationRejected,
  accountMismatch,
  completionFailed,
}

enum SubscriptionPeriodUnit { day, week, month, year }

final class SubscriptionPeriod {
  const SubscriptionPeriod(this.value, this.unit) : assert(value > 0);
  final int value;
  final SubscriptionPeriodUnit unit;

  static SubscriptionPeriod? fromAppleUnitName(int value, String unitName) {
    if (value <= 0) return null;
    final unit = switch (unitName) {
      'day' => SubscriptionPeriodUnit.day,
      'week' => SubscriptionPeriodUnit.week,
      'month' => SubscriptionPeriodUnit.month,
      'year' => SubscriptionPeriodUnit.year,
      _ => null,
    };
    return unit == null ? null : SubscriptionPeriod(value, unit);
  }

  /// Google's Play Billing period, for example P1M or P3M. Other ISO
  /// durations are left unknown instead of guessing a billing interval.
  static SubscriptionPeriod? fromPlayIso8601(String raw) {
    final match = RegExp(r'^P([1-9][0-9]*)([DWMY])$').firstMatch(raw);
    if (match == null) return null;
    final value = int.tryParse(match.group(1)!);
    if (value == null) return null;
    final unit = switch (match.group(2)!) {
      'D' => SubscriptionPeriodUnit.day,
      'W' => SubscriptionPeriodUnit.week,
      'M' => SubscriptionPeriodUnit.month,
      'Y' => SubscriptionPeriodUnit.year,
      _ => null,
    };
    return unit == null ? null : SubscriptionPeriod(value, unit);
  }
}

final class StoreProductCatalogue {
  const StoreProductCatalogue({
    required this.products,
    required this.missingProductIds,
  });
  final List<StoreProduct> products;
  final Set<String> missingProductIds;
  bool get incomplete => missingProductIds.isNotEmpty;
}

final class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.localizedPrice,
    required this.currencyCode,
    this.period,
    this.offerId,
  });
  final String id, title, description, localizedPrice, currencyCode;
  final SubscriptionPeriod? period;

  /// The selected Play offer token, not a guessed subscription SKU suffix.
  final String? offerId;
}

/// The store token/JWS is an opaque input for a trusted verifier, never proof
/// of Premium on its own. A transaction ID is mandatory for deduplication.
final class StoreTransaction {
  const StoreTransaction({
    required this.platform,
    required this.id,
    required this.productId,
    required this.status,
    required this.verificationData,
    required this.pendingCompletion,
    this.accountId,
    this.packageId,
  });
  final StoreKind platform;
  final String id, productId, verificationData;
  final StoreEventStatus status;
  final bool pendingCompletion;
  final String? accountId, packageId;

  String get key => '${platform.name}:$id';
  Map<String, Object?> toJson() => {
    'platform': platform.name,
    'id': id,
    'productId': productId,
    'verificationData': verificationData,
    'accountId': accountId,
    'packageId': packageId,
    'pendingCompletion': pendingCompletion,
  };
  static StoreTransaction fromJson(Map<String, dynamic> json) =>
      StoreTransaction(
        platform: StoreKind.values.byName(json['platform'] as String),
        id: json['id'] as String,
        productId: json['productId'] as String,
        verificationData: json['verificationData'] as String,
        pendingCompletion: json['pendingCompletion'] as bool? ?? false,
        accountId: json['accountId'] as String?,
        packageId: json['packageId'] as String?,
        status: StoreEventStatus.purchased,
      );
}

final class VerifiedEntitlement {
  const VerifiedEntitlement({
    required this.accountId,
    required this.status,
    required this.adFree,
    this.verifiedAtUtc,
    this.expiresAtUtc,
  });
  final String accountId;
  final EntitlementStatus status;
  final bool adFree;
  final DateTime? verifiedAtUtc, expiresAtUtc;
  bool get permitsAdsRemoval =>
      adFree &&
      (status == EntitlementStatus.active ||
          status == EntitlementStatus.gracePeriod) &&
      (expiresAtUtc == null || DateTime.now().toUtc().isBefore(expiresAtUtc!));
}

enum VerificationOutcome {
  verified,
  inactive,
  pending,
  rejected,
  unavailable,
  accountMismatch,
}

final class VerificationResult {
  const VerificationResult(
    this.outcome, {
    this.entitlement,
    this.acknowledgementPending = false,
  });
  final VerificationOutcome outcome;
  final VerifiedEntitlement? entitlement;
  final bool acknowledgementPending;
}
