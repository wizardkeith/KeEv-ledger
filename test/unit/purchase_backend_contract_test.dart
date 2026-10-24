import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final remote = File(
    'lib/features/purchases/infrastructure/supabase_purchase_remote.dart',
  ).readAsStringSync();
  final store = File(
    'lib/features/purchases/infrastructure/flutter_store_gateway.dart',
  ).readAsStringSync();
  final bootstrap = File('lib/app/bootstrap.dart').readAsStringSync();
  test('authenticated Supabase adapter invokes narrow functions', () {
    // The formatter may put the first argument on a separate line.
    expect(
      remote,
      matches(RegExp(r"client\.functions\.invoke\(\s*'verify-purchase'")),
    );
    expect(
      remote,
      matches(RegExp(r"client\.functions\.invoke\(\s*'refresh-entitlements'")),
    );
    expect(remote, contains('client.auth.currentUser?.id == accountId'));
    expect(remote, isNot(contains('SERVICE_ROLE_KEY')));
  });
  test('backend acknowledges Play; client finishes Apple after verification', () {
    expect(store, contains('transaction.platform == StoreKind.google'));
    expect(store, contains('await _plugin.completePurchase(details)'));
    expect(
      bootstrap,
      contains(
        "const bool.fromEnvironment('PURCHASES_ENABLED', defaultValue: false)",
      ),
    );
  });
}
