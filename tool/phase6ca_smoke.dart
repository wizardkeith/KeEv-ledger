import 'dart:convert';
import 'dart:io';

import 'package:ledger/features/sync/domain/sync_protocol.dart';

Never _fail(String message) => throw StateError(message);

void main() {
  const empty = SyncLedgerSummary(
    accounts: 0,
    transactions: 0,
    receipts: 0,
    baseCurrencyCode: null,
  );
  const populated = SyncLedgerSummary(
    accounts: 1,
    transactions: 0,
    receipts: 0,
    baseCurrencyCode: 'HKD',
  );
  const cloudEmpty = SyncCloudDiscovery(
    summary: empty,
    generation: null,
    maximumRevision: 0,
    initializationInProgress: false,
  );
  const cloudData = SyncCloudDiscovery(
    summary: populated,
    generation: '30000000-0000-4000-8000-000000000001',
    maximumRevision: 4,
    initializationInProgress: false,
  );
  final cases = [
    const SyncDiscovery(local: empty, cloud: cloudEmpty).classification,
    const SyncDiscovery(local: populated, cloud: cloudEmpty).classification,
    const SyncDiscovery(local: empty, cloud: cloudData).classification,
    const SyncDiscovery(local: populated, cloud: cloudData).classification,
  ];
  if (cases.join(',') != SyncDiscoveryCase.values.join(',')) {
    _fail('Four-case discovery mismatch');
  }

  final sql = File(
    'supabase/migrations/202609230003_sync_onboarding_v1.sql',
  ).readAsStringSync().toLowerCase();
  for (final required in [
    'create table public.sync_datasets',
    "set search_path = ''",
    'auth.uid()',
    'pg_advisory_xact_lock',
    'reconciliation_required',
    'revoke all on function public.sync_begin_initialization_v1',
    'revoke insert,update,delete on public.sync_datasets',
  ]) {
    if (!sql.contains(required)) _fail('Missing SQL control: $required');
  }
  if (sql.contains('service_role')) _fail('Privileged client credential found');

  final fixSql = File(
    'supabase/migrations/202609230004_sync_onboarding_v1_fix_gate.sql',
  ).readAsStringSync().toLowerCase();
  for (final required in [
    "interval '30 minutes'",
    'initialization_lease_expires_at',
    "'status','resumed'",
    "'status','initialization_in_progress'",
    "'status','recovered'",
    'sync_abort_initialization_v1',
    "set search_path = ''",
    'auth.uid()',
  ]) {
    if (!fixSql.contains(required)) {
      _fail('Missing initialization recovery control: $required');
    }
  }
  if (fixSql.contains('service_role')) {
    _fail('Privileged recovery credential found');
  }

  final onboardingStore = File(
    'lib/features/sync/data/drift_sync_onboarding_store.dart',
  ).readAsStringSync();
  if (!onboardingStore.contains('last_successful_sync_at_utc=NULL')) {
    _fail('Onboarding still claims a successful caught-up sync');
  }

  final arbFiles = [
    'app_en.arb',
    'app_zh.arb',
    'app_zh_HK.arb',
    'app_zh_CN.arb',
    'app_ja.arb',
    'app_th.arb',
  ];
  Set<String>? baseline;
  for (final name in arbFiles) {
    final values =
        jsonDecode(File('lib/localization/arb/$name').readAsStringSync())
            as Map<String, dynamic>;
    final keys = values.keys.where((key) => !key.startsWith('@')).toSet();
    baseline ??= keys;
    if (keys.length != baseline.length || !keys.containsAll(baseline)) {
      _fail('Localization key mismatch: $name');
    }
  }

  final dart = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');
  for (final forbidden in [
    'RealtimeChannel(',
    'Workmanager(',
    'BackgroundFetch(',
  ]) {
    if (dart.contains(forbidden)) _fail('Phase 6C-B scope found: $forbidden');
  }

  stdout.writeln('Phase 6C-A pure-Dart/static smoke checks passed.');
}
