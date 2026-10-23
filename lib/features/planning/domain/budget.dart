import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';

final class BudgetMonth implements Comparable<BudgetMonth> {
  BudgetMonth(this.value) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
    if (match == null) throw FormatException('Expected yyyy-MM', value);
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) throw FormatException('Invalid month', value);
  }

  factory BudgetMonth.fromDate(DateTime date) => BudgetMonth(
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}',
  );

  final String value;
  String get firstDay => '$value-01';
  String get nextMonthFirstDay {
    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final next = month == 12
        ? DateTime.utc(year + 1)
        : DateTime.utc(year, month + 1);
    return '${next.year.toString().padLeft(4, '0')}-${next.month.toString().padLeft(2, '0')}-01';
  }

  bool contains(String businessDate) =>
      businessDate.compareTo(firstDay) >= 0 &&
      businessDate.compareTo(nextMonthFirstDay) < 0;

  @override
  int compareTo(BudgetMonth other) => value.compareTo(other.value);
  @override
  bool operator ==(Object other) =>
      other is BudgetMonth && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

final class Budget {
  Budget({
    required this.id,
    required this.profileId,
    required this.name,
    required this.amount,
    required this.month,
    this.categoryId,
    this.warningThresholdPercent = 80,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) {
    if (name != name.trim() || name.isEmpty || name.length > 120) {
      throw ArgumentError('Budget name must be trimmed and 1–120 characters');
    }
    if (amount.minorUnits < 0) throw ArgumentError('Budget cannot be negative');
    if (warningThresholdPercent < 1 || warningThresholdPercent > 100) {
      throw ArgumentError('Warning threshold must be 1–100');
    }
    if (!createdAtUtc.isUtc ||
        !updatedAtUtc.isUtc ||
        updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError('Budget timestamps must be ordered UTC instants');
    }
  }

  final LocalId id, profileId;
  final String name;
  final Money amount;
  Currency get currency => amount.currency;
  final BudgetMonth month;
  final LocalId? categoryId;
  final int warningThresholdPercent;
  final bool isArchived;
  final DateTime createdAtUtc, updatedAtUtc;
}

final class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.isOverBudget,
    required this.isComplete,
    required this.missingCurrencies,
  });

  final Money budget, spent, remaining;
  final bool isOverBudget, isComplete;
  final Set<String> missingCurrencies;

  /// Null deliberately represents a zero budget; unknown is never encoded as 0.
  double? get fraction =>
      budget.minorUnits == 0 ? null : spent.minorUnits / budget.minorUnits;
}

abstract interface class BudgetRepository {
  Future<Result<Budget>> create(Budget budget);
  Future<Result<List<Budget>>> list(
    LocalId profileId, {
    bool includeArchived = false,
  });
  Future<Result<Budget>> archive(
    LocalId profileId,
    LocalId budgetId,
    DateTime nowUtc,
  );
}
