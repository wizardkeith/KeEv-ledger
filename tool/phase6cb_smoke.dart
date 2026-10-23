import 'dart:io';

Future<void> main() async {
  final migration = await File(
    'supabase/migrations/202609230005_sync_realtime_and_retention_v1.sql',
  ).readAsString();
  final coordinator = await File(
    'lib/features/sync/application/sync_trigger_coordinator.dart',
  ).readAsString();
  final checks = <bool>[
    migration.contains('sync_ack_device_v1'),
    migration.contains('pg_catalog.greatest'),
    migration.contains("interval '180 days'"),
    migration.contains("interval '365 days'"),
    migration.contains('sync_prune_safe_history_v1'),
    migration.contains('from public,anon,authenticated'),
    migration.contains("'sync_invalidated'"),
    !migration.contains("'amount',new"),
    !migration.contains("'note',new"),
    coordinator.contains('minimumAutomaticInterval'),
    coordinator.contains('connectivityDebounce'),
    coordinator.contains('SyncBackgroundWorker'),
  ];
  if (checks.any((value) => !value)) {
    stderr.writeln('Phase 6C-B smoke verification failed.');
    exitCode = 1;
    return;
  }
  stdout.writeln('Phase 6C-B pure-Dart/static smoke checks passed.');
}
