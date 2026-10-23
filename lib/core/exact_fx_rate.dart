import 'currency.dart';
import 'money.dart';

/// Round a signed rational to the nearest integer, breaking ties toward even.
BigInt roundHalfEven(BigInt numerator, BigInt positiveDenominator) {
  if (positiveDenominator <= BigInt.zero) {
    throw ArgumentError.value(positiveDenominator, 'positiveDenominator');
  }
  final magnitude = numerator.abs();
  var quotient = magnitude ~/ positiveDenominator;
  final twiceRemainder = (magnitude % positiveDenominator) * BigInt.two;
  if (twiceRemainder > positiveDenominator ||
      (twiceRemainder == positiveDenominator && quotient.isOdd)) {
    quotient += BigInt.one;
  }
  return numerator.isNegative ? -quotient : quotient;
}

/// numerator / denominator is TARGET major units per SOURCE major unit.
/// No rounding occurs before the final target-minor-unit result.
final class ExactFxRate {
  ExactFxRate._(this.source, this.target, this.numerator, this.denominator);

  factory ExactFxRate.majorRatio({
    required Currency source,
    required Currency target,
    required BigInt numerator,
    required BigInt denominator,
  }) {
    if (source == target)
      throw ArgumentError('FX requires distinct currencies');
    if (numerator <= BigInt.zero || denominator <= BigInt.zero) {
      throw ArgumentError('FX numerator and denominator must be positive');
    }
    final gcd = numerator.gcd(denominator);
    return ExactFxRate._(source, target, numerator ~/ gcd, denominator ~/ gcd);
  }

  final Currency source;
  final Currency target;
  final BigInt numerator;
  final BigInt denominator;

  Money convert(Money amount) {
    if (amount.currency != source) {
      throw ArgumentError('FX source does not match the money currency');
    }
    final numeratorInTargetMinorUnits =
        BigInt.from(amount.minorUnits) *
        numerator *
        BigInt.from(10).pow(target.minorDigits);
    final denominatorInSourceMinorUnits =
        denominator * BigInt.from(10).pow(source.minorDigits);
    return Money.fromExactMinorUnits(
      target,
      roundHalfEven(numeratorInTargetMinorUnits, denominatorInSourceMinorUnits),
    );
  }
}
