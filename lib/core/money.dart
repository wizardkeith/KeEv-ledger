import 'currency.dart';

/// SQLite signed 64-bit integer range with -2^63 reserved for safe negation.
final class Money implements Comparable<Money> {
  Money.fromMinorUnits(this.currency, this.minorUnits) {
    if (minorUnits < -maxMinorUnits || minorUnits > maxMinorUnits) {
      throw RangeError('Money minor units exceed the supported SQLite range');
    }
  }

  static const maxMinorUnits = 9223372036854775807;
  final Currency currency;
  final int minorUnits;

  factory Money.zero(Currency currency) => Money.fromMinorUnits(currency, 0);

  static Money fromExactMinorUnits(Currency currency, BigInt value) {
    final limit = BigInt.from(maxMinorUnits);
    if (value < -limit || value > limit) {
      throw RangeError('Money minor units exceed the supported SQLite range');
    }
    return Money.fromMinorUnits(currency, value.toInt());
  }

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Money currencies differ; use an explicit FX rate');
    }
  }

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return fromExactMinorUnits(
      currency,
      BigInt.from(minorUnits) + BigInt.from(other.minorUnits),
    );
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return fromExactMinorUnits(
      currency,
      BigInt.from(minorUnits) - BigInt.from(other.minorUnits),
    );
  }

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.currency == currency &&
      other.minorUnits == minorUnits;

  @override
  int get hashCode => Object.hash(currency, minorUnits);
}
