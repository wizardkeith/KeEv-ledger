import 'package:flutter/material.dart';

import '../../../design_system/components.dart';
import '../../../core/result.dart';
import '../../../localization/generated/app_localizations.dart';
import '../application/sync_conflict_service.dart';
import '../application/sync_controller.dart';
import '../domain/sync_protocol.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key, required this.controller});
  final SyncController controller;

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final controller = widget.controller;
      final durable = controller.durable;
      return KeEvScaffold(
        title: l.syncTitle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            KeEvCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeEvSectionHeader(text: _status(l, controller.status)),
                  const SizedBox(height: 12),
                  Text(l.syncDescription),
                  if (durable != null) ...[
                    const SizedBox(height: 12),
                    Text('${l.syncPendingChanges}: ${durable.pendingChanges}'),
                    if (durable.lastSuccessfulSyncAtUtc != null)
                      Text(
                        '${l.syncLastSynced}: '
                        '${MaterialLocalizations.of(context).formatCompactDate(durable.lastSuccessfulSyncAtUtc!.toLocal())}',
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (controller.busy)
              Semantics(
                liveRegion: true,
                child: Column(
                  children: [
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(_progress(l, controller.progress)),
                  ],
                ),
              )
            else if (durable == null || !durable.syncEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeEvPrimaryButton(
                    key: const Key('enable-sync'),
                    label: l.syncEnable,
                    onPressed:
                        durable?.linkedAccountId != null &&
                            controller.status ==
                                SyncUserStatus.authenticationRequired
                        ? null
                        : () async {
                            final result = await controller.beginEnable();
                            if (!mounted || result is! Success<SyncDiscovery>) {
                              return;
                            }
                            await _showDiscovery(result.value);
                          },
                  ),
                  if (durable?.linkedAccountId != null)
                    TextButton(
                      key: const Key('unlink-inactive-sync'),
                      onPressed: _unlink,
                      child: Text(l.syncDisable),
                    ),
                ],
              )
            else ...[
              KeEvPrimaryButton(
                key: const Key('sync-now'),
                label: l.syncNow,
                onPressed: durable.paused ? null : controller.syncNow,
              ),
              const SizedBox(height: 8),
              KeEvSecondaryButton(
                key: const Key('pause-sync'),
                label: durable.paused ? l.syncResume : l.syncPause,
                onPressed: () => controller.pause(!durable.paused),
              ),
              if (durable.unresolvedConflicts > 0) ...[
                const SizedBox(height: 8),
                KeEvSecondaryButton(
                  key: const Key('resolve-conflicts'),
                  label: '${l.syncConflicts} (${durable.unresolvedConflicts})',
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) =>
                          SyncConflictScreen(controller: controller),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                key: const Key('unlink-sync'),
                onPressed: _unlink,
                child: Text(l.syncDisable),
              ),
            ],
            if (controller.failure != null) ...[
              const SizedBox(height: 16),
              KeEvErrorCard(message: _status(l, controller.status)),
            ],
          ],
        ),
      );
    },
  );

  Future<void> _showDiscovery(SyncDiscovery discovery) async {
    final l = AppLocalizations.of(context);
    final stage = widget.controller.durable?.stage;
    final resumeLocal = stage == SyncOnboardingStage.localToCloud;
    final resumeCloud = stage == SyncOnboardingStage.cloudToLocal;
    final choice = await showDialog<SyncOnboardingChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.syncEnable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summary(l, l.syncLocalData, discovery.local),
            const SizedBox(height: 12),
            _summary(l, l.syncCloudData, discovery.cloud.summary),
            if (discovery.classification == SyncDiscoveryCase.bothHaveData) ...[
              const SizedBox(height: 12),
              Text(l.syncNoAutomaticMerge),
              const SizedBox(height: 8),
              Text(l.syncDestructiveWarning),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, SyncOnboardingChoice.cancel),
            child: Text(l.syncCancel),
          ),
          if (!resumeLocal &&
              !resumeCloud &&
              discovery.classification == SyncDiscoveryCase.bothEmpty)
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, SyncOnboardingChoice.enableEmpty),
              child: Text(l.syncEnable),
            ),
          if (!resumeCloud &&
              (resumeLocal ||
                  discovery.classification == SyncDiscoveryCase.localOnly ||
                  discovery.classification == SyncDiscoveryCase.bothHaveData))
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, SyncOnboardingChoice.keepLocal),
              child: Text(l.syncKeepLocal),
            ),
          if (!resumeLocal &&
              (resumeCloud ||
                  discovery.classification == SyncDiscoveryCase.cloudOnly ||
                  discovery.classification == SyncDiscoveryCase.bothHaveData))
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, SyncOnboardingChoice.keepCloud),
              child: Text(l.syncKeepCloud),
            ),
        ],
      ),
    );
    if (choice != null) await widget.controller.confirm(choice);
  }

  Widget _summary(
    AppLocalizations l,
    String title,
    SyncLedgerSummary summary,
  ) => Semantics(
    container: true,
    child: Text(
      '$title\n'
      '${l.accounts}: ${summary.accounts} · ${l.history}: ${summary.transactions} · '
      '${l.receiptPhoto}: ${summary.receipts}'
      '${summary.baseCurrencyCode == null ? '' : ' · ${summary.baseCurrencyCode}'}',
    ),
  );

  Future<void> _unlink() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.syncDisable),
        content: Text(l.syncUnlinkWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.syncCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.syncDisable),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.controller.unlink();
  }
}

class SyncConflictScreen extends StatelessWidget {
  const SyncConflictScreen({super.key, required this.controller});
  final SyncController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return KeEvScaffold(
        title: l.syncConflictsTitle,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.unresolved.length,
          itemBuilder: (context, index) {
            final conflict = controller.unresolved[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KeEvCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KeEvSectionHeader(
                      text: _entityLabel(l, conflict.entityType),
                    ),
                    const SizedBox(height: 10),
                    _candidate(
                      l.syncLocalData,
                      l,
                      conflict.localCandidate,
                      conflict.localDeleted ? l.syncLocalDelete : null,
                    ),
                    const Divider(height: 24),
                    _candidate(
                      l.syncCloudData,
                      l,
                      conflict.remoteCandidate,
                      conflict.remoteDeleted ? l.syncCloudDelete : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: KeEvSecondaryButton(
                            label: l.syncKeepCloud,
                            onPressed: controller.busy
                                ? null
                                : () => controller.resolve(
                                    conflict,
                                    SyncConflictChoice.keepCloud,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: KeEvPrimaryButton(
                            label: l.syncKeepLocal,
                            onPressed: controller.busy
                                ? null
                                : () => controller.resolve(
                                    conflict,
                                    SyncConflictChoice.keepLocal,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  Widget _candidate(
    String heading,
    AppLocalizations l,
    Map<String, Object?> candidate,
    String? deleted,
  ) {
    const visible = [
      'name',
      'amount_minor_units',
      'currency_code',
      'business_date',
      'account_id',
      'category_id',
      'project_id',
      'note',
      'is_archived',
      'position',
      'mime_type',
    ];
    final rows = visible
        .where((key) => candidate.containsKey(key))
        .map((key) => '${_fieldLabel(l, key)}: ${candidate[key] ?? '—'}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (deleted != null) Text(deleted),
        for (final row in rows) Text(row),
      ],
    );
  }

  static String _entityLabel(AppLocalizations l, SyncEntityType type) =>
      switch (type) {
        SyncEntityType.profile => l.authentication,
        SyncEntityType.account => l.account,
        SyncEntityType.category => l.category,
        SyncEntityType.transaction || SyncEntityType.transfer => l.history,
        SyncEntityType.project => l.project,
        SyncEntityType.budget => l.budget,
        SyncEntityType.receiptAttachment => l.receiptPhoto,
      };

  static String _fieldLabel(AppLocalizations l, String key) => switch (key) {
    'name' => l.projectName,
    'amount_minor_units' => l.amount,
    'currency_code' => l.currency,
    'business_date' => l.history,
    'account_id' => l.account,
    'category_id' => l.category,
    'project_id' => l.project,
    'note' => l.noteOptional,
    'is_archived' => l.archivedEntity,
    'position' || 'mime_type' => l.receiptPhoto,
    _ => l.preview,
  };
}

String syncStatusLabel(AppLocalizations l, SyncController controller) =>
    _status(l, controller.status);

String _status(AppLocalizations l, SyncUserStatus status) => switch (status) {
  SyncUserStatus.localOnly => l.localOnlyModeTitle,
  SyncUserStatus.signedInDisabled => l.syncEnable,
  SyncUserStatus.initializationRequired ||
  SyncUserStatus.needsReconciliation => l.syncNeedsReconciliation,
  SyncUserStatus.active => l.syncActive,
  SyncUserStatus.paused => l.syncPaused,
  SyncUserStatus.conflicts => l.syncConflicts,
  SyncUserStatus.authenticationRequired => l.syncAuthRequired,
  SyncUserStatus.temporarilyUnavailable => l.syncOffline,
  SyncUserStatus.syncing => l.syncInitializing,
  SyncUserStatus.upToDate => l.syncUpToDate,
};

String _progress(AppLocalizations l, SyncOnboardingProgress? progress) =>
    switch (progress) {
      SyncOnboardingProgress.checking => l.syncChecking,
      SyncOnboardingProgress.preparing => l.syncInitializing,
      SyncOnboardingProgress.uploading => l.syncUploading,
      SyncOnboardingProgress.downloading => l.syncDownloading,
      SyncOnboardingProgress.verifying => l.syncVerifying,
      SyncOnboardingProgress.finalizing => l.syncFinalizing,
      null => l.syncInitializing,
    };
