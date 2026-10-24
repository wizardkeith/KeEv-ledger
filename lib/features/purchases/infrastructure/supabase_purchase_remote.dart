import 'package:supabase_flutter/supabase_flutter.dart';

import '../application/purchase_ports.dart';
import '../domain/purchase.dart';

/// User JWT is attached by the existing Supabase session. No admin key lives
/// in Flutter; the server derives ownership from its verified JWT.
final class SupabasePurchaseRemote
    implements PurchaseVerificationGateway, EntitlementRemoteStore {
  const SupabasePurchaseRemote(this.client);
  final SupabaseClient client;

  bool _signedInAs(String accountId) =>
      client.auth.currentUser?.id == accountId &&
      client.auth.currentSession?.accessToken != null;

  VerifiedEntitlement? _entitlement(
    Map<String, dynamic> body,
    String accountId,
  ) {
    if (body['accountId'] != accountId) return null;
    final value = body['entitlement'];
    if (value is! Map) return null;
    final snapshot = Map<String, dynamic>.from(value);
    final verifiedAt = DateTime.tryParse(
      snapshot['verifiedAt'] as String? ?? '',
    )?.toUtc();
    final validUntil = DateTime.tryParse(
      snapshot['validUntil'] as String? ?? '',
    )?.toUtc();
    if (verifiedAt == null) return null;
    final active =
        snapshot['active'] == true &&
        snapshot['adFree'] == true &&
        validUntil != null &&
        validUntil.isAfter(verifiedAt);
    final status = switch (snapshot['state']) {
      'gracePeriod' => EntitlementStatus.gracePeriod,
      'billingRetry' || 'onHold' => EntitlementStatus.billingRetry,
      'expired' => EntitlementStatus.expired,
      'revoked' => EntitlementStatus.revoked,
      'pending' => EntitlementStatus.pendingVerification,
      _ => active ? EntitlementStatus.active : EntitlementStatus.inactive,
    };
    return VerifiedEntitlement(
      accountId: accountId,
      status: status,
      adFree: active,
      verifiedAtUtc: verifiedAt,
      expiresAtUtc: validUntil,
    );
  }

  @override
  Future<VerificationResult> verify(
    StoreTransaction transaction,
    String accountId,
  ) async {
    if (!_signedInAs(accountId) || transaction.accountId != accountId) {
      return const VerificationResult(VerificationOutcome.accountMismatch);
    }
    try {
      final response = await client.functions.invoke(
        'verify-purchase',
        body: {
          'platform': transaction.platform.name,
          'transactionId': transaction.id,
          'productId': transaction.productId,
          'proof': transaction.verificationData,
          'accountId': accountId,
          'packageId': transaction.packageId,
        },
      );
      if (!_signedInAs(accountId) || response.data is! Map) {
        return const VerificationResult(VerificationOutcome.unavailable);
      }
      final body = Map<String, dynamic>.from(response.data as Map);
      if (body['accountId'] != accountId) {
        return const VerificationResult(VerificationOutcome.accountMismatch);
      }
      final outcome = switch (body['outcome']) {
        'VERIFIED_ACTIVE' => VerificationOutcome.verified,
        'VERIFIED_INACTIVE' => VerificationOutcome.inactive,
        'PENDING' => VerificationOutcome.pending,
        'REJECTED' => VerificationOutcome.rejected,
        'ACCOUNT_MISMATCH' => VerificationOutcome.accountMismatch,
        _ => VerificationOutcome.unavailable,
      };
      if (outcome == VerificationOutcome.verified &&
          _entitlement(body, accountId)?.permitsAdsRemoval != true) {
        return const VerificationResult(VerificationOutcome.unavailable);
      }
      return VerificationResult(
        outcome,
        entitlement: _entitlement(body, accountId),
        acknowledgementPending: body['acknowledgementPending'] == true,
      );
    } on Object {
      return const VerificationResult(VerificationOutcome.unavailable);
    }
  }

  @override
  Future<VerifiedEntitlement?> refresh(String accountId) async {
    if (!_signedInAs(accountId)) return null;
    final response = await client.functions.invoke(
      'refresh-entitlements',
      body: {},
    );
    if (!_signedInAs(accountId) || response.data is! Map) return null;
    final body = Map<String, dynamic>.from(response.data as Map);
    if (body['outcome'] != 'OK') return null;
    return _entitlement(body, accountId);
  }
}
