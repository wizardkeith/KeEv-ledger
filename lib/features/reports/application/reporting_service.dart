import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../bookkeeping/domain/history_item.dart';
import '../../bookkeeping/domain/recorded_fx.dart';
import '../../bookkeeping/domain/transfer.dart';
import '../domain/reports.dart';

final class _Accumulator {
  _Accumulator(this.currency);
  final Currency currency;
  BigInt income = BigInt.zero;
  BigInt expense = BigInt.zero;
  bool hasActivity = false;
  final issues = <FxIssue>{};
  final provenance = <FxProvenance>[];

  void add(BookkeepingEntry entry, RecordedFxConversion conversion) {
    hasActivity = true;
    if (!conversion.isComplete) {
      issues.add(conversion.issue!);
      return;
    }
    if (conversion.provenance != null) provenance.add(conversion.provenance!);
    final units = BigInt.from(conversion.money!.minorUnits);
    if (entry.kind == EntryKind.income) {
      income += units;
    } else {
      expense += units;
    }
  }

  ReportTotals build() {
    final incomeMoney = Money.fromExactMinorUnits(currency, income);
    final expenseMoney = Money.fromExactMinorUnits(currency, expense);
    return ReportTotals(
      income: incomeMoney,
      expense: expenseMoney,
      net: incomeMoney - expenseMoney,
      hasActivity: hasActivity,
      completeness: ReportCompleteness(
        issues: Set.unmodifiable(issues),
        provenance: List.unmodifiable(provenance),
      ),
    );
  }
}

final class ReportingService {
  const ReportingService({
    required this.accounts,
    required this.categories,
    required this.entries,
    required this.transfers,
    this.fx = const RecordedFxConverter(),
  });

  final AccountRepository accounts;
  final CategoryRepository categories;
  final EntryRepository entries;
  final TransferRepository transfers;
  final RecordedFxConverter fx;

  Future<Result<IncomeExpenseReport>> incomeExpense(ReportQuery query) async {
    final loaded = await _load(query.profileId);
    if (loaded case Failure<_ReportData>(:final code)) return Failure(code);
    final data = (loaded as Success<_ReportData>).value;
    final currentEntries = data.entries
        .where((entry) => query.range.contains(entry.businessDate))
        .where((entry) => _matches(entry, query))
        .toList();
    final current = _totals(currentEntries, query.currency, data.transfers);
    final previousQuery = ReportQuery(
      profileId: query.profileId,
      range: query.range.previous,
      currency: query.currency,
      categoryId: query.categoryId,
      accountId: query.accountId,
      projectId: query.projectId,
    );
    final previous = _totals(
      data.entries
          .where((entry) => previousQuery.range.contains(entry.businessDate))
          .where((entry) => _matches(entry, previousQuery)),
      query.currency,
      data.transfers,
    );
    return Success(
      IncomeExpenseReport(
        query: query,
        totals: current,
        categories: _breakdowns(
          currentEntries,
          data.categories,
          (entry) => entry.categoryId,
          query.currency,
          data.transfers,
        ),
        accounts: _breakdowns(
          currentEntries,
          data.accounts,
          (entry) => entry.accountId,
          query.currency,
          data.transfers,
        ),
        trend: _trend(currentEntries, query.currency, data.transfers),
        comparison: PeriodComparison(
          range: previousQuery.range,
          income: _comparison(
            current.income,
            previous.income,
            current,
            previous,
          ),
          expense: _comparison(
            current.expense,
            previous.expense,
            current,
            previous,
          ),
          net: _comparison(current.net, previous.net, current, previous),
        ),
      ),
    );
  }

  Future<Result<AssetsLiabilitiesOverview>> assetsLiabilities({
    required LocalId profileId,
    required BusinessDate asOf,
    required Currency currency,
  }) async {
    final loaded = await _load(profileId);
    if (loaded case Failure<_ReportData>(:final code)) return Failure(code);
    final data = (loaded as Success<_ReportData>).value;
    var assetUnits = BigInt.zero;
    var liabilityUnits = BigInt.zero;
    final rows = <AccountAsOfRow>[];
    final issues = <FxIssue>{};
    final provenance = <FxProvenance>[];
    for (final account in data.accounts) {
      if (account.openingDate.compareTo(asOf) > 0) continue;
      var nativeUnits = BigInt.from(account.openingBalance.minorUnits);
      for (final entry in data.entries) {
        if (entry.accountId != account.id ||
            entry.businessDate.compareTo(asOf) > 0) {
          continue;
        }
        final units = BigInt.from(entry.amount.minorUnits);
        nativeUnits = entry.kind == EntryKind.income
            ? nativeUnits + units
            : nativeUnits - units;
      }
      for (final transfer in data.transfers) {
        if (transfer.businessDate.compareTo(asOf) > 0) continue;
        if (transfer.sourceAccountId == account.id) {
          nativeUnits -= BigInt.from(transfer.sent.minorUnits);
        } else if (transfer.destinationAccountId == account.id) {
          nativeUnits += BigInt.from(transfer.received.minorUnits);
        }
      }
      final native = Money.fromExactMinorUnits(account.currency, nativeUnits);
      final conversion = fx.convert(
        amount: native,
        target: currency,
        businessDate: asOf,
        availableTransfers: data.transfers,
      );
      final rowIssues = <FxIssue>{};
      final rowProvenance = <FxProvenance>[];
      if (!conversion.isComplete) {
        rowIssues.add(conversion.issue!);
        issues.add(conversion.issue!);
      } else {
        if (conversion.provenance != null) {
          rowProvenance.add(conversion.provenance!);
          provenance.add(conversion.provenance!);
        }
        final units = BigInt.from(conversion.money!.minorUnits);
        if (account.kind == AccountKind.creditCard) {
          liabilityUnits -= units;
        } else {
          assetUnits += units;
        }
      }
      rows.add(
        AccountAsOfRow(
          account: account,
          nativeBalance: native,
          reportedBalance: conversion.money,
          completeness: ReportCompleteness(
            issues: Set.unmodifiable(rowIssues),
            provenance: List.unmodifiable(rowProvenance),
          ),
        ),
      );
    }
    final assets = Money.fromExactMinorUnits(currency, assetUnits);
    final liabilities = Money.fromExactMinorUnits(currency, liabilityUnits);
    return Success(
      AssetsLiabilitiesOverview(
        profileId: profileId,
        asOf: asOf,
        currency: currency,
        assets: assets,
        liabilities: liabilities,
        net: assets - liabilities,
        accounts: List.unmodifiable(rows),
        completeness: ReportCompleteness(
          issues: Set.unmodifiable(issues),
          provenance: List.unmodifiable(provenance),
        ),
      ),
    );
  }

  Future<Result<List<LedgerHistoryItem>>> transactionHistory(
    TransactionHistoryQuery query,
  ) async {
    final entryResult = await entries.history(query.profileId);
    if (entryResult is Failure<List<BookkeepingEntry>>) {
      return Failure(entryResult.code);
    }
    final transferResult = await transfers.history(query.profileId);
    if (transferResult is Failure<List<LedgerTransfer>>) {
      return Failure(transferResult.code);
    }
    final needle = query.text?.trim().toLowerCase();
    bool textMatches(String? note) =>
        needle == null ||
        needle.isEmpty ||
        (note?.toLowerCase().contains(needle) ?? false);
    final items =
        <LedgerHistoryItem>[
          for (final entry
              in (entryResult as Success<List<BookkeepingEntry>>).value)
            if ((query.range?.contains(entry.businessDate) ?? true) &&
                (query.event == HistoryEventFilter.all ||
                    (query.event == HistoryEventFilter.income &&
                        entry.kind == EntryKind.income) ||
                    (query.event == HistoryEventFilter.expense &&
                        entry.kind == EntryKind.expense)) &&
                query.event != HistoryEventFilter.transfer &&
                (query.accountId == null ||
                    entry.accountId == query.accountId) &&
                (query.categoryId == null ||
                    entry.categoryId == query.categoryId) &&
                (query.projectId == null ||
                    entry.projectId == query.projectId) &&
                textMatches(entry.note))
              LedgerHistoryItem.entry(entry),
          for (final transfer
              in (transferResult as Success<List<LedgerTransfer>>).value)
            if ((query.range?.contains(transfer.businessDate) ?? true) &&
                (query.event == HistoryEventFilter.all ||
                    query.event == HistoryEventFilter.transfer) &&
                query.categoryId == null &&
                query.projectId == null &&
                (query.accountId == null ||
                    transfer.sourceAccountId == query.accountId ||
                    transfer.destinationAccountId == query.accountId) &&
                textMatches(transfer.note))
              LedgerHistoryItem.transfer(transfer),
        ]..sort((a, b) {
          final date = b.businessDate.compareTo(a.businessDate);
          return date != 0 ? date : b.id.value.compareTo(a.id.value);
        });
    return Success(items);
  }

  bool _matches(BookkeepingEntry entry, ReportQuery query) =>
      (query.categoryId == null || entry.categoryId == query.categoryId) &&
      (query.accountId == null || entry.accountId == query.accountId) &&
      (query.projectId == null || entry.projectId == query.projectId);

  ReportTotals _totals(
    Iterable<BookkeepingEntry> source,
    Currency currency,
    List<LedgerTransfer> transfers,
  ) {
    final accumulator = _Accumulator(currency);
    for (final entry in source) {
      accumulator.add(
        entry,
        fx.convert(
          amount: entry.amount,
          target: currency,
          businessDate: entry.businessDate,
          availableTransfers: transfers,
        ),
      );
    }
    return accumulator.build();
  }

  List<ReportBreakdown> _breakdowns<T>(
    List<BookkeepingEntry> source,
    List<T> references,
    LocalId Function(BookkeepingEntry) keyOf,
    Currency currency,
    List<LedgerTransfer> transfers,
  ) {
    LocalId idOf(T value) => switch (value) {
      Account(:final id) => id,
      Category(:final id) => id,
      _ => throw StateError('Unsupported report reference'),
    };
    String nameOf(T value) => switch (value) {
      Account(:final name) => name,
      Category(:final name) => name,
      _ => throw StateError('Unsupported report reference'),
    };
    final rows = <ReportBreakdown>[];
    for (final reference in references) {
      final id = idOf(reference);
      final matching = source.where((entry) => keyOf(entry) == id).toList();
      if (matching.isEmpty) continue;
      rows.add(
        ReportBreakdown(
          id: id,
          name: nameOf(reference),
          totals: _totals(matching, currency, transfers),
        ),
      );
    }
    rows.sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(rows);
  }

  List<TrendPoint> _trend(
    List<BookkeepingEntry> entries,
    Currency currency,
    List<LedgerTransfer> transfers,
  ) {
    final dates = entries.map((entry) => entry.businessDate).toSet().toList()
      ..sort();
    return List.unmodifiable([
      for (final date in dates)
        TrendPoint(
          date: date,
          totals: _totals(
            entries.where((entry) => entry.businessDate == date),
            currency,
            transfers,
          ),
        ),
    ]);
  }

  ComparisonMetric _comparison(
    Money current,
    Money previous,
    ReportTotals currentTotals,
    ReportTotals previousTotals,
  ) => ComparisonMetric(
    current: current,
    previous: previous,
    previousHasActivity: previousTotals.hasActivity,
    isComplete:
        currentTotals.completeness.isComplete &&
        previousTotals.completeness.isComplete,
  );

  Future<Result<_ReportData>> _load(LocalId profileId) async {
    final accountResult = await accounts.list(profileId, includeArchived: true);
    if (accountResult is Failure<List<Account>>)
      return Failure(accountResult.code);
    final categoryResult = await categories.list(
      profileId,
      includeArchived: true,
    );
    if (categoryResult is Failure<List<Category>>)
      return Failure(categoryResult.code);
    final entryResult = await entries.history(profileId);
    if (entryResult is Failure<List<BookkeepingEntry>>)
      return Failure(entryResult.code);
    final transferResult = await transfers.history(profileId);
    if (transferResult is Failure<List<LedgerTransfer>>)
      return Failure(transferResult.code);
    return Success(
      _ReportData(
        accounts: (accountResult as Success<List<Account>>).value,
        categories: (categoryResult as Success<List<Category>>).value,
        entries: (entryResult as Success<List<BookkeepingEntry>>).value,
        transfers: (transferResult as Success<List<LedgerTransfer>>).value,
      ),
    );
  }
}

final class _ReportData {
  const _ReportData({
    required this.accounts,
    required this.categories,
    required this.entries,
    required this.transfers,
  });
  final List<Account> accounts;
  final List<Category> categories;
  final List<BookkeepingEntry> entries;
  final List<LedgerTransfer> transfers;
}
