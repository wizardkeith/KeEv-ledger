import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/clock.dart';
import '../core/currency.dart';
import '../core/local_id.dart';
import '../core/result.dart';
import '../infrastructure/local/ledger_database.dart' show LedgerDatabase;
import '../features/local_profile/data/drift_local_profile_repository.dart';
import '../features/local_profile/domain/local_profile.dart';
import '../features/bookkeeping/data/drift_bookkeeping_repositories.dart';
import '../features/bookkeeping/data/drift_transfer_repository.dart';
import '../features/bookkeeping/application/bookkeeping_service.dart';
import '../features/bookkeeping/application/bookkeeping_session.dart';
import '../features/planning/application/planning_service.dart';
import '../features/planning/data/drift_planning_repositories.dart';
import '../features/reports/application/reporting_service.dart';
import '../features/receipts/application/receipt_service.dart';
import '../features/receipts/application/receipt_contracts.dart';
import '../features/receipts/data/drift_receipt_repository.dart';
import '../features/receipts/infrastructure/image_picker_receipt_acquirer.dart';
import '../features/receipts/infrastructure/local_receipt_file_store.dart';
import '../features/voice/application/voice_recognition.dart';
import '../features/voice/infrastructure/speech_to_text_recognizer.dart';
import '../features/backup/application/backup_service.dart';
import '../features/backup/data/drift_ledger_backup_store.dart';
import '../features/sync/infrastructure/local_sync_receipt_spool.dart';
import '../features/account/application/account_controller.dart';
import '../features/sync/application/sync_conflict_service.dart';
import '../features/sync/application/sync_connectivity.dart';
import '../features/sync/application/sync_controller.dart';
import '../features/sync/application/sync_engine.dart';
import '../features/sync/application/sync_onboarding_service.dart';
import '../features/sync/application/sync_trigger_coordinator.dart';
import '../features/sync/data/drift_sync_conflict_store.dart';
import '../features/sync/data/drift_sync_onboarding_store.dart';
import '../features/sync/data/drift_sync_state_store.dart';
import '../features/sync/infrastructure/local_sync_receipt_pull_files.dart';
import '../features/sync/infrastructure/platform_sync_connectivity_observer.dart';
import '../features/sync/infrastructure/supabase_sync_onboarding_store.dart';
import '../features/sync/infrastructure/supabase_sync_receipt_transport.dart';
import '../features/sync/infrastructure/supabase_sync_remote_store.dart';
import '../features/sync/infrastructure/supabase_sync_realtime_hints.dart';

/// Composition root for local-only bookkeeping. UI sees only application APIs.
final class BookkeepingRuntime implements BookkeepingSession {
  factory BookkeepingRuntime(
    LedgerDatabase db, {
    ReceiptImageAcquirer? receiptAcquirer,
    ReceiptFileStore? receiptFileStore,
    VoiceRecognizer? voiceRecognizer,
    AccountController? accountController,
    SupabaseClient? syncClient,
  }) {
    const clock = SystemClock();
    final ids = SecureUuidV4Generator();
    final profiles = DriftLocalProfileRepository(db, ids, clock);
    final accounts = DriftAccountRepository(db);
    final categories = DriftCategoryRepository(db);
    final entries = DriftEntryRepository(db);
    final transfers = DriftTransferRepository(db);
    final service = BookkeepingService(
      profiles: profiles,
      accounts: accounts,
      categories: categories,
      entries: entries,
      transfers: transfers,
      ids: ids,
      clock: clock,
    );
    final files =
        receiptFileStore ??
        LocalReceiptFileStore(
          directoryProvider: () async {
            final support = await getApplicationSupportDirectory();
            return Directory('${support.path}/receipt_attachments');
          },
        );
    final receipts = ReceiptService(
      bookkeeping: service,
      repository: DriftReceiptAttachmentRepository(db),
      files: files,
      acquirer: receiptAcquirer ?? ImagePickerReceiptAcquirer(),
      ids: ids,
      clock: clock,
      syncSpool: LocalSyncReceiptSpool(
        db: db,
        directoryProvider: () async {
          final support = await getApplicationSupportDirectory();
          return Directory('${support.path}/sync_receipt_spool');
        },
      ),
    );
    Future<Directory> receiptDirectory() async {
      final support = await getApplicationSupportDirectory();
      return Directory('${support.path}/receipt_attachments');
    }

    final backup = BackupService(
      store: DriftLedgerBackupStore(db),
      receiptDirectoryProvider: receiptDirectory,
      temporaryDirectoryProvider: getTemporaryDirectory,
    );
    SyncController? syncController;
    SyncTriggerCoordinator? syncCoordinator;
    SyncConnectivityBinding? syncConnectivity;
    if (accountController != null && syncClient != null) {
      final transport = SupabaseSyncReceiptTransport(syncClient);
      final syncSpool = LocalSyncReceiptSpool(
        db: db,
        directoryProvider: () async {
          final support = await getApplicationSupportDirectory();
          return Directory('${support.path}/sync_receipt_spool');
        },
      );
      final state = DriftSyncStateStore(
        db,
        receiptFiles: LocalSyncReceiptPullFiles(
          transport: transport,
          directoryProvider: receiptDirectory,
        ),
      );
      final onboardingLocal = DriftSyncOnboardingStore(db: db, backup: backup);
      final onboardingRemote = SupabaseSyncOnboardingStore(syncClient);
      final syncRemote = SupabaseSyncRemoteStore(syncClient);
      final onboarding = SyncOnboardingService(
        local: onboardingLocal,
        remote: onboardingRemote,
        receipts: transport,
        receiptSource: files.resolve,
        receiptSpool: syncSpool,
        deviceIdProvider: () async {
          try {
            final row = await db.select(db.syncDeviceStates).getSingle();
            return Success(row.deviceId);
          } on Object {
            return const Failure(FailureCode.syncLocalStoreFailure);
          }
        },
        deviceRegistration: syncRemote,
      );
      final engine = SyncEngine(
        remote: syncRemote,
        local: state,
        clock: clock,
        receiptTransport: transport,
        receiptSpool: syncSpool,
      );
      final conflictLocal = DriftSyncConflictStore(db: db, runtime: state);
      syncController = SyncController(
        local: onboardingLocal,
        onboarding: onboarding,
        engine: engine,
        conflicts: SyncConflictService(
          local: conflictLocal,
          remote: onboardingRemote,
        ),
        authenticatedAccountId: () => accountController.account?.id,
        receiptSpool: syncSpool,
      );
      syncCoordinator = SyncTriggerCoordinator(
        controller: syncController,
        clock: clock,
        realtime: SupabaseSyncRealtimeHints(syncClient),
      );
      syncController.addListener(syncCoordinator.stateChanged);
      syncConnectivity = SyncConnectivityBinding(
        observer: PlatformSyncConnectivityObserver(),
        coordinator: syncCoordinator,
      );
      unawaited(syncConnectivity.start());
    }
    final runtime = BookkeepingRuntime._(
      database: db,
      service: service,
      receipts: receipts,
      planning: PlanningService(
        profiles: DriftLocalProfileRepository(db, ids, clock),
        entries: entries,
        transfers: transfers,
        budgets: DriftBudgetRepository(db),
        projects: DriftProjectRepository(db),
        ids: ids,
        clock: clock,
      ),
      reporting: ReportingService(
        accounts: accounts,
        categories: categories,
        entries: entries,
        transfers: transfers,
      ),
      voice: voiceRecognizer ?? SpeechToTextRecognizer(),
      backup: backup,
      syncController: syncController,
      syncCoordinator: syncCoordinator,
      syncConnectivity: syncConnectivity,
      accountController: accountController,
    );
    accountController?.addListener(runtime._accountChanged);
    return runtime;
  }
  BookkeepingRuntime._({
    required this.database,
    required this.service,
    required this.planning,
    required this.reporting,
    required this.receipts,
    required this.voice,
    required this.backup,
    required this.syncController,
    required this.syncCoordinator,
    required this.syncConnectivity,
    required AccountController? accountController,
  }) : _accountController = accountController;
  factory BookkeepingRuntime.openLocal({
    AccountController? accountController,
    SupabaseClient? syncClient,
  }) => BookkeepingRuntime(
    LedgerDatabase.openLocal(),
    accountController: accountController,
    syncClient: syncClient,
  );
  final LedgerDatabase database;
  final BookkeepingService service;
  @override
  final PlanningService planning;
  @override
  final ReportingService reporting;
  @override
  final ReceiptService receipts;
  @override
  final VoiceRecognizer voice;
  final BackupService backup;
  final SyncController? syncController;
  final SyncTriggerCoordinator? syncCoordinator;
  final SyncConnectivityBinding? syncConnectivity;
  final AccountController? _accountController;
  Future<Result<LocalId>>? _profile;

  Future<Result<LocalId>> profile() => _profile ??= _loadProfile();
  Future<Result<LocalId>> _loadProfile() async {
    final stored = await service.profiles.read();
    if (stored is Failure<LocalProfile?>) return Failure(stored.code);
    final existing = (stored as Success<LocalProfile?>).value;
    if (existing != null) return Success(existing.id);
    final created = await service.profiles.create(baseCurrency: Currency.hkd);
    if (created is Success<LocalProfile>) return Success(created.value.id);
    if (created is Failure<LocalProfile> &&
        created.code == FailureCode.localProfileAlreadyExists) {
      final reread = await service.profiles.read();
      if (reread is Success<LocalProfile?> && reread.value != null)
        return Success(reread.value!.id);
    }
    return Failure((created as Failure<LocalProfile>).code);
  }

  Future<void> reconcileReceipts() async {
    final result = await profile();
    if (result is Success<LocalId>) await receipts.reconcile(result.value);
  }

  Future<void> resetAfterRestore() async {
    _profile = null;
    await receipts.clearSyncSpoolAfterRestore();
  }

  void _accountChanged() {
    if (syncCoordinator != null) {
      unawaited(syncCoordinator!.accountStateChanged());
    } else if (syncController != null) {
      unawaited(syncController!.load());
    }
  }

  Future<void> close() async {
    _accountController?.removeListener(_accountChanged);
    await syncConnectivity?.dispose();
    await syncCoordinator?.dispose();
    await database.close();
  }
}
