import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result.dart';
import '../application/sync_contracts.dart';
import '../domain/sync_protocol.dart';
import 'supabase_sync_remote_store.dart';

final class SupabaseSyncOnboardingStore
    implements SyncOnboardingRemoteStore, SyncConflictRemoteStore {
  const SupabaseSyncOnboardingStore(this.client);
  final SupabaseClient client;

  @override
  Future<Result<SyncCloudDiscovery>> discover() async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_discover_dataset_v1',
      );
      return Success(
        SyncCloudDiscovery(
          summary: SyncLedgerSummary(
            accounts: _integer(row['accounts']),
            transactions: _integer(row['transactions']),
            receipts: _integer(row['receipts']),
            otherRecords: _integer(row['other_records']),
            baseCurrencyCode: row['base_currency_code'] as String?,
            latestActivityDate: row['latest_activity_date'] as String?,
          ),
          generation: row['generation'] as String?,
          maximumRevision: _integer(row['maximum_revision']),
          initializationInProgress: row['initialization_in_progress'] == true,
        ),
      );
    } on FormatException {
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<void>> abortInitialization(
    SyncInitializationLease lease,
  ) async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_abort_initialization_v1',
        params: {
          'p_operation_id': lease.operationId,
          'p_generation': lease.generation,
        },
      );
      final status = row['status'] as String?;
      return switch (status) {
        'ABORTED' || 'ALREADY_ABORTED' => const Success(null),
        'NOT_OWNER' => const Failure(FailureCode.syncInitializationInProgress),
        _ => const Failure(FailureCode.syncProtocolMismatch),
      };
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<SyncInitializationLease>> beginInitialization({
    required String operationId,
    required SyncOnboardingChoice choice,
  }) async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_begin_initialization_v1',
        params: {'p_operation_id': operationId, 'p_choice': choice.name},
      );
      final status = row['status'] as String?;
      if (status == 'INITIALIZATION_IN_PROGRESS') {
        return const Failure(FailureCode.syncInitializationInProgress);
      }
      if (status == 'RECONCILIATION_REQUIRED') {
        return const Failure(FailureCode.syncNeedsReconciliation);
      }
      return Success(
        SyncInitializationLease(
          operationId: row['operation_id'] as String,
          generation: row['generation'] as String,
          snapshotRevision: _integer(row['snapshot_revision']),
        ),
      );
    } on FormatException {
      return const Failure(FailureCode.syncProtocolMismatch);
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<SyncInitialEntityResult>> uploadInitialEntity({
    required SyncInitializationLease lease,
    required String deviceId,
    required SyncInitialEntity entity,
  }) async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_initialize_entity_v1',
        params: {
          'p_operation_id': lease.operationId,
          'p_generation': lease.generation,
          'p_device_id': deviceId,
          'p_entity_type': _entity(entity.entityType),
          'p_entity_id': entity.entityId,
          'p_payload': entity.payload,
        },
      );
      return Success(
        SyncInitialEntityResult(
          entityType: entity.entityType,
          entityId: entity.entityId,
          serverVersion: _positive(row['server_version']),
          serverRevision: _positive(row['server_revision']),
        ),
      );
    } on FormatException {
      return const Failure(FailureCode.syncProtocolMismatch);
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<int>> finalizeInitialization(
    SyncInitializationLease lease,
  ) async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_finalize_initialization_v1',
        params: {
          'p_operation_id': lease.operationId,
          'p_generation': lease.generation,
        },
      );
      return Success(_integer(row['maximum_revision']));
    } on FormatException {
      return const Failure(FailureCode.syncProtocolMismatch);
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<SyncSnapshotPage>> fetchSnapshotPage({
    required String generation,
    required int highWaterRevision,
    required int offset,
    int limit = maximumSyncPageSize,
  }) async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_fetch_snapshot_v1',
        params: {
          'p_generation': generation,
          'p_high_water_revision': highWaterRevision,
          'p_offset': offset,
          'p_limit': limit,
        },
      );
      final rawEntities = row['entities'];
      if (rawEntities is! List) throw const FormatException();
      final entities = rawEntities
          .map((raw) {
            final map = Map<String, dynamic>.from(raw as Map);
            return SyncInitialEntity(
              entityType: _parseEntity(map['entity_type'] as String),
              entityId: map['entity_id'] as String,
              payload: Map<String, Object?>.unmodifiable(
                Map<String, Object?>.from(map['payload'] as Map),
              ),
            );
          })
          .toList(growable: false);
      return Success(
        SyncSnapshotPage(
          generation: row['generation'] as String,
          highWaterRevision: _integer(row['high_water_revision']),
          entities: entities,
          nextOffset: row['next_offset'] == null
              ? null
              : _integer(row['next_offset']),
        ),
      );
    } on FormatException {
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<SyncCanonicalEntity>> fetchCurrentEntity({
    required String generation,
    required SyncEntityType entityType,
    required String entityId,
  }) async {
    try {
      final row = await client.rpc<Map<String, dynamic>>(
        'sync_fetch_current_entity_v1',
        params: {
          'p_generation': generation,
          'p_entity_type': _entity(entityType),
          'p_entity_id': entityId,
        },
      );
      return Success(
        SupabaseSyncRemoteStore.parseCanonicalEntity(
          Map<String, dynamic>.from(row['payload'] as Map),
          expectedType: entityType,
          throughSequence: _positive(row['server_revision']),
        ),
      );
    } on FormatException {
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on PostgrestException catch (error) {
      return Failure(_failure(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  static int _integer(Object? value) {
    if (value is int && value >= 0) return value;
    throw const FormatException();
  }

  static int _positive(Object? value) {
    final parsed = _integer(value);
    if (parsed < 1) throw const FormatException();
    return parsed;
  }

  static String _entity(SyncEntityType value) => switch (value) {
    SyncEntityType.receiptAttachment => 'receipt_attachment',
    _ => value.name,
  };

  static SyncEntityType _parseEntity(String value) => switch (value) {
    'profile' => SyncEntityType.profile,
    'account' => SyncEntityType.account,
    'category' => SyncEntityType.category,
    'transaction' => SyncEntityType.transaction,
    'transfer' => SyncEntityType.transfer,
    'project' => SyncEntityType.project,
    'budget' => SyncEntityType.budget,
    'receipt_attachment' => SyncEntityType.receiptAttachment,
    _ => throw const FormatException(),
  };

  static FailureCode _failure(PostgrestException error) => switch (error.code) {
    '42501' => FailureCode.syncUnauthorized,
    'PGRST301' => FailureCode.syncAuthenticationRequired,
    '409' => FailureCode.syncNeedsReconciliation,
    '429' => FailureCode.syncRateLimited,
    _ => FailureCode.syncBackendUnavailable,
  };
}
