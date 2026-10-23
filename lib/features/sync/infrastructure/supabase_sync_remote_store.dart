import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result.dart';
import '../application/sync_contracts.dart';
import '../domain/sync_protocol.dart';

final class SupabaseSyncRemoteStore
    implements SyncRemoteStore, SyncDeviceRegistrationRemote {
  const SupabaseSyncRemoteStore(this.client);
  final SupabaseClient client;

  @override
  Future<Result<void>> acknowledgeDevice({
    required String deviceId,
    required String generation,
    required int revision,
  }) async {
    try {
      final response = await client.rpc<Map<String, dynamic>>(
        'sync_ack_device_v1',
        params: {
          'p_device_id': deviceId,
          'p_generation': generation,
          'p_revision': revision,
        },
      );
      if (response['status'] == 'RECONCILIATION_REQUIRED') {
        return const Failure(FailureCode.syncNeedsReconciliation);
      }
      if (response['status'] != 'ACKNOWLEDGED') {
        return const Failure(FailureCode.syncProtocolMismatch);
      }
      return const Success(null);
    } on AuthException {
      return const Failure(FailureCode.syncAuthenticationRequired);
    } on PostgrestException catch (error) {
      return Failure(_postgrest(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<void>> unlinkDevice({
    required String deviceId,
    required String generation,
  }) async {
    try {
      final response = await client.rpc<Map<String, dynamic>>(
        'sync_unlink_device_v1',
        params: {'p_device_id': deviceId, 'p_generation': generation},
      );
      return switch (response['status']) {
        'UNLINKED' || 'ALREADY_UNLINKED' => const Success(null),
        'RECONCILIATION_REQUIRED' => const Failure(
          FailureCode.syncNeedsReconciliation,
        ),
        _ => const Failure(FailureCode.syncProtocolMismatch),
      };
    } on AuthException {
      return const Failure(FailureCode.syncAuthenticationRequired);
    } on PostgrestException catch (error) {
      return Failure(_postgrest(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<SyncMutationResult>> applyMutation(
    SyncMutation mutation,
  ) async {
    try {
      final value = await client.rpc<Map<String, dynamic>>(
        'sync_apply_mutation_v1',
        params: {
          'p_mutation_id': mutation.mutationId,
          'p_device_id': mutation.deviceId,
          'p_entity_type': _entity(mutation.entityType),
          'p_entity_id': mutation.entityId,
          'p_operation': mutation.operation.name,
          'p_base_server_version': mutation.baseServerVersion,
          'p_payload': mutation.payload,
          'p_generation': mutation.datasetGeneration,
        },
      );
      return Success(parseMutationResult(value));
    } on FormatException {
      return const Failure(FailureCode.syncProtocolMismatch);
    } on PostgrestException catch (error) {
      return Failure(_postgrest(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  @override
  Future<Result<SyncChangePage>> fetchChanges({
    required int afterSequence,
    int limit = maximumSyncPageSize,
  }) async {
    if (afterSequence < 0 || limit < 1 || limit > maximumSyncPageSize) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    try {
      final generation = await client.rpc<Map<String, dynamic>>(
        'sync_current_generation_v1',
      );
      final generationId = generation['generation'];
      if (generationId is! String) {
        return const Failure(FailureCode.syncNeedsReconciliation);
      }
      final response = await client.rpc<Map<String, dynamic>>(
        'sync_fetch_changes_v2',
        params: {
          'p_generation': generationId,
          'p_after_sequence': afterSequence,
          'p_limit': limit,
        },
      );
      if (response['status'] == 'RECONCILIATION_REQUIRED') {
        return const Failure(FailureCode.syncNeedsReconciliation);
      }
      if (response['status'] != 'OK') {
        return const Failure(FailureCode.syncProtocolMismatch);
      }
      final rows = response['changes'];
      if (rows is! List || response['generation'] is! String) {
        throw const FormatException('Invalid generation page');
      }
      return Success(
        SyncChangePage(
          datasetGeneration: response['generation'] as String,
          changes: rows
              .map((row) => parseChange(Map<String, dynamic>.from(row as Map)))
              .toList(growable: false),
        ),
      );
    } on FormatException {
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on PostgrestException catch (error) {
      return Failure(_postgrest(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  /// Compatibility diagnostic for canonical current-state inspection. Pull
  /// execution uses immutable change snapshots and does not call this method.
  Future<Result<Map<SyncEntityType, List<SyncCanonicalEntity>>>> fetchEntities(
    Map<SyncEntityType, List<String>> ids, {
    required int throughSequence,
  }) async {
    if (throughSequence < 1) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    try {
      final result = <SyncEntityType, List<SyncCanonicalEntity>>{};
      for (final entry in ids.entries) {
        if (entry.value.isEmpty) continue;
        final rows = await client
            .from('sync_${_table(entry.key)}')
            .select()
            .inFilter('id', entry.value)
            .lte('server_revision', throughSequence);
        result[entry.key] = rows
            .map(
              (row) => parseCanonicalEntity(
                row,
                expectedType: entry.key,
                throughSequence: throughSequence,
              ),
            )
            .toList(growable: false);
      }
      return Success(result);
    } on FormatException {
      return const Failure(FailureCode.syncInvalidRemoteData);
    } on PostgrestException catch (error) {
      return Failure(_postgrest(error));
    } on Object {
      return const Failure(FailureCode.syncNetworkUnavailable);
    }
  }

  static SyncMutationResult parseMutationResult(Map<String, dynamic> row) {
    final status = switch (row['status']) {
      'APPLIED' => SyncMutationStatus.applied,
      'ALREADY_APPLIED' => SyncMutationStatus.alreadyApplied,
      'CONFLICT' => SyncMutationStatus.conflict,
      'REJECTED' => SyncMutationStatus.rejected,
      'RECONCILIATION_REQUIRED' => SyncMutationStatus.reconciliationRequired,
      _ => throw const FormatException('Unknown mutation result'),
    };
    final version = row['server_version'] as int?;
    final revision = row['server_revision'] as int?;
    if ((status == SyncMutationStatus.applied ||
            status == SyncMutationStatus.alreadyApplied) &&
        (version == null || version < 1 || revision == null || revision < 1)) {
      throw const FormatException('Missing applied version');
    }
    if (status == SyncMutationStatus.conflict &&
        (version == null ||
            version < 1 ||
            revision == null ||
            revision < 1 ||
            row['remote_snapshot'] is! Map)) {
      throw const FormatException('Missing conflict version');
    }
    return SyncMutationResult(
      status: status,
      serverVersion: version,
      serverRevision: revision,
      remoteSnapshot: row['remote_snapshot'] is Map
          ? Map<String, Object?>.unmodifiable(
              Map<String, Object?>.from(row['remote_snapshot'] as Map),
            )
          : null,
      isRemoteDeleted: row['remote_deleted'] == true,
      failure: status == SyncMutationStatus.reconciliationRequired
          ? FailureCode.syncGenerationMismatch
          : status == SyncMutationStatus.conflict
          ? FailureCode.syncConflict
          : status == SyncMutationStatus.rejected
          ? FailureCode.syncInvalidRemoteData
          : null,
    );
  }

  static SyncChange parseChange(Map<String, dynamic> row) {
    final snapshot = row['payload'];
    if (snapshot is! Map) throw const FormatException('Missing snapshot');
    return SyncChange(
      sequence: row['sequence'] as int,
      entityType: _parseEntity(row['entity_type'] as String),
      entityId: row['entity_id'] as String,
      serverVersion: row['server_version'] as int,
      operation: switch (row['operation']) {
        'upsert' => SyncOperation.update,
        'delete' => SyncOperation.delete,
        _ => throw const FormatException('Unknown change operation'),
      },
      originDeviceId: row['origin_device_id'] as String,
      mutationId: row['mutation_id'] as String,
      snapshot: Map<String, Object?>.unmodifiable(
        Map<String, Object?>.from(snapshot),
      ),
    );
  }

  static SyncCanonicalEntity parseCanonicalEntity(
    Map<String, dynamic> row, {
    required SyncEntityType expectedType,
    required int throughSequence,
  }) {
    final remoteType = row['entity_type'];
    if (remoteType != null && remoteType != _entity(expectedType)) {
      throw const FormatException('Canonical entity type mismatch');
    }
    final id = row['id'];
    final version = row['server_version'];
    final revision = row['server_revision'];
    if (id is! String || version is! int || revision is! int) {
      throw const FormatException('Missing canonical metadata');
    }
    return SyncCanonicalEntity(
      entityType: expectedType,
      id: id,
      serverVersion: version,
      serverRevision: revision,
      isDeleted: row['deleted_at'] != null,
      payload: Map<String, Object?>.unmodifiable(row),
      throughSequence: throughSequence,
    );
  }

  static String _entity(SyncEntityType value) => switch (value) {
    SyncEntityType.receiptAttachment => 'receipt_attachment',
    _ => value.name,
  };

  static String _table(SyncEntityType value) => switch (value) {
    SyncEntityType.profile => 'profiles',
    SyncEntityType.account => 'accounts',
    SyncEntityType.category => 'categories',
    SyncEntityType.transaction => 'transactions',
    SyncEntityType.transfer => 'transfers',
    SyncEntityType.project => 'projects',
    SyncEntityType.budget => 'budgets',
    SyncEntityType.receiptAttachment => 'receipt_attachments',
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
    _ => throw const FormatException('Unknown entity type'),
  };

  FailureCode _postgrest(PostgrestException error) => switch (error.code) {
    '42501' => FailureCode.syncUnauthorized,
    'PGRST301' => FailureCode.syncAuthenticationRequired,
    '429' => FailureCode.syncRateLimited,
    _ => FailureCode.syncBackendUnavailable,
  };
}
