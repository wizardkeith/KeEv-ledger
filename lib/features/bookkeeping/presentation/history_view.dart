import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../design_system/theme.dart';
import '../../../localization/generated/app_localizations.dart';
import '../application/bookkeeping_service.dart';
import '../application/bookkeeping_session.dart';
import '../domain/bookkeeping.dart';
import 'quick_add_screen.dart';
import '../../reports/domain/reports.dart';
import '../../receipts/domain/receipt_attachment.dart';

String displayMoney(Money money) {
  final negative = money.minorUnits < 0;
  final digits = money.minorUnits.abs().toString().padLeft(
    money.currency.minorDigits + 1,
    '0',
  );
  final integral = money.currency.minorDigits == 0
      ? digits
      : digits.substring(0, digits.length - money.currency.minorDigits);
  final grouped = integral.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  final fraction = money.currency.minorDigits == 0
      ? ''
      : '.${digits.substring(digits.length - money.currency.minorDigits)}';
  return '${negative ? '−' : ''}${money.currency.code} $grouped$fraction';
}

class HistoryView extends StatefulWidget {
  const HistoryView({super.key, required this.session});
  final BookkeepingSession session;
  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late Future<(Result<List<LedgerHistoryItem>>, Map<LocalId, Account>)> events;
  final search = TextEditingController();
  HistoryEventFilter filter = HistoryEventFilter.all;

  @override
  void initState() {
    super.initState();
    events = _load();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
    events = _load();
  });

  Future<(Result<List<LedgerHistoryItem>>, Map<LocalId, Account>)>
  _load() async {
    final profile = await widget.session.profile();
    if (profile is Failure<LocalId>)
      return (
        Failure<List<LedgerHistoryItem>>(profile.code),
        <LocalId, Account>{},
      );
    final id = (profile as Success<LocalId>).value;
    final history = await widget.session.reporting.transactionHistory(
      TransactionHistoryQuery(profileId: id, event: filter, text: search.text),
    );
    final accounts = await widget.session.service.accounts.list(
      id,
      includeArchived: true,
    );
    if (accounts is Failure<List<Account>>)
      return (
        Failure<List<LedgerHistoryItem>>(accounts.code),
        <LocalId, Account>{},
      );
    return (
      history,
      {for (final a in (accounts as Success<List<Account>>).value) a.id: a},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<
      (Result<List<LedgerHistoryItem>>, Map<LocalId, Account>)
    >(
      future: events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const KeEvLoadingState();
        final (result, accounts) = snapshot.data!;
        if (result is Failure<List<LedgerHistoryItem>>)
          return KeEvErrorCard(message: l.saveFailed);
        final list = (result as Success<List<LedgerHistoryItem>>).value;
        return ListView.builder(
          key: const PageStorageKey('ledger-history-list'),
          padding: const EdgeInsets.all(16),
          itemCount: list.length + 1 + (list.isEmpty ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.preview),
                  const SizedBox(height: 24),
                  KeEvCard(
                    child: Column(
                      children: [
                        DropdownButtonFormField<HistoryEventFilter>(
                          key: const Key('history-kind-filter'),
                          initialValue: filter,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: l.history),
                          items: [
                            DropdownMenuItem(
                              value: HistoryEventFilter.all,
                              child: Text(l.allTransactions),
                            ),
                            DropdownMenuItem(
                              value: HistoryEventFilter.income,
                              child: Text(l.income),
                            ),
                            DropdownMenuItem(
                              value: HistoryEventFilter.expense,
                              child: Text(l.expense),
                            ),
                            DropdownMenuItem(
                              value: HistoryEventFilter.transfer,
                              child: Text(l.transfer),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            filter = value;
                            _reload();
                          },
                        ),
                        TextField(
                          key: const Key('history-note-search'),
                          controller: search,
                          decoration: InputDecoration(
                            labelText: l.searchNotes,
                            suffixIcon: IconButton(
                              tooltip: l.applyFilter,
                              onPressed: _reload,
                              icon: const Icon(Icons.search),
                            ),
                          ),
                          onSubmitted: (_) => _reload(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: KeEvCard(child: Text(l.noHistory)),
              );
            }
            final item = list[index - 1];
            return Padding(
              key: ValueKey(
                item.entry != null
                    ? 'history-entry-${item.entry!.id.value}'
                    : 'history-transfer-${item.transfer!.id.value}',
              ),
              padding: const EdgeInsets.only(top: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.transfer == null
                            ? '${item.entry!.kind == EntryKind.expense ? l.expense : l.income} · ${accounts[item.entry!.accountId]?.name ?? l.account}'
                            : '${l.transfer} · ${accounts[item.transfer!.sourceAccountId]?.name ?? l.sourceAccount} → ${accounts[item.transfer!.destinationAccountId]?.name ?? l.destinationAccount}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(item.businessDate.value),
                      if ((item.transfer?.note ?? item.entry?.note)
                          case final String text)
                        Text(text),
                      const SizedBox(height: 8),
                      Text(
                        displayMoney(item.transfer?.sent ?? item.entry!.amount),
                        style: KeEvTypography.financialAmount(
                          Theme.of(context).textTheme,
                        ),
                      ),
                      if (item.transfer != null &&
                          item.transfer!.sent.currency !=
                              item.transfer!.received.currency)
                        Text(
                          displayMoney(item.transfer!.received),
                          style: KeEvTypography.financialAmount(
                            Theme.of(context).textTheme,
                          ),
                        ),
                      if (item.entry != null)
                        _ReceiptStrip(
                          key: ValueKey(
                            'receipt-strip-${item.entry!.profileId.value}-${item.entry!.id.value}',
                          ),
                          session: widget.session,
                          profileId: item.entry!.profileId,
                          transactionId: item.entry!.id,
                          onChanged: _reload,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReceiptStrip extends StatefulWidget {
  const _ReceiptStrip({
    super.key,
    required this.session,
    required this.profileId,
    required this.transactionId,
    required this.onChanged,
  });
  final BookkeepingSession session;
  final LocalId profileId, transactionId;
  final VoidCallback onChanged;
  @override
  State<_ReceiptStrip> createState() => _ReceiptStripState();
}

class _ReceiptStripState extends State<_ReceiptStrip> {
  late Future<Result<List<ReceiptAttachment>>> rows = _load();

  @override
  void didUpdateWidget(covariant _ReceiptStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionId != widget.transactionId ||
        oldWidget.profileId != widget.profileId ||
        !identical(oldWidget.session, widget.session)) {
      rows = _load();
    }
  }

  Future<Result<List<ReceiptAttachment>>> _load() =>
      widget.session.receipts.list(widget.profileId, widget.transactionId);

  Future<void> _open(ReceiptAttachment attachment) async {
    final l = AppLocalizations.of(context);
    final resolved = await widget.session.receipts.resolve(attachment);
    if (!mounted || resolved is Failure<File>) return;
    final file = (resolved as Success<File>).value;
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.receiptPhoto),
        content: InteractiveViewer(child: Image.file(file)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.close),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.removeReceipt),
          ),
        ],
      ),
    );
    if (remove != true) return;
    final removed = await widget.session.receipts.remove(
      widget.profileId,
      attachment.id,
    );
    if (!mounted || removed is Failure<void>) return;
    setState(() => rows = _load());
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Result<List<ReceiptAttachment>>>(
        future: rows,
        builder: (context, snapshot) {
          if (snapshot.data is! Success<List<ReceiptAttachment>>) {
            return const SizedBox.shrink();
          }
          final attachments =
              (snapshot.data as Success<List<ReceiptAttachment>>).value;
          if (attachments.isEmpty) return const SizedBox.shrink();
          return Wrap(
            spacing: 8,
            children: [
              for (final attachment in attachments)
                IconButton(
                  tooltip: AppLocalizations.of(context).viewReceipt,
                  onPressed: () => _open(attachment),
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
            ],
          );
        },
      );
}

class AccountOverview extends StatefulWidget {
  const AccountOverview({super.key, required this.session});
  final BookkeepingSession session;
  @override
  State<AccountOverview> createState() => _AccountOverviewState();
}

class _AccountOverviewState extends State<AccountOverview> {
  late Future<Result<List<Account>>> accounts = _load();
  Future<Result<List<Account>>> _load() async {
    final profile = await widget.session.profile();
    if (profile is Failure<LocalId>) return Failure(profile.code);
    return widget.session.service.listAccounts(
      (profile as Success<LocalId>).value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvScaffold(
      title: l.accounts,
      child: FutureBuilder<Result<List<Account>>>(
        future: accounts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: KeEvLoadingState());
          if (snapshot.data is Failure<List<Account>>)
            return KeEvErrorCard(message: l.saveFailed);
          final rows = (snapshot.data as Success<List<Account>>).value;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (rows.isEmpty) KeEvCard(child: Text(l.firstAccount)),
              for (final a in rows)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(a.currency.code),
                        FutureBuilder<Result<Money>>(
                          future: widget.session.service.accountBalance(
                            a.profileId,
                            a.id,
                          ),
                          builder: (context, amount) => Text(
                            amount.data is Success<Money>
                                ? displayMoney(
                                    (amount.data as Success<Money>).value,
                                  )
                                : l.loading,
                            style: KeEvTypography.financialAmount(
                              Theme.of(context).textTheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              KeEvPrimaryButton(
                label: l.addAccount,
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuickAddScreen(session: widget.session),
                    ),
                  );
                  if (mounted) setState(() => accounts = _load());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
