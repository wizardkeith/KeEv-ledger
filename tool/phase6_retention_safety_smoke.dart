import 'dart:convert';
import 'dart:io';

Never _fail(String message) => throw StateError(message);

void _contains(String source, String value, String label) {
  if (!source.contains(value)) _fail('$label is missing');
}

void main() {
  final migration = File(
    'supabase/migrations/202609230006_sync_retention_safety_v1.sql',
  );
  if (!migration.existsSync()) _fail('retention migration is missing');
  final sql = migration.readAsStringSync();
  _contains(
    sql,
    'history_floor_revision bigint not null default 0',
    'history floor',
  );
  _contains(
    sql,
    'when public.sync_device_registrations.generation=excluded.generation',
    'generation-scoped acknowledgement',
  );
  _contains(
    sql,
    'else excluded.acknowledged_revision',
    'generation acknowledgement reset',
  );
  _contains(sql, 'if p_after_sequence<v_floor then', 'history gap gate');
  _contains(sql, "'reason','HISTORY_UNAVAILABLE'", 'structured history gap');
  _contains(
    sql,
    'pg_catalog.greatest(history_floor_revision,v_safe)',
    'monotonic floor update',
  );

  final lifecycle = File(
    'supabase/migrations/202609230007_sync_device_lifecycle_safety_v1.sql',
  ).readAsStringSync();
  _contains(lifecycle, 'if p_revision<v_floor then', 'ack history floor');
  _contains(lifecycle, 'if p_revision>v_head then', 'ack upper bound');
  _contains(lifecycle, "'reason','INVALID_ACK_REVISION'", 'invalid ack result');
  _contains(
    lifecycle,
    'and generation=p_generation and linked=true',
    'generation-scoped unlink',
  );
  _contains(lifecycle, 'last_seen_at=pg_catalog.now()', 'server heartbeat');

  final engine = File(
    'lib/features/sync/application/sync_engine.dart',
  ).readAsStringSync();
  _contains(
    engine,
    'lastAcknowledgedRevision != revision',
    'caught-up cursor heartbeat',
  );
  final controller = File(
    'lib/features/sync/application/sync_controller.dart',
  ).readAsStringSync();
  _contains(controller, 'await onboarding.unlinkDevice', 'production unlink');
  _contains(
    controller,
    'final result = await local.unlink()',
    'offline-safe local unlink',
  );

  final schemaFile = File('drift_schemas/ledger_database/drift_schema_v8.json');
  if (!schemaFile.existsSync()) _fail('Drift v8 schema is missing');
  final schema =
      jsonDecode(schemaFile.readAsStringSync()) as Map<String, Object?>;
  final entities = schema['entities'] as List<Object?>;
  final names = entities
      .whereType<Map<String, Object?>>()
      .map((entity) => entity['data'])
      .whereType<Map<String, Object?>>()
      .map((data) => data['name'])
      .whereType<String>()
      .toSet();
  if (!names.contains('sync_onboarding_state') ||
      !names.contains('sync_initialization_entities')) {
    _fail('Drift v8 onboarding tables are missing');
  }

  final runtime = File('lib/app/bookkeeping_runtime.dart').readAsStringSync();
  _contains(
    runtime,
    'PlatformSyncConnectivityObserver()',
    'production connectivity observer',
  );
  _contains(runtime, 'syncConnectivity.start()', 'observer startup');
  _contains(runtime, 'syncConnectivity?.dispose()', 'observer disposal');

  final android = File(
    'android/app/src/main/kotlin/com/keev/ledger/MainActivity.kt',
  ).readAsStringSync();
  _contains(android, 'Handler(Looper.getMainLooper())', 'Android main handler');
  _contains(
    android,
    'if (connectivitySink === events) events.success(potentiallyOnline)',
    'main-thread EventSink emission',
  );

  stdout.writeln('Phase 6 retention safety smoke: PASS');
}
