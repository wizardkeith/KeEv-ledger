import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../application/bookkeeping_session.dart';
import '../application/money_input.dart';
import '../domain/bookkeeping.dart';
import '../../planning/domain/project.dart';
import '../../receipts/application/receipt_contracts.dart';
import '../../receipts/domain/receipt_attachment.dart';
import '../../voice/application/voice_recognition.dart';
import '../../voice/application/voice_transaction_parser.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key, required this.session});
  final BookkeepingSession session;
  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final amount = TextEditingController(),
      received = TextEditingController(),
      note = TextEditingController();
  LocalId? profileId, sourceId, destinationId, categoryId, projectId;
  List<Account> accounts = [];
  List<Category> categories = [];
  List<Project> projects = [];
  EntryKind? entryKind = EntryKind.expense;
  bool loading = true, saving = false;
  FailureCode? failure;
  final List<File> receiptSources = [];
  late DateTime day = DateTime.now();
  final voiceOwnership = VoiceDraftOwnership();
  final voiceParser = const VoiceTransactionParser();
  VoiceRecognitionStatus voiceStatus = VoiceRecognitionStatus.idle;
  String voiceTranscript = '';
  FailureCode? voiceFailure;
  bool applyingVoice = false;
  bool voiceDisclosureAccepted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    voiceOwnership.cancelSession();
    unawaited(widget.session.voice.cancel());
    amount.dispose();
    received.dispose();
    note.dispose();
    super.dispose();
  }

  String _localeTag(Locale locale) => [
    locale.languageCode,
    if (locale.scriptCode != null) locale.scriptCode!,
    if (locale.countryCode != null) locale.countryCode!,
  ].join('-');

  String _moneyInput(Money money) {
    final scale = BigInt.from(10).pow(money.currency.minorDigits);
    final units = BigInt.from(money.minorUnits);
    final whole = units ~/ scale;
    if (money.currency.minorDigits == 0) return '$whole';
    final fraction = (units % scale).toString().padLeft(
      money.currency.minorDigits,
      '0',
    );
    return '$whole.$fraction';
  }

  Future<void> _startVoice() async {
    if (saving || voiceStatus == VoiceRecognitionStatus.listening) return;
    final source = _account(sourceId);
    if (source == null) {
      setState(() => voiceFailure = FailureCode.accountNotFound);
      return;
    }
    if (!voiceDisclosureAccepted) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppLocalizations.of(dialogContext).voiceEntry),
          content: Text(
            AppLocalizations.of(dialogContext).voicePrivacyDisclosure,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppLocalizations.of(dialogContext).cancelVoice),
            ),
            FilledButton(
              key: const Key('voice-disclosure-continue'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(AppLocalizations.of(dialogContext).continueLabel),
            ),
          ],
        ),
      );
      if (!mounted || accepted != true) return;
      voiceDisclosureAccepted = true;
    }
    final session = voiceOwnership.beginSession();
    setState(() {
      voiceStatus = VoiceRecognitionStatus.processing;
      voiceFailure = null;
      voiceTranscript = '';
    });
    final result = await widget.session.voice.start(
      uiLocaleTag: _localeTag(Localizations.localeOf(context)),
      onTranscript: (transcript) {
        if (!mounted || !voiceOwnership.isCurrent(session)) return;
        final current = _account(sourceId);
        if (current == null) return;
        final candidate = voiceParser.parse(
          transcript.text,
          contextCurrency: current.currency,
        );
        setState(() {
          voiceTranscript = transcript.text;
          applyingVoice = true;
          try {
            if (candidate.amount != null &&
                candidate.amount!.currency == current.currency &&
                voiceOwnership.mayApply(session, VoiceDraftField.amount)) {
              amount.text = _moneyInput(candidate.amount!);
            }
            if (candidate.kind != null &&
                voiceOwnership.mayApply(session, VoiceDraftField.kind)) {
              entryKind = candidate.kind;
              if (!categories.any(
                (category) =>
                    category.id == categoryId && category.kind == entryKind,
              )) {
                categoryId = null;
              }
            }
            if (candidate.category != null &&
                voiceOwnership.mayApply(session, VoiceDraftField.category)) {
              final intendedKind = candidate.kind ?? entryKind;
              categoryId = categories
                  .where(
                    (category) =>
                        category.kind == intendedKind &&
                        categoryMatchesVoiceIntent(
                          category.name,
                          candidate.category!,
                        ),
                  )
                  .firstOrNull
                  ?.id;
            }
            if (transcript.isFinal) voiceStatus = VoiceRecognitionStatus.idle;
          } finally {
            applyingVoice = false;
          }
        });
      },
      onStatus: (status) {
        if (mounted && voiceOwnership.isCurrent(session)) {
          setState(() => voiceStatus = status);
        }
      },
      onError: (code) {
        if (mounted && voiceOwnership.isCurrent(session)) {
          setState(() {
            voiceStatus = VoiceRecognitionStatus.idle;
            voiceFailure = code;
          });
        }
      },
    );
    if (!mounted || !voiceOwnership.isCurrent(session)) return;
    if (result is Failure<String>) {
      setState(() {
        voiceStatus = VoiceRecognitionStatus.idle;
        voiceFailure = result.code;
      });
    }
  }

  Future<void> _stopVoice() => widget.session.voice.stop();

  Future<void> _cancelVoice() async {
    voiceOwnership.cancelSession();
    await widget.session.voice.cancel();
    if (mounted) setState(() => voiceStatus = VoiceRecognitionStatus.idle);
  }

  String _voiceError(AppLocalizations l, FailureCode code) => switch (code) {
    FailureCode.accountNotFound => l.chooseAccount,
    FailureCode.speechPermissionDenied => l.voicePermissionDenied,
    FailureCode.speechLocaleUnavailable => l.voiceLocaleUnavailable,
    FailureCode.speechUnavailable => l.voiceUnavailable,
    _ => l.voiceRecognitionFailed,
  };

  Future<void> _load() async {
    final profile = await widget.session.profile();
    if (!mounted) return;
    if (profile is Failure<LocalId>) {
      setState(() {
        failure = profile.code;
        loading = false;
      });
      return;
    }
    profileId = (profile as Success<LocalId>).value;
    await _refresh();
  }

  Future<void> _refresh() async {
    final a = await widget.session.service.listAccounts(profileId!);
    final c = await widget.session.service.listCategories(profileId!);
    final p = await widget.session.planning.projects.list(profileId!);
    if (!mounted) return;
    if (a is Failure<List<Account>> ||
        c is Failure<List<Category>> ||
        p is Failure<List<Project>>) {
      setState(() {
        failure = FailureCode.localStoreUnavailable;
        loading = false;
      });
      return;
    }
    setState(() {
      accounts = (a as Success<List<Account>>).value;
      categories = (c as Success<List<Category>>).value;
      projects = (p as Success<List<Project>>).value;
      if (!accounts.any((account) => account.id == sourceId))
        sourceId = accounts.firstOrNull?.id;
      if (!accounts.any((account) => account.id == destinationId))
        destinationId = null;
      if (!categories.any(
        (category) => category.id == categoryId && category.kind == entryKind,
      ))
        categoryId = null;
      if (!projects.any((project) => project.id == projectId)) projectId = null;
      loading = false;
      failure = null;
    });
  }

  Account? _account(LocalId? id) {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  String _error(AppLocalizations l, FailureCode code) => switch (code) {
    FailureCode.invalidAmount => l.invalidMoney,
    FailureCode.accountNotFound => l.chooseAccount,
    FailureCode.categoryNotFound => l.chooseCategory,
    FailureCode.sameAccount => l.differentAccounts,
    FailureCode.receivedAmountRequired => l.receivedRequired,
    FailureCode.accountArchived ||
    FailureCode.categoryArchived => l.archivedEntity,
    FailureCode.projectArchived => l.projectArchived,
    FailureCode.currencyMismatch ||
    FailureCode.categoryKindMismatch ||
    FailureCode.transferAmountMismatch => l.mismatchEntity,
    FailureCode.dateBeforeOpening => l.beforeOpening,
    FailureCode.attachmentLimitReached => l.receiptLimitReached,
    FailureCode.attachmentInvalidImage => l.receiptInvalid,
    FailureCode.attachmentTooLarge => l.receiptTooLarge,
    FailureCode.attachmentPermissionDenied => l.receiptPermissionDenied,
    _ => l.saveFailed,
  };

  Future<void> _pickReceipt(ReceiptAcquisitionSource source) async {
    if (receiptSources.length >= maximumReceiptsPerTransaction) {
      setState(() => failure = FailureCode.attachmentLimitReached);
      return;
    }
    final result = await widget.session.receipts.acquirer.acquire(source);
    if (!mounted) return;
    if (result is Failure<AcquiredReceipt?>) {
      setState(() => failure = result.code);
      return;
    }
    final acquired = (result as Success<AcquiredReceipt?>).value;
    if (acquired == null) return;
    setState(() {
      receiptSources.add(File(acquired.path));
      failure = null;
    });
  }

  Future<void> _save() async {
    if (saving) return;
    final l = AppLocalizations.of(context);
    final source = _account(sourceId);
    if (source == null) {
      setState(() => failure = FailureCode.accountNotFound);
      return;
    }
    final sent = MoneyInput.parsePositive(amount.text, source.currency);
    if (sent is Failure<Money>) {
      setState(() => failure = sent.code);
      return;
    }
    Money? incoming;
    if (entryKind == null) {
      final destination = _account(destinationId);
      if (destination == null) {
        setState(() => failure = FailureCode.accountNotFound);
        return;
      }
      if (source.id == destination.id) {
        setState(() => failure = FailureCode.sameAccount);
        return;
      }
      if (destination.currency != source.currency) {
        final parsed = MoneyInput.parsePositive(
          received.text,
          destination.currency,
        );
        if (parsed is Failure<Money>) {
          setState(
            () => failure = received.text.trim().isEmpty
                ? FailureCode.receivedAmountRequired
                : parsed.code,
          );
          return;
        }
        incoming = (parsed as Success<Money>).value;
      }
    } else if (categoryId == null) {
      setState(() => failure = FailureCode.categoryNotFound);
      return;
    }
    setState(() {
      saving = true;
      failure = null;
    });
    final businessDate = BusinessDate(
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
    );
    final money = (sent as Success<Money>).value;
    final text = note.text.trim();
    Result<Object> result;
    if (entryKind == null) {
      result = await widget.session.service.transfer(
        profileId: profileId!,
        sourceAccountId: sourceId!,
        destinationAccountId: destinationId!,
        sent: money,
        received: incoming,
        businessDate: businessDate,
        note: text.isEmpty ? null : text,
      );
    } else if (entryKind == EntryKind.income) {
      result = await widget.session.receipts.recordIncomeWithReceipts(
        profileId: profileId!,
        accountId: sourceId!,
        categoryId: categoryId!,
        amount: money,
        businessDate: businessDate,
        note: text.isEmpty ? null : text,
        projectId: projectId,
        receiptSources: receiptSources,
      );
    } else {
      result = await widget.session.receipts.recordExpenseWithReceipts(
        profileId: profileId!,
        accountId: sourceId!,
        categoryId: categoryId!,
        amount: money,
        businessDate: businessDate,
        note: text.isEmpty ? null : text,
        projectId: projectId,
        receiptSources: receiptSources,
      );
    }
    if (!mounted) return;
    if (result is Failure<Object>) {
      final code = result.code;
      setState(() {
        saving = false;
        failure = code;
      });
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.savedLocally)));
    Navigator.of(context).pop(true);
  }

  Future<void> _createAccount() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _AccountDialog(session: widget.session, profileId: profileId!),
    );
    if (created == true && mounted) await _refresh();
  }

  Future<void> _createCategory() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _CategoryDialog(
        session: widget.session,
        profileId: profileId!,
        kind: entryKind!,
      ),
    );
    if (created == true && mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final source = _account(sourceId);
    final destination = _account(destinationId);
    final transfer = entryKind == null;
    return KeEvScaffold(
      title: l.quickAdd,
      child: loading
          ? const Center(child: KeEvLoadingState())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<int>(
                  key: const Key('entry-kind'),
                  segments: [
                    ButtonSegment(value: 0, label: Text(l.expense)),
                    ButtonSegment(value: 1, label: Text(l.income)),
                    ButtonSegment(value: 2, label: Text(l.transfer)),
                  ],
                  selected: {
                    entryKind == null
                        ? 2
                        : entryKind == EntryKind.income
                        ? 1
                        : 0,
                  },
                  onSelectionChanged: saving
                      ? null
                      : (value) => setState(() {
                          voiceOwnership.markUserEdited(VoiceDraftField.kind);
                          entryKind = switch (value.first) {
                            1 => EntryKind.income,
                            2 => null,
                            _ => EntryKind.expense,
                          };
                          categoryId = null;
                          if (entryKind == null) projectId = null;
                          if (entryKind == null) {
                            voiceOwnership.cancelSession();
                            unawaited(widget.session.voice.cancel());
                            voiceStatus = VoiceRecognitionStatus.idle;
                          }
                          failure = null;
                        }),
                ),
                const SizedBox(height: 16),
                KeEvCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        key: const Key('quick-amount'),
                        controller: amount,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText: transfer ? l.sentAmount : l.amount,
                          suffixText: source?.currency.code,
                          suffixIcon: transfer
                              ? null
                              : IconButton(
                                  key: const Key('voice-start'),
                                  tooltip: l.voiceEntry,
                                  onPressed:
                                      saving ||
                                          voiceStatus ==
                                              VoiceRecognitionStatus.listening
                                      ? null
                                      : _startVoice,
                                  icon: const Icon(Icons.mic_none_outlined),
                                ),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (!applyingVoice) {
                            voiceOwnership.markUserEdited(
                              VoiceDraftField.amount,
                            );
                          }
                        },
                      ),
                      if (!transfer &&
                          (voiceStatus != VoiceRecognitionStatus.idle ||
                              voiceTranscript.isNotEmpty ||
                              voiceFailure != null)) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          liveRegion: true,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  voiceStatus ==
                                          VoiceRecognitionStatus.listening
                                      ? l.listening
                                      : voiceStatus ==
                                            VoiceRecognitionStatus.processing
                                      ? l.processingSpeech
                                      : voiceTranscript.isEmpty
                                      ? l.reviewVoiceDraft
                                      : voiceTranscript,
                                  key: const Key('voice-transcript'),
                                ),
                              ),
                              if (voiceStatus ==
                                  VoiceRecognitionStatus.listening)
                                IconButton(
                                  key: const Key('voice-stop'),
                                  tooltip: l.stopListening,
                                  onPressed: _stopVoice,
                                  icon: const Icon(Icons.stop_circle_outlined),
                                ),
                              if (voiceStatus != VoiceRecognitionStatus.idle)
                                IconButton(
                                  key: const Key('voice-cancel'),
                                  tooltip: l.cancelVoice,
                                  onPressed: _cancelVoice,
                                  icon: const Icon(Icons.close),
                                ),
                            ],
                          ),
                        ),
                        if (voiceFailure != null)
                          KeEvErrorCard(message: _voiceError(l, voiceFailure!)),
                      ],
                      const SizedBox(height: 12),
                      if (accounts.isEmpty) Text(l.firstAccount),
                      KeyedSubtree(
                        key: ValueKey('source-${sourceId?.value}'),
                        child: DropdownButtonFormField<LocalId>(
                          key: const Key('quick-source'),
                          initialValue: sourceId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: transfer ? l.sourceAccount : l.account,
                          ),
                          items: [
                            for (final a in accounts)
                              DropdownMenuItem(
                                value: a.id,
                                child: Text(
                                  '${a.name} · ${a.currency.code}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: saving
                              ? null
                              : (value) => setState(() {
                                  sourceId = value;
                                  if (destinationId == value)
                                    destinationId = null;
                                  received.clear();
                                  failure = null;
                                }),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: saving ? null : _createAccount,
                        icon: const Icon(Icons.add),
                        label: Text(l.addAccount),
                      ),
                      if (transfer) ...[
                        if (accounts.length < 2) Text(l.secondAccount),
                        KeyedSubtree(
                          key: ValueKey(
                            'destination-${sourceId?.value}-${destinationId?.value}',
                          ),
                          child: DropdownButtonFormField<LocalId>(
                            key: const Key('quick-destination'),
                            initialValue: destinationId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l.destinationAccount,
                            ),
                            items: [
                              for (final a in accounts)
                                if (a.id != sourceId)
                                  DropdownMenuItem(
                                    value: a.id,
                                    child: Text(
                                      '${a.name} · ${a.currency.code}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                            ],
                            onChanged: saving
                                ? null
                                : (value) => setState(() {
                                    destinationId = value;
                                    received.clear();
                                    failure = null;
                                  }),
                          ),
                        ),
                        if (source != null &&
                            destination != null &&
                            source.currency != destination.currency)
                          TextField(
                            key: const Key('quick-received'),
                            controller: received,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: l.receivedAmount,
                              suffixText: destination.currency.code,
                            ),
                          ),
                      ] else ...[
                        if (!categories.any((c) => c.kind == entryKind))
                          Text(l.categoryNeeded),
                        KeyedSubtree(
                          key: ValueKey(
                            'category-${entryKind?.name}-${categoryId?.value}',
                          ),
                          child: DropdownButtonFormField<LocalId>(
                            key: const Key('quick-category'),
                            initialValue: categoryId,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: l.category),
                            items: [
                              for (final c in categories)
                                if (c.kind == entryKind)
                                  DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                            ],
                            onChanged: saving
                                ? null
                                : (value) => setState(() {
                                    if (!applyingVoice) {
                                      voiceOwnership.markUserEdited(
                                        VoiceDraftField.category,
                                      );
                                    }
                                    categoryId = value;
                                    failure = null;
                                  }),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: saving ? null : _createCategory,
                          icon: const Icon(Icons.add),
                          label: Text(l.addCategory),
                        ),
                        DropdownButtonFormField<LocalId?>(
                          key: const Key('quick-project'),
                          initialValue: projectId,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l.project),
                          items: [
                            DropdownMenuItem<LocalId?>(
                              value: null,
                              child: Text(l.noProject),
                            ),
                            for (final project in projects)
                              DropdownMenuItem<LocalId?>(
                                value: project.id,
                                child: Text(
                                  project.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: saving
                              ? null
                              : (value) => setState(() {
                                  projectId = value;
                                  failure = null;
                                }),
                        ),
                      ],
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(l.businessDate),
                          subtitle: Text(
                            '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.calendar_today_outlined),
                          onTap: saving
                              ? null
                              : () async {
                                  final chosen = await showDatePicker(
                                    context: context,
                                    initialDate: day,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  if (chosen != null && mounted)
                                    setState(() => day = chosen);
                                },
                        ),
                      ),
                      TextField(
                        key: const Key('quick-note'),
                        controller: note,
                        maxLines: 2,
                        decoration: InputDecoration(labelText: l.noteOptional),
                        onChanged: (_) {
                          if (!applyingVoice) {
                            voiceOwnership.markUserEdited(VoiceDraftField.note);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (failure != null)
                        KeEvErrorCard(message: _error(l, failure!)),
                      KeEvPrimaryButton(
                        key: const Key('quick-save'),
                        label: saving ? l.loading : l.save,
                        onPressed: saving ? null : _save,
                      ),
                      if (!transfer) ...[
                        const SizedBox(height: 12),
                        Text(
                          l.receiptsOptional,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(l.receiptPrivacyNote),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              key: const Key('take-receipt-photo'),
                              onPressed: saving
                                  ? null
                                  : () => _pickReceipt(
                                      ReceiptAcquisitionSource.camera,
                                    ),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: Text(l.takePhoto),
                            ),
                            OutlinedButton.icon(
                              key: const Key('choose-receipt-photo'),
                              onPressed: saving
                                  ? null
                                  : () => _pickReceipt(
                                      ReceiptAcquisitionSource.photoLibrary,
                                    ),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(l.choosePhoto),
                            ),
                          ],
                        ),
                        for (final (index, source) in receiptSources.indexed)
                          Semantics(
                            label: '${l.receiptPhoto} ${index + 1}',
                            child: ListTile(
                              key: ValueKey('pending-receipt-$index'),
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox.square(
                                dimension: 56,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    source,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                              title: Text('${l.receiptPhoto} ${index + 1}'),
                              trailing: IconButton(
                                tooltip: l.removeReceipt,
                                onPressed: saving
                                    ? null
                                    : () => setState(
                                        () => receiptSources.removeAt(index),
                                      ),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _AccountDialog extends StatefulWidget {
  const _AccountDialog({required this.session, required this.profileId});
  final BookkeepingSession session;
  final LocalId profileId;
  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  final name = TextEditingController();
  AccountKind kind = AccountKind.cash;
  Currency currency = Currency.hkd;
  bool saving = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (saving) return;
    final l = AppLocalizations.of(context);
    final text = name.text.trim();
    if (text.isEmpty || text.length > 120) {
      setState(() => error = l.name);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final current = DateTime.now();
    final date = BusinessDate(
      '${current.year.toString().padLeft(4, '0')}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}',
    );
    final result = await widget.session.service.createAccount(
      profileId: widget.profileId,
      name: text,
      kind: kind,
      currency: currency,
      openingBalance: Money.zero(currency),
      openingDate: date,
    );
    if (!mounted) return;
    if (result is Success<Account>)
      Navigator.of(context).pop(true);
    else
      setState(() {
        saving = false;
        error = l.saveFailed;
      });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addAccount),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('account-name'),
            controller: name,
            decoration: InputDecoration(labelText: l.name),
          ),
          DropdownButtonFormField<AccountKind>(
            initialValue: kind,
            decoration: InputDecoration(labelText: l.accountType),
            items: [
              for (final k in AccountKind.values)
                DropdownMenuItem(
                  value: k,
                  child: Text(switch (k) {
                    AccountKind.cash => l.cash,
                    AccountKind.bank => l.bank,
                    AccountKind.creditCard => l.creditCard,
                    AccountKind.eWallet => l.eWallet,
                    AccountKind.other => l.other,
                  }),
                ),
            ],
            onChanged: saving
                ? null
                : (value) {
                    if (value != null) setState(() => kind = value);
                  },
          ),
          DropdownButtonFormField<Currency>(
            initialValue: currency,
            decoration: InputDecoration(labelText: l.currency),
            items: [
              for (final c in Currency.supported)
                DropdownMenuItem(value: c, child: Text(c.code)),
            ],
            onChanged: saving
                ? null
                : (value) {
                    if (value != null) setState(() => currency = value);
                  },
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: Text(l.close),
        ),
        FilledButton(
          key: const Key('create-account'),
          onPressed: saving ? null : _create,
          child: Text(l.create),
        ),
      ],
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    required this.session,
    required this.profileId,
    required this.kind,
  });
  final BookkeepingSession session;
  final LocalId profileId;
  final EntryKind kind;
  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final name = TextEditingController();
  String? error;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (saving) return;
    final l = AppLocalizations.of(context);
    final text = name.text.trim();
    if (text.isEmpty || text.length > 120) {
      setState(() => error = l.name);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final result = await widget.session.service.createCategory(
      profileId: widget.profileId,
      name: text,
      kind: widget.kind,
    );
    if (!mounted) return;
    if (result is Success<Category>)
      Navigator.of(context).pop(true);
    else
      setState(() {
        saving = false;
        error = l.saveFailed;
      });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addCategory),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('category-name'),
            controller: name,
            decoration: InputDecoration(labelText: l.name),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: Text(l.close),
        ),
        FilledButton(
          key: const Key('create-category'),
          onPressed: saving ? null : _create,
          child: Text(l.create),
        ),
      ],
    );
  }
}
