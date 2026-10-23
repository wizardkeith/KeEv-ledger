import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';

/// Calendar day without an implicit device timezone or UTC instant conversion.
final class BusinessDate implements Comparable<BusinessDate> {
  BusinessDate(this.value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw FormatException('Expected yyyy-MM-dd', value);
    }
    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final day = int.parse(value.substring(8, 10));
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw FormatException('Invalid calendar date', value);
    }
  }
  final String value;
  @override
  int compareTo(BusinessDate other) => value.compareTo(other.value);
  @override
  bool operator ==(Object other) =>
      other is BusinessDate && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

enum AccountKind { cash, bank, creditCard, eWallet, other }

enum EntryKind { income, expense }

void _validateName(String name) {
  if (name != name.trim() || name.isEmpty || name.length > 120) {
    throw ArgumentError(
      'Name must be trimmed and between 1 and 120 characters',
    );
  }
}

void _validateTimes(DateTime created, DateTime updated) {
  if (!created.isUtc || !updated.isUtc || updated.isBefore(created)) {
    throw ArgumentError('Technical timestamps must be ordered UTC instants');
  }
}

final class Account {
  Account({
    required this.id,
    required this.profileId,
    required this.name,
    required this.kind,
    required this.currency,
    required this.openingBalance,
    required this.openingDate,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) {
    _validateName(name);
    _validateTimes(createdAtUtc, updatedAtUtc);
    if (currency != openingBalance.currency)
      throw ArgumentError('Opening balance currency differs');
  }
  final LocalId id, profileId;
  final String name;
  final AccountKind kind;
  final Currency currency;
  final Money openingBalance;
  final BusinessDate openingDate;
  final bool isArchived;
  final DateTime createdAtUtc, updatedAtUtc;
}

final class Category {
  Category({
    required this.id,
    required this.profileId,
    required this.name,
    required this.kind,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) {
    _validateName(name);
    _validateTimes(createdAtUtc, updatedAtUtc);
  }
  final LocalId id, profileId;
  final String name;
  final EntryKind kind;
  final bool isArchived;
  final DateTime createdAtUtc, updatedAtUtc;
}

final class BookkeepingEntry {
  BookkeepingEntry({
    required this.id,
    required this.profileId,
    required this.accountId,
    required this.categoryId,
    this.projectId,
    required this.kind,
    required this.amount,
    required this.businessDate,
    this.note,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  }) {
    if (amount.minorUnits <= 0)
      throw ArgumentError('Entry amount must be positive');
    _validateTimes(createdAtUtc, updatedAtUtc);
    if (deletedAtUtc != null &&
        (!deletedAtUtc!.isUtc || deletedAtUtc!.isBefore(createdAtUtc))) {
      throw ArgumentError('Deletion timestamp must be UTC and after creation');
    }
  }
  final LocalId id, profileId, accountId, categoryId;
  final LocalId? projectId;
  final EntryKind kind;
  final Money amount;
  final BusinessDate businessDate;
  final String? note;
  final DateTime createdAtUtc, updatedAtUtc;
  final DateTime? deletedAtUtc;
}

/// No generated Drift classes cross this boundary.
abstract interface class AccountRepository {
  Future<Result<Account>> create(Account account);
  Future<Result<Account?>> get(LocalId profileId, LocalId accountId);
  Future<Result<List<Account>>> list(
    LocalId profileId, {
    bool includeArchived = false,
  });
  Future<Result<Account>> archive(
    LocalId profileId,
    LocalId accountId,
    DateTime nowUtc,
  );
}

abstract interface class CategoryRepository {
  Future<Result<Category>> create(Category category);
  Future<Result<Category?>> get(LocalId profileId, LocalId categoryId);
  Future<Result<List<Category>>> list(
    LocalId profileId, {
    EntryKind? kind,
    bool includeArchived = false,
  });
  Future<Result<Category>> archive(
    LocalId profileId,
    LocalId categoryId,
    DateTime nowUtc,
  );
}

abstract interface class EntryRepository {
  Future<Result<BookkeepingEntry>> create(BookkeepingEntry entry);
  Future<Result<BookkeepingEntry?>> get(LocalId profileId, LocalId entryId);
  Future<Result<List<BookkeepingEntry>>> history(
    LocalId profileId, {
    LocalId? accountId,
  });
  Future<Result<BookkeepingEntry>> delete(
    LocalId profileId,
    LocalId entryId,
    DateTime nowUtc,
  );
  Future<Result<BookkeepingEntry>> assignProject(
    LocalId profileId,
    LocalId entryId,
    LocalId? projectId,
    DateTime nowUtc,
  );
}
