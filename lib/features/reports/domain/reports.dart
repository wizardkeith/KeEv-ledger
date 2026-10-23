import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../bookkeeping/domain/recorded_fx.dart';

final class ReportRange {
  ReportRange({required this.start, required this.end}) {
    if (start.compareTo(end) > 0) {
      throw ArgumentError('Report start must not be after end');
    }
  }

  final BusinessDate start, end;

  bool contains(BusinessDate date) =>
      date.compareTo(start) >= 0 && date.compareTo(end) <= 0;

  ReportRange get previous {
    final startDate = DateTime.parse('${start.value}T00:00:00Z');
    final endDate = DateTime.parse('${end.value}T00:00:00Z');
    final days = endDate.difference(startDate).inDays + 1;
    final previousEnd = startDate.subtract(const Duration(days: 1));
    final previousStart = previousEnd.subtract(Duration(days: days - 1));
    String value(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return ReportRange(
      start: BusinessDate(value(previousStart)),
      end: BusinessDate(value(previousEnd)),
    );
  }
}

final class ReportQuery {
  const ReportQuery({
    required this.profileId,
    required this.range,
    required this.currency,
    this.categoryId,
    this.accountId,
    this.projectId,
  });

  final LocalId profileId;
  final ReportRange range;
  final Currency currency;
  final LocalId? categoryId, accountId, projectId;
}

final class ReportCompleteness {
  const ReportCompleteness({required this.issues, required this.provenance});

  final Set<FxIssue> issues;
  final List<FxProvenance> provenance;
  bool get isComplete => issues.isEmpty;
  Set<String> get missingCurrencies =>
      Set.unmodifiable(issues.map((issue) => issue.source.code));
}

final class ReportTotals {
  const ReportTotals({
    required this.income,
    required this.expense,
    required this.net,
    required this.hasActivity,
    required this.completeness,
  });

  final Money income, expense, net;
  final bool hasActivity;
  final ReportCompleteness completeness;
}

final class ReportBreakdown {
  const ReportBreakdown({
    required this.id,
    required this.name,
    required this.totals,
  });

  final LocalId id;
  final String name;
  final ReportTotals totals;
}

final class TrendPoint {
  const TrendPoint({required this.date, required this.totals});
  final BusinessDate date;
  final ReportTotals totals;
}

final class ComparisonMetric {
  const ComparisonMetric({
    required this.current,
    required this.previous,
    required this.previousHasActivity,
    required this.isComplete,
  });

  final Money current, previous;
  final bool previousHasActivity, isComplete;

  /// Null means unavailable: no prior activity, prior zero, or incomplete data.
  double? get percentageChange =>
      !isComplete || !previousHasActivity || previous.minorUnits == 0
      ? null
      : (current.minorUnits - previous.minorUnits) /
            previous.minorUnits.abs() *
            100;
}

final class PeriodComparison {
  const PeriodComparison({
    required this.range,
    required this.income,
    required this.expense,
    required this.net,
  });
  final ReportRange range;
  final ComparisonMetric income, expense, net;
}

final class IncomeExpenseReport {
  const IncomeExpenseReport({
    required this.query,
    required this.totals,
    required this.categories,
    required this.accounts,
    required this.trend,
    required this.comparison,
  });

  final ReportQuery query;
  final ReportTotals totals;
  final List<ReportBreakdown> categories, accounts;
  final List<TrendPoint> trend;
  final PeriodComparison comparison;
}

final class AccountAsOfRow {
  const AccountAsOfRow({
    required this.account,
    required this.nativeBalance,
    required this.reportedBalance,
    required this.completeness,
  });

  final Account account;
  final Money nativeBalance;
  final Money? reportedBalance;
  final ReportCompleteness completeness;
}

final class AssetsLiabilitiesOverview {
  const AssetsLiabilitiesOverview({
    required this.profileId,
    required this.asOf,
    required this.currency,
    required this.assets,
    required this.liabilities,
    required this.net,
    required this.accounts,
    required this.completeness,
  });

  final LocalId profileId;
  final BusinessDate asOf;
  final Currency currency;
  final Money assets, liabilities, net;
  final List<AccountAsOfRow> accounts;
  final ReportCompleteness completeness;
}

enum HistoryEventFilter { all, income, expense, transfer }

final class TransactionHistoryQuery {
  const TransactionHistoryQuery({
    required this.profileId,
    this.range,
    this.event = HistoryEventFilter.all,
    this.accountId,
    this.categoryId,
    this.projectId,
    this.text,
  });

  final LocalId profileId;
  final ReportRange? range;
  final HistoryEventFilter event;
  final LocalId? accountId, categoryId, projectId;
  final String? text;
}
