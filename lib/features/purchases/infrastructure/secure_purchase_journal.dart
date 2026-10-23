import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../application/purchase_ports.dart';
import '../domain/purchase.dart';

/// Device-local encrypted journal. Excluded from ledger backup and live sync.
/// Writes are serialized so overlapping store callbacks cannot drop entries.
final class SecurePurchaseJournal implements PurchaseJournal {
  SecurePurchaseJournal({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  static const _key = 'keev_purchase_verification_pending_v1';
  Future<void> _tail = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Future<Map<String, StoreTransaction>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return {};
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    return parsed.map(
      (key, value) => MapEntry(
        key,
        StoreTransaction.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Future<Map<String, StoreTransaction>> readPending() => _serial(_read);

  @override
  Future<void> put(StoreTransaction transaction) => _serial(() async {
    final entries = await _read();
    entries[transaction.key] = transaction;
    await _storage.write(
      key: _key,
      value: jsonEncode(
        entries.map((key, value) => MapEntry(key, value.toJson())),
      ),
    );
  });

  @override
  Future<void> remove(String key) => _serial(() async {
    final entries = await _read();
    entries.remove(key);
    await _storage.write(
      key: _key,
      value: jsonEncode(
        entries.map((key, value) => MapEntry(key, value.toJson())),
      ),
    );
  });
}

/// Cache only; a bounded, recently server-verified view while temporarily
/// offline. The authoritative entitlement lives with the Phase 8B verifier.
final class SecureEntitlementCache implements EntitlementCache {
  SecureEntitlementCache({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  String _key(String account) =>
      'keev_verified_entitlement_v1_${sha256.convert(utf8.encode(account))}';

  @override
  Future<void> remove(String accountId) =>
      _storage.delete(key: _key(accountId));

  @override
  Future<VerifiedEntitlement?> read(String accountId) async {
    final raw = await _storage.read(key: _key(accountId));
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final verifiedAt = DateTime.tryParse(
      json['verifiedAt'] as String? ?? '',
    )?.toUtc();
    final expiresAt = DateTime.tryParse(
      json['expiresAt'] as String? ?? '',
    )?.toUtc();
    final now = DateTime.now().toUtc();
    // Never resurrect a cache with no server timestamp or expiry. 48h is a
    // temporary UI allowance, not a store or server subscription ruling.
    if (json['accountId'] != accountId ||
        verifiedAt == null ||
        expiresAt == null ||
        verifiedAt.isAfter(now) ||
        now.difference(verifiedAt) > const Duration(hours: 48) ||
        !now.isBefore(expiresAt))
      return null;
    return VerifiedEntitlement(
      accountId: accountId,
      status: EntitlementStatus.values.byName(json['status'] as String),
      adFree: json['adFree'] as bool,
      verifiedAtUtc: verifiedAt,
      expiresAtUtc: expiresAt,
    );
  }

  @override
  Future<void> write(VerifiedEntitlement value) => _storage.write(
    key: _key(value.accountId),
    value: jsonEncode({
      'accountId': value.accountId,
      'status': value.status.name,
      'adFree': value.adFree,
      'verifiedAt': value.verifiedAtUtc?.toIso8601String(),
      'expiresAt': value.expiresAtUtc?.toIso8601String(),
    }),
  );
}
