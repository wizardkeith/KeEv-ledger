import '../../../core/exact_fx_rate.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import 'bookkeeping.dart';

/// A transfer is one business event with two authoritative amounts.
final class LedgerTransfer {
  LedgerTransfer({
    required this.id,
    required this.profileId,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.sent,
    required this.received,
    required this.businessDate,
    this.note,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  }) {
    if (sourceAccountId == destinationAccountId)
      throw ArgumentError('Transfer requires two accounts');
    if (sent.minorUnits <= 0 || received.minorUnits <= 0)
      throw ArgumentError('Transfer amounts must be positive');
    if (sent.currency == received.currency && sent != received) {
      throw ArgumentError('Same-currency transfer amounts must match');
    }
    if (!createdAtUtc.isUtc ||
        !updatedAtUtc.isUtc ||
        updatedAtUtc.isBefore(createdAtUtc) ||
        (deletedAtUtc != null &&
            (!deletedAtUtc!.isUtc || deletedAtUtc!.isBefore(createdAtUtc)))) {
      throw ArgumentError('Transfer timestamps must be ordered UTC instants');
    }
  }
  final LocalId id, profileId, sourceAccountId, destinationAccountId;
  final Money sent, received;
  final BusinessDate businessDate;
  final String? note;
  final DateTime createdAtUtc, updatedAtUtc;
  final DateTime? deletedAtUtc;

  /// Destination major units per one source major unit; not persisted or rounded.
  ExactFxRate? get impliedSourceToDestinationRate =>
      sent.currency == received.currency
      ? null
      : ExactFxRate.majorRatio(
          source: sent.currency,
          target: received.currency,
          numerator:
              BigInt.from(received.minorUnits) *
              BigInt.from(10).pow(sent.currency.minorDigits),
          denominator:
              BigInt.from(sent.minorUnits) *
              BigInt.from(10).pow(received.currency.minorDigits),
        );
}

abstract interface class TransferRepository {
  Future<Result<LedgerTransfer>> create(LedgerTransfer transfer);
  Future<Result<List<LedgerTransfer>>> history(
    LocalId profileId, {
    LocalId? accountId,
  });
  Future<Result<LedgerTransfer>> delete(
    LocalId profileId,
    LocalId transferId,
    DateTime nowUtc,
  );
}
