import '../../../core/result.dart';
import '../domain/sync_protocol.dart';
import 'sync_contracts.dart';

enum SyncConflictChoice { keepLocal, keepCloud }

final class SyncConflictService {
  const SyncConflictService({required this.local, required this.remote});
  final SyncConflictLocalStore local;
  final SyncConflictRemoteStore remote;

  Future<Result<List<SyncConflictItem>>> list() => local.unresolvedConflicts();

  Future<Result<void>> resolve({
    required SyncConflictItem conflict,
    required SyncConflictChoice choice,
    required String generation,
  }) async {
    final refreshed = await remote.fetchCurrentEntity(
      generation: generation,
      entityType: conflict.entityType,
      entityId: conflict.entityId,
    );
    if (refreshed is Failure<SyncCanonicalEntity>) {
      return Failure(refreshed.code);
    }
    final current = (refreshed as Success<SyncCanonicalEntity>).value;
    return choice == SyncConflictChoice.keepLocal
        ? local.keepLocal(
            conflict: conflict,
            currentRemote: current,
            generation: generation,
          )
        : local.keepCloud(conflict: conflict, currentRemote: current);
  }
}
