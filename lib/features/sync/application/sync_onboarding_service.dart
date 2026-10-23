import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/result.dart';
import '../domain/sync_protocol.dart';
import 'sync_contracts.dart';
import 'sync_receipt_spool.dart';

typedef SyncReceiptSource = Future<Result<File>> Function(String storageKey);
typedef SyncDeviceIdProvider = Future<Result<String>> Function();

/// Explicit foreground-only onboarding. Nothing here is invoked by lifecycle,
/// connectivity, or background hooks.
final class SyncOnboardingService {
  const SyncOnboardingService({
    required this.local,
    required this.remote,
    required this.receipts,
    required this.receiptSource,
    required this.receiptSpool,
    required this.deviceIdProvider,
    required this.deviceRegistration,
  });

  final SyncOnboardingLocalStore local;
  final SyncOnboardingRemoteStore remote;
  final SyncReceiptTransport receipts;
  final SyncReceiptSource receiptSource;
  final SyncReceiptSpool receiptSpool;
  final SyncDeviceIdProvider deviceIdProvider;
  final SyncDeviceRegistrationRemote deviceRegistration;

  /// Best effort at the controller boundary; local unlink remains available.
  Future<Result<void>> unlinkDevice(String generation) async {
    final device = await deviceIdProvider();
    if (device is Failure<String>) return Failure(device.code);
    return deviceRegistration.unlinkDevice(
      deviceId: (device as Success<String>).value,
      generation: generation,
    );
  }

  Future<Result<SyncDiscovery>> discover() async {
    final localResult = await local.summarizeLocal();
    if (localResult is Failure<SyncLedgerSummary>) {
      return Failure(localResult.code);
    }
    final cloudResult = await remote.discover();
    if (cloudResult is Failure<SyncCloudDiscovery>) {
      return Failure(cloudResult.code);
    }
    return Success(
      SyncDiscovery(
        local: (localResult as Success<SyncLedgerSummary>).value,
        cloud: (cloudResult as Success<SyncCloudDiscovery>).value,
      ),
    );
  }

  Future<Result<void>> abort({
    required String operationId,
    required String generation,
  }) => remote.abortInitialization(
    SyncInitializationLease(
      operationId: operationId,
      generation: generation,
      snapshotRevision: 0,
    ),
  );

  Future<Result<void>> confirm({
    required String accountId,
    required SyncDiscovery discovery,
    required SyncOnboardingChoice choice,
    void Function(SyncOnboardingProgress progress)? onProgress,
  }) async {
    if (!_allowed(discovery.classification, choice)) {
      return const Failure(FailureCode.syncNeedsReconciliation);
    }
    if (choice == SyncOnboardingChoice.cancel) return const Success(null);
    onProgress?.call(SyncOnboardingProgress.preparing);
    final stage = choice == SyncOnboardingChoice.keepCloud
        ? SyncOnboardingStage.cloudToLocal
        : SyncOnboardingStage.localToCloud;
    final operation = await local.beginOnboarding(stage);
    if (operation is Failure<String>) return Failure(operation.code);
    final serverChoice = currentReplaceCloud(discovery.classification, choice)
        ? SyncOnboardingChoice.replaceCloud
        : choice;
    final lease = await remote.beginInitialization(
      operationId: (operation as Success<String>).value,
      choice: serverChoice,
    );
    if (lease is Failure<SyncInitializationLease>) {
      await local.failOnboarding();
      return Failure(lease.code);
    }
    final activeLease = (lease as Success<SyncInitializationLease>).value;
    final result = choice == SyncOnboardingChoice.keepCloud
        ? await _download(
            accountId,
            activeLease,
            onProgress,
            requireLocalEmpty:
                discovery.classification == SyncDiscoveryCase.cloudOnly,
          )
        : await _upload(accountId, activeLease, onProgress);
    if (result is Failure<void>) {
      // Server finalization and local activation may already be durable when
      // only the registration heartbeat fails. Preserve that safe active
      // state so a normal sync cycle can retry the idempotent heartbeat.
      final state = await local.readDurableState();
      final active =
          state is Success<SyncDurableState> &&
          state.value.stage == SyncOnboardingStage.active &&
          state.value.generation == activeLease.generation;
      if (!active) await local.failOnboarding();
    }
    return result;
  }

  Future<Result<void>> _upload(
    String accountId,
    SyncInitializationLease lease,
    void Function(SyncOnboardingProgress progress)? onProgress,
  ) async {
    final bound = await local.bindInitialization(
      accountId: accountId,
      generation: lease.generation,
    );
    if (bound is Failure<void>) return Failure(bound.code);
    final entitiesResult = await local.readInitialEntities();
    if (entitiesResult is Failure<List<SyncInitialEntity>>) {
      return Failure(entitiesResult.code);
    }
    final results = <SyncInitialEntityResult>[];
    final device = await deviceIdProvider();
    if (device is Failure<String>) return Failure(device.code);
    final deviceId = (device as Success<String>).value;
    final initialEntities =
        (entitiesResult as Success<List<SyncInitialEntity>>).value;
    onProgress?.call(SyncOnboardingProgress.uploading);
    for (final receipt in initialEntities.where(
      (entity) => entity.entityType == SyncEntityType.receiptAttachment,
    )) {
      final prepared = await _preserveInitialReceipt(receipt);
      if (prepared is Failure<void>) return Failure(prepared.code);
    }
    for (var entity in initialEntities) {
      if (entity.entityType == SyncEntityType.receiptAttachment) {
        final key = entity.payload['storage_key'];
        if (key is! String) {
          return const Failure(FailureCode.syncAttachmentIntegrityFailure);
        }
        var source = await receiptSpool.resolve(entity.entityId);
        if (source is Failure<File>) source = await receiptSource(key);
        if (source is Failure<File>) return Failure(source.code);
        final bytes = await (source as Success<File>).value.readAsBytes();
        final expectedSize = entity.payload['byte_size'];
        final expectedHash = entity.payload['sha256_hex'];
        if (expectedSize is! int ||
            expectedHash is! String ||
            bytes.length != expectedSize ||
            sha256.convert(bytes).toString() != expectedHash ||
            !_jpeg(bytes)) {
          return const Failure(FailureCode.syncAttachmentIntegrityFailure);
        }
        final path = '$accountId/receipts/${entity.entityId}/$expectedHash.jpg';
        final uploaded = await receipts.uploadImmutable(
          objectPath: path,
          bytes: bytes,
          sha256Hex: expectedHash,
        );
        if (uploaded is Failure<void>) return Failure(uploaded.code);
        entity = SyncInitialEntity(
          entityType: entity.entityType,
          entityId: entity.entityId,
          payload: {...entity.payload, 'storage_path': path},
        );
      }
      final uploaded = await remote.uploadInitialEntity(
        lease: lease,
        deviceId: deviceId,
        entity: entity,
      );
      if (uploaded is Failure<SyncInitialEntityResult>) {
        return Failure(uploaded.code);
      }
      results.add((uploaded as Success<SyncInitialEntityResult>).value);
    }
    final finalized = await remote.finalizeInitialization(lease);
    if (finalized is Failure<int>) return Failure(finalized.code);
    final finalizedRevision = (finalized as Success<int>).value;
    onProgress?.call(SyncOnboardingProgress.finalizing);
    final activated = await local.activate(
      accountId: accountId,
      generation: lease.generation,
      cursor: finalizedRevision,
      entityStates: results,
    );
    if (activated is Success<void>) {
      for (final receipt in initialEntities.where(
        (entity) => entity.entityType == SyncEntityType.receiptAttachment,
      )) {
        await receiptSpool.remove(receipt.entityId);
      }
      final registered = await deviceRegistration.acknowledgeDevice(
        deviceId: deviceId,
        generation: lease.generation,
        revision: finalizedRevision,
      );
      if (registered is Failure<void>) return Failure(registered.code);
    }
    return activated;
  }

  Future<Result<void>> _preserveInitialReceipt(SyncInitialEntity entity) async {
    final key = entity.payload['storage_key'];
    final expectedSize = entity.payload['byte_size'];
    final expectedHash = entity.payload['sha256_hex'];
    if (key is! String || expectedSize is! int || expectedHash is! String) {
      return const Failure(FailureCode.syncInvalidRemoteData);
    }
    final existing = await receiptSpool.resolve(entity.entityId);
    if (existing is Success<File>) return const Success(null);
    final source = await receiptSource(key);
    if (source is Failure<File>) return Failure(source.code);
    final preserved = await receiptSpool.prepare(
      attachmentId: entity.entityId,
      processedFile: (source as Success<File>).value,
      sha256Hex: expectedHash,
      byteSize: expectedSize,
    );
    return switch (preserved) {
      Success<bool>(value: true) => const Success(null),
      Success<bool>(value: false) => const Failure(
        FailureCode.syncAttachmentFailure,
      ),
      Failure<bool>(:final code) => Failure(code),
    };
  }

  Future<Result<void>> _download(
    String accountId,
    SyncInitializationLease lease,
    void Function(SyncOnboardingProgress progress)? onProgress, {
    required bool requireLocalEmpty,
  }) async {
    final entities = <SyncInitialEntity>[];
    final receiptBytes = <String, List<int>>{};
    var offset = 0;
    var highWater = lease.snapshotRevision;
    onProgress?.call(SyncOnboardingProgress.downloading);
    while (true) {
      final pageResult = await remote.fetchSnapshotPage(
        generation: lease.generation,
        highWaterRevision: highWater,
        offset: offset,
      );
      if (pageResult is Failure<SyncSnapshotPage>) {
        return Failure(pageResult.code);
      }
      final page = (pageResult as Success<SyncSnapshotPage>).value;
      if (page.generation != lease.generation ||
          page.highWaterRevision != highWater) {
        return const Failure(FailureCode.syncGenerationMismatch);
      }
      for (final entity in page.entities) {
        entities.add(entity);
        if (entity.entityType != SyncEntityType.receiptAttachment ||
            entity.payload['deleted_at'] != null) {
          continue;
        }
        final path = entity.payload['storage_path'];
        final expectedSize = entity.payload['byte_size'];
        final expectedHash = entity.payload['sha256_hex'];
        if (path is! String ||
            expectedSize is! int ||
            expectedHash is! String) {
          return const Failure(FailureCode.syncInvalidRemoteData);
        }
        final downloaded = await receipts.download(path);
        if (downloaded is Failure<List<int>>) return Failure(downloaded.code);
        final bytes = (downloaded as Success<List<int>>).value;
        if (bytes.length != expectedSize ||
            sha256.convert(bytes).toString() != expectedHash ||
            !_jpeg(bytes)) {
          return const Failure(FailureCode.syncAttachmentIntegrityFailure);
        }
        receiptBytes['${entity.entityId}.jpg'] = bytes;
      }
      final next = page.nextOffset;
      if (next == null) break;
      offset = next;
    }
    onProgress?.call(SyncOnboardingProgress.verifying);
    if (requireLocalEmpty) {
      final localSummary = await local.summarizeLocal();
      if (localSummary is Failure<SyncLedgerSummary>) {
        return Failure(localSummary.code);
      }
      if ((localSummary as Success<SyncLedgerSummary>)
          .value
          .hasMeaningfulData) {
        return const Failure(FailureCode.syncNeedsReconciliation);
      }
    }
    final finalized = await remote.finalizeInitialization(lease);
    if (finalized is Failure<int>) return Failure(finalized.code);
    if ((finalized as Success<int>).value != highWater) {
      return const Failure(FailureCode.syncProtocolMismatch);
    }
    onProgress?.call(SyncOnboardingProgress.finalizing);
    final replaced = await local.replaceWithCloudSnapshot(
      accountId: accountId,
      generation: lease.generation,
      cursor: highWater,
      entities: entities,
      receiptBytes: receiptBytes,
    );
    if (replaced is Failure<void>) return replaced;
    final device = await deviceIdProvider();
    if (device is Failure<String>) return Failure(device.code);
    return deviceRegistration.acknowledgeDevice(
      deviceId: (device as Success<String>).value,
      generation: lease.generation,
      revision: highWater,
    );
  }

  static bool _allowed(
    SyncDiscoveryCase discovery,
    SyncOnboardingChoice choice,
  ) => switch ((discovery, choice)) {
    (_, SyncOnboardingChoice.cancel) => true,
    (SyncDiscoveryCase.bothEmpty, SyncOnboardingChoice.enableEmpty) => true,
    (SyncDiscoveryCase.localOnly, SyncOnboardingChoice.keepLocal) => true,
    (SyncDiscoveryCase.cloudOnly, SyncOnboardingChoice.keepCloud) => true,
    (SyncDiscoveryCase.bothHaveData, SyncOnboardingChoice.keepLocal) => true,
    (SyncDiscoveryCase.bothHaveData, SyncOnboardingChoice.keepCloud) => true,
    _ => false,
  };

  static bool currentReplaceCloud(
    SyncDiscoveryCase discovery,
    SyncOnboardingChoice choice,
  ) =>
      discovery == SyncDiscoveryCase.bothHaveData &&
      choice == SyncOnboardingChoice.keepLocal;

  static bool _jpeg(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;
}
