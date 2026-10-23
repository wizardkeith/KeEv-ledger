import '../../../core/currency.dart';
import '../../../core/exact_fx_rate.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import 'bookkeeping.dart';
import 'transfer.dart';

enum FxResolution {
  sameCurrency,
  exactZero,
  transferImplied,
  missing,
  ambiguous,
}

final class FxIssue {
  const FxIssue({
    required this.source,
    required this.target,
    required this.businessDate,
    required this.resolution,
  });

  final Currency source, target;
  final BusinessDate businessDate;
  final FxResolution resolution;

  @override
  bool operator ==(Object other) =>
      other is FxIssue &&
      other.source == source &&
      other.target == target &&
      other.businessDate == businessDate &&
      other.resolution == resolution;

  @override
  int get hashCode => Object.hash(source, target, businessDate, resolution);
}

final class FxProvenance {
  const FxProvenance({
    required this.source,
    required this.target,
    required this.businessDate,
    required this.transferIds,
  });

  final Currency source, target;
  final BusinessDate businessDate;
  final Set<LocalId> transferIds;
}

final class RecordedFxConversion {
  const RecordedFxConversion._({
    required this.resolution,
    this.money,
    this.issue,
    this.provenance,
  });

  final FxResolution resolution;
  final Money? money;
  final FxIssue? issue;
  final FxProvenance? provenance;
  bool get isComplete => money != null;
}

/// Resolves only exact rates evidenced by recorded same-day transfers.
/// Identical rates may have several source transfer IDs; conflicting rates are
/// deliberately ambiguous instead of selecting one silently.
final class RecordedFxConverter {
  const RecordedFxConverter();

  RecordedFxConversion convert({
    required Money amount,
    required Currency target,
    required BusinessDate businessDate,
    required List<LedgerTransfer> availableTransfers,
  }) {
    if (amount.currency == target) {
      return RecordedFxConversion._(
        resolution: FxResolution.sameCurrency,
        money: amount,
      );
    }
    if (amount.minorUnits == 0) {
      return RecordedFxConversion._(
        resolution: FxResolution.exactZero,
        money: Money.zero(target),
      );
    }
    final candidates = <(ExactFxRate, LocalId)>[];
    for (final transfer in availableTransfers) {
      if (transfer.businessDate != businessDate ||
          transfer.sent.currency == transfer.received.currency) {
        continue;
      }
      if (transfer.sent.currency == amount.currency &&
          transfer.received.currency == target) {
        candidates.add((transfer.impliedSourceToDestinationRate!, transfer.id));
      } else if (transfer.received.currency == amount.currency &&
          transfer.sent.currency == target) {
        final forward = transfer.impliedSourceToDestinationRate!;
        candidates.add((
          ExactFxRate.majorRatio(
            source: amount.currency,
            target: target,
            numerator: forward.denominator,
            denominator: forward.numerator,
          ),
          transfer.id,
        ));
      }
    }
    if (candidates.isEmpty) {
      return RecordedFxConversion._(
        resolution: FxResolution.missing,
        issue: FxIssue(
          source: amount.currency,
          target: target,
          businessDate: businessDate,
          resolution: FxResolution.missing,
        ),
      );
    }
    final first = candidates.first.$1;
    if (candidates.any(
      (candidate) =>
          candidate.$1.numerator != first.numerator ||
          candidate.$1.denominator != first.denominator,
    )) {
      return RecordedFxConversion._(
        resolution: FxResolution.ambiguous,
        issue: FxIssue(
          source: amount.currency,
          target: target,
          businessDate: businessDate,
          resolution: FxResolution.ambiguous,
        ),
      );
    }
    return RecordedFxConversion._(
      resolution: FxResolution.transferImplied,
      money: first.convert(amount),
      provenance: FxProvenance(
        source: amount.currency,
        target: target,
        businessDate: businessDate,
        transferIds: Set.unmodifiable(
          candidates.map((candidate) => candidate.$2),
        ),
      ),
    );
  }
}
