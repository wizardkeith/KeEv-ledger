import '../../../core/clock.dart';
import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../local_profile/domain/local_profile.dart';
import '../domain/bookkeeping.dart';
import '../domain/transfer.dart';
import '../domain/history_item.dart';

export '../domain/history_item.dart';

/// Offline application boundary; callers never need SQLite or a cloud identity.
final class BookkeepingService {
  BookkeepingService({
    required this.profiles,
    required this.accounts,
    required this.categories,
    required this.entries,
    required this.transfers,
    required this.ids,
    required this.clock,
  });

  final LocalProfileRepository profiles;
  final AccountRepository accounts;
  final CategoryRepository categories;
  final EntryRepository entries;
  final TransferRepository transfers;
  final IdGenerator ids;
  final Clock clock;

  DateTime _now() {
    final now = clock.nowUtc();
    if (!now.isUtc) throw StateError('Clock must supply UTC instants');
    return now;
  }

  Future<Failure<T>?> _checkProfile<T>(LocalId profileId) async {
    final result = await profiles.read();
    if (result is Failure<LocalProfile?>) return Failure(result.code);
    if ((result as Success<LocalProfile?>).value?.id != profileId) {
      return const Failure(FailureCode.profileNotFound);
    }
    return null;
  }

  Future<Result<Account>> createAccount({
    required LocalId profileId,
    required String name,
    required AccountKind kind,
    required Currency currency,
    required Money openingBalance,
    required BusinessDate openingDate,
  }) async {
    if (openingBalance.currency != currency)
      return const Failure(FailureCode.currencyMismatch);
    final failure = await _checkProfile<Account>(profileId);
    if (failure != null) return failure;
    final now = _now();
    return accounts.create(
      Account(
        id: ids.generate(),
        profileId: profileId,
        name: name,
        kind: kind,
        currency: currency,
        openingBalance: openingBalance,
        openingDate: openingDate,
        isArchived: false,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<Result<Category>> createCategory({
    required LocalId profileId,
    required String name,
    required EntryKind kind,
  }) async {
    final failure = await _checkProfile<Category>(profileId);
    if (failure != null) return failure;
    final now = _now();
    return categories.create(
      Category(
        id: ids.generate(),
        profileId: profileId,
        name: name,
        kind: kind,
        isArchived: false,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<Result<BookkeepingEntry>> recordIncome({
    required LocalId profileId,
    required LocalId accountId,
    required LocalId categoryId,
    required Money amount,
    required BusinessDate businessDate,
    String? note,
    LocalId? projectId,
  }) => _record(
    profileId: profileId,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    businessDate: businessDate,
    note: note,
    projectId: projectId,
    kind: EntryKind.income,
  );

  Future<Result<BookkeepingEntry>> recordExpense({
    required LocalId profileId,
    required LocalId accountId,
    required LocalId categoryId,
    required Money amount,
    required BusinessDate businessDate,
    String? note,
    LocalId? projectId,
  }) => _record(
    profileId: profileId,
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    businessDate: businessDate,
    note: note,
    projectId: projectId,
    kind: EntryKind.expense,
  );

  Future<Result<BookkeepingEntry>> _record({
    required LocalId profileId,
    required LocalId accountId,
    required LocalId categoryId,
    required Money amount,
    required BusinessDate businessDate,
    required EntryKind kind,
    String? note,
    LocalId? projectId,
  }) async {
    if (amount.minorUnits <= 0)
      throw ArgumentError.value(
        amount.minorUnits,
        'amount',
        'Must be positive',
      );
    final failure = await _checkProfile<BookkeepingEntry>(profileId);
    if (failure != null) return failure;
    final now = _now();
    return entries.create(
      BookkeepingEntry(
        id: ids.generate(),
        profileId: profileId,
        accountId: accountId,
        categoryId: categoryId,
        kind: kind,
        amount: amount,
        businessDate: businessDate,
        note: note,
        projectId: projectId,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<Result<List<Account>>> listAccounts(LocalId profileId) =>
      accounts.list(profileId);
  Future<Result<List<Category>>> listCategories(
    LocalId profileId, {
    EntryKind? kind,
  }) => categories.list(profileId, kind: kind);
  Future<Result<List<BookkeepingEntry>>> history(
    LocalId profileId, {
    LocalId? accountId,
  }) => entries.history(profileId, accountId: accountId);

  Future<Result<Money>> accountBalance(
    LocalId profileId,
    LocalId accountId,
  ) async {
    final accountResult = await accounts.get(profileId, accountId);
    if (accountResult is Failure<Account?>) return Failure(accountResult.code);
    final account = (accountResult as Success<Account?>).value;
    if (account == null) return const Failure(FailureCode.accountNotFound);
    final entryResult = await entries.history(profileId, accountId: accountId);
    if (entryResult is Failure<List<BookkeepingEntry>>)
      return Failure(entryResult.code);
    var total = BigInt.from(account.openingBalance.minorUnits);
    for (final entry
        in (entryResult as Success<List<BookkeepingEntry>>).value) {
      if (entry.amount.currency != account.currency) {
        throw StateError('Persisted entry has inconsistent account currency');
      }
      final units = BigInt.from(entry.amount.minorUnits);
      total = entry.kind == EntryKind.income ? total + units : total - units;
    }
    final transferResult = await transfers.history(
      profileId,
      accountId: accountId,
    );
    if (transferResult is Failure<List<LedgerTransfer>>)
      return Failure(transferResult.code);
    for (final transfer
        in (transferResult as Success<List<LedgerTransfer>>).value) {
      if (transfer.sourceAccountId == accountId) {
        if (transfer.sent.currency != account.currency)
          throw StateError('Invalid transfer source currency');
        total -= BigInt.from(transfer.sent.minorUnits);
      } else {
        if (transfer.received.currency != account.currency)
          throw StateError('Invalid transfer destination currency');
        total += BigInt.from(transfer.received.minorUnits);
      }
    }
    return Success(Money.fromExactMinorUnits(account.currency, total));
  }

  Future<Result<LedgerTransfer>> transfer({
    required LocalId profileId,
    required LocalId sourceAccountId,
    required LocalId destinationAccountId,
    required Money sent,
    Money? received,
    required BusinessDate businessDate,
    String? note,
  }) async {
    if (sourceAccountId == destinationAccountId)
      return const Failure(FailureCode.sameAccount);
    if (sent.minorUnits <= 0 ||
        (received != null && received.minorUnits <= 0)) {
      return const Failure(FailureCode.invalidAmount);
    }
    final failure = await _checkProfile<LedgerTransfer>(profileId);
    if (failure != null) return failure;
    final destinationResult = await accounts.get(
      profileId,
      destinationAccountId,
    );
    if (destinationResult is Failure<Account?>)
      return Failure(destinationResult.code);
    final destination = (destinationResult as Success<Account?>).value;
    if (destination == null) return const Failure(FailureCode.accountNotFound);
    if (destination.isArchived)
      return const Failure(FailureCode.accountArchived);
    if (sent.currency == destination.currency) {
      if (received != null && received != sent)
        return const Failure(FailureCode.transferAmountMismatch);
      received = sent;
    } else {
      if (received == null)
        return const Failure(FailureCode.receivedAmountRequired);
      if (received.currency != destination.currency)
        return const Failure(FailureCode.currencyMismatch);
    }
    final now = _now();
    return transfers.create(
      LedgerTransfer(
        id: ids.generate(),
        profileId: profileId,
        sourceAccountId: sourceAccountId,
        destinationAccountId: destinationAccountId,
        sent: sent,
        received: received,
        businessDate: businessDate,
        note: note,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<Result<List<LedgerHistoryItem>>> historyEvents(
    LocalId profileId,
  ) async {
    final entriesResult = await entries.history(profileId);
    if (entriesResult is Failure<List<BookkeepingEntry>>)
      return Failure(entriesResult.code);
    final transfersResult = await transfers.history(profileId);
    if (transfersResult is Failure<List<LedgerTransfer>>)
      return Failure(transfersResult.code);
    final events =
        <LedgerHistoryItem>[
          for (final entry
              in (entriesResult as Success<List<BookkeepingEntry>>).value)
            LedgerHistoryItem.entry(entry),
          for (final transfer
              in (transfersResult as Success<List<LedgerTransfer>>).value)
            LedgerHistoryItem.transfer(transfer),
        ]..sort((a, b) {
          final date = b.businessDate.compareTo(a.businessDate);
          return date != 0 ? date : b.id.value.compareTo(a.id.value);
        });
    return Success(events);
  }

  Future<Result<LedgerTransfer>> deleteTransfer(
    LocalId profileId,
    LocalId id,
  ) => transfers.delete(profileId, id, _now());

  Future<Result<Account>> archiveAccount(LocalId profileId, LocalId id) =>
      accounts.archive(profileId, id, _now());
  Future<Result<Category>> archiveCategory(LocalId profileId, LocalId id) =>
      categories.archive(profileId, id, _now());
  Future<Result<BookkeepingEntry>> deleteEntry(LocalId profileId, LocalId id) =>
      entries.delete(profileId, id, _now());
}
