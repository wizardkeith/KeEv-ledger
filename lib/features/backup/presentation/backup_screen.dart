import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/bookkeeping_runtime.dart';
import '../../../core/local_id.dart';
import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../features/account/application/account_controller.dart';
import '../../../features/account/application/cloud_backend_contracts.dart';
import '../../../localization/generated/app_localizations.dart';
import '../domain/backup.dart';

Future<bool> confirmCloudBackupDeletion(BuildContext context) async {
  final l = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.deleteBackup),
          content: Text(l.deleteCloudBackupConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancelVoice),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.deleteBackup),
            ),
          ],
        ),
      ) ??
      false;
}

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({
    super.key,
    required this.runtime,
    required this.accountController,
  });
  final BookkeepingRuntime runtime;
  final AccountController? accountController;

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool busy = false;
  String? status;
  List<CloudBackupMetadata> cloud = const [];

  @override
  void initState() {
    super.initState();
    _refreshCloud();
  }

  Future<void> _refreshCloud() async {
    final account = widget.accountController;
    if (account == null || !account.canUseCloudBackup) return;
    final result = await account.listBackups();
    if (mounted && result is Success<List<CloudBackupMetadata>>) {
      setState(() => cloud = result.value);
    }
  }

  Future<String?> _passphrase({required bool confirm}) async {
    final l = AppLocalizations.of(context);
    final first = TextEditingController(), second = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l.backupPassphrase),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.backupPassphraseHelp),
            TextField(
              controller: first,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(labelText: l.backupPassphrase),
            ),
            if (confirm)
              TextField(
                controller: second,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l.confirmBackupPassphrase,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancelVoice),
          ),
          FilledButton(
            onPressed: () {
              if (first.text.runes.length >= 10 &&
                  (!confirm || first.text == second.text))
                Navigator.pop(context, first.text);
            },
            child: Text(l.continueLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _create({required bool upload}) async {
    if (busy) return;
    final l = AppLocalizations.of(context);
    final passphrase = await _passphrase(confirm: true);
    if (passphrase == null) return;
    setState(() {
      busy = true;
      status = null;
    });
    File? temporaryBackup;
    try {
      final result = await widget.runtime.backup.createLocalBackup(passphrase);
      if (result is Failure<LocalBackupFile>) {
        if (mounted) setState(() => status = l.backupFailed);
        return;
      }
      final backup = (result as Success<LocalBackupFile>).value;
      temporaryBackup = backup.file;
      final bytes = await backup.file.readAsBytes();
      if (upload) {
        final account = widget.accountController;
        final uploaded = account == null
            ? const Failure<CloudBackupMetadata>(
                FailureCode.cloudAuthenticationRequired,
              )
            : await account.uploadBackup(
                CloudBackupUpload(
                  id: SecureUuidV4Generator().generate().value,
                  filePath: backup.file.path,
                  byteSize: bytes.length,
                  encryptedSha256: sha256.convert(bytes).toString(),
                  formatVersion: keevBackupFormatVersion,
                  appVersion: '0.1.0+1',
                ),
              );
        if (mounted) {
          setState(
            () => status = uploaded is Success<CloudBackupMetadata>
                ? l.backupCreated
                : l.backupFailed,
          );
        }
        if (uploaded is Success<CloudBackupMetadata>) await _refreshCloud();
      } else {
        final uri = await FilePicker.saveFile(
          fileName: backup.file.uri.pathSegments.last,
          bytes: Uint8List.fromList(bytes),
          mimeType: 'application/octet-stream',
          type: FileType.custom,
          allowedExtensions: const ['keevbackup'],
        );
        if (mounted)
          setState(() => status = uri == null ? null : l.backupCreated);
      }
    } on FileSystemException {
      if (mounted) setState(() => status = l.backupFailed);
    } on Object {
      if (mounted) setState(() => status = l.backupFailed);
    } finally {
      if (temporaryBackup != null) {
        try {
          if (await temporaryBackup.exists()) await temporaryBackup.delete();
        } on FileSystemException {
          // Private temporary cleanup is best effort.
        }
      }
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _pickRestore() async {
    if (busy) return;
    setState(() {
      busy = true;
      status = null;
    });
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['keevbackup'],
      );
      if (picked?.path == null) return;
      await _prepareAndRestore(File(picked!.path!), operationStarted: true);
    } on Object {
      if (mounted)
        setState(
          () => status = AppLocalizations.of(context).restoreFailedMessage,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _prepareAndRestore(
    File file, {
    bool operationStarted = false,
  }) async {
    final l = AppLocalizations.of(context);
    if (!operationStarted) {
      if (busy) return;
      setState(() {
        busy = true;
        status = null;
      });
    }
    final passphrase = await _passphrase(confirm: false);
    if (passphrase == null) {
      if (!operationStarted && mounted) setState(() => busy = false);
      return;
    }
    final prepared = await widget.runtime.backup.prepareRestore(
      file,
      passphrase,
    );
    if (!mounted) return;
    if (prepared is Failure<PreparedRestore>) {
      setState(() {
        status = prepared.code == FailureCode.wrongBackupPassphrase
            ? l.wrongBackupPassphrase
            : l.corruptedBackup;
      });
      return;
    }
    final value = (prepared as Success<PreparedRestore>).value;
    final counts = value.preview.manifest.entityCounts;
    final manifest = value.preview.manifest;
    final material = MaterialLocalizations.of(context);
    final created = manifest.createdAtUtc.toLocal();
    final createdLabel =
        '${material.formatFullDate(created)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(created))}';
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.restorePreview),
            content: Text(
              '${l.restoreReplaceWarning}\n\n${l.backupCreatedAt}: $createdLabel\n${l.backupFormatVersion}: ${keevBackupFormatVersion}\n${l.backupSourceApp}: ${manifest.appVersion}\n${l.backupBaseCurrency}: ${manifest.baseCurrencyCode}\n${l.accounts}: ${counts['accounts'] ?? 0}\n${l.history}: ${counts['transactions'] ?? 0}\n${l.category}: ${counts['categories'] ?? 0}\n${l.projects}: ${counts['projects'] ?? 0}\n${l.budget}: ${counts['budgets'] ?? 0}\n${l.receiptPhoto}: ${manifest.attachmentCount}\n${l.encryptedBackupSize}: ${value.preview.encryptedBytes} bytes',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancelVoice),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.restoreConfirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      if (!operationStarted && mounted) setState(() => busy = false);
      return;
    }
    final restored = await widget.runtime.backup.restore(value);
    await widget.runtime.resetAfterRestore();
    if (mounted)
      setState(() {
        status = restored is Success<void>
            ? l.restoreCompleted
            : l.restoreFailedMessage;
      });
  }

  Future<void> _restoreCloud(CloudBackupMetadata item) async {
    if (busy) return;
    setState(() {
      busy = true;
      status = null;
    });
    File? file;
    try {
      final result = await widget.accountController!.retrieveBackup(item.id);
      if (result is! Success<List<int>>) {
        if (mounted)
          setState(
            () => status = AppLocalizations.of(context).restoreFailedMessage,
          );
        return;
      }
      if (sha256.convert(result.value).toString() != item.encryptedSha256) {
        if (mounted)
          setState(() => status = AppLocalizations.of(context).corruptedBackup);
        return;
      }
      final temp = await getTemporaryDirectory();
      file = File('${temp.path}${Platform.pathSeparator}${item.id}.keevbackup');
      await file.writeAsBytes(result.value, flush: true);
      await _prepareAndRestore(file, operationStarted: true);
    } on Object {
      if (mounted)
        setState(
          () => status = AppLocalizations.of(context).restoreFailedMessage,
        );
    } finally {
      if (file != null) {
        try {
          if (await file.exists()) await file.delete();
        } on FileSystemException {}
      }
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _deleteCloud(CloudBackupMetadata item) async {
    if (busy) return;
    final l = AppLocalizations.of(context);
    final confirmed = await confirmCloudBackupDeletion(context);
    if (!confirmed || !mounted) return;
    setState(() {
      busy = true;
      status = null;
    });
    try {
      final result = await widget.accountController!.deleteBackup(item.id);
      if (result is Success<void>) await _refreshCloud();
      if (mounted && result is Failure<void>)
        setState(() => status = l.backupFailed);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), account = widget.accountController;
    return KeEvScaffold(
      title: l.backup,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KeEvSectionHeader(text: l.localBackup),
          Text(l.backupSecurityInfo),
          const SizedBox(height: 12),
          KeEvPrimaryButton(
            label: l.createEncryptedBackup,
            onPressed: busy ? null : () => _create(upload: false),
          ),
          const SizedBox(height: 8),
          KeEvSecondaryButton(
            label: l.restoreFromBackupFile,
            onPressed: busy ? null : _pickRestore,
          ),
          const SizedBox(height: 24),
          KeEvSectionHeader(text: l.cloudBackup),
          if (account == null || !account.canUseCloudBackup)
            Text(l.cloudSignInRequired)
          else ...[
            KeEvPrimaryButton(
              label: l.createEncryptedBackup,
              onPressed: busy ? null : () => _create(upload: true),
            ),
            if (cloud.isEmpty) Text(l.noCloudBackups),
            for (final item in cloud)
              ListTile(
                title: Text(item.createdAtUtc.toLocal().toString()),
                subtitle: Text('${item.byteSize} bytes'),
                onTap: busy ? null : () => _restoreCloud(item),
                trailing: IconButton(
                  tooltip: l.deleteBackup,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: busy ? null : () => _deleteCloud(item),
                ),
              ),
          ],
          if (busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: KeEvLoadingState(),
            ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(status!, semanticsLabel: status),
            ),
        ],
      ),
    );
  }
}
