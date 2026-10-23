import 'dart:io';

Never fail(String message) => throw StateError(message);

void require(bool condition, String message) {
  if (!condition) fail(message);
}

void main() {
  final store = File(
    'lib/features/sync/data/drift_sync_state_store.dart',
  ).readAsStringSync();
  final contracts = File(
    'lib/features/sync/application/sync_contracts.dart',
  ).readAsStringSync();
  final files = File(
    'lib/features/sync/infrastructure/local_sync_receipt_pull_files.dart',
  ).readAsStringSync();
  final tests = File('test/unit/sync_runtime_test.dart').readAsStringSync();

  final committed = store.indexOf('databaseCommitted = true;');
  final cleanupBoundary = store.indexOf(
    '// The database and cursor are durable now.',
  );
  final postCommitCompensation = store.indexOf(
    'await _safeCompensate(entry.value);',
    cleanupBoundary,
  );
  require(committed >= 0, 'missing explicit database commit state');
  require(
    cleanupBoundary > committed && postCommitCompensation > cleanupBoundary,
    'post-commit cleanup must be outside the transactional rollback try/catch',
  );
  require(
    RegExp(r'if \(!databaseCommitted\)').allMatches(store).length >= 3,
    'every pre-commit exception path must guard receipt rollback',
  );
  final applyPageStart = store.indexOf(
    'Future<Result<SyncPageApplyResult>> applyPageAtomically',
  );
  final preScanStart = store.indexOf('final pending =', applyPageStart);
  final preScanEnd = store.indexOf(
    '// Conflict and own-echo decisions',
    preScanStart,
  );
  final preScan = store.substring(preScanStart, preScanEnd);
  require(
    preScan.contains('..limit(1)') && preScan.contains('.getSingleOrNull()'),
    'receipt outbox pre-scan must use LIMIT 1 for an existence check',
  );
  require(
    contracts.contains('Future<Result<void>> compensate') &&
        contracts.contains('Future<Result<void>> removeAfterCommit'),
    'cleanup contracts must surface filesystem cleanup failure safely',
  );
  require(
    files.contains('FailureCode.syncAttachmentFailure'),
    'local cleanup implementation must map filesystem exceptions',
  );
  require(
    tests.contains('post-commit tombstone cleanup failure') &&
        tests.contains('post-commit staging cleanup failure') &&
        tests.contains('multiple own-echo outbox rows') &&
        tests.contains('multiple pending rows'),
    'focused receipt atomicity regressions must remain present',
  );

  stdout.writeln('Phase 6B final receipt atomicity smoke checks passed.');
}
