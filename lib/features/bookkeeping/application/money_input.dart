import '../../../core/currency.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';

/// Strict decimal input: no binary float and no silent precision loss.
final class MoneyInput {
  const MoneyInput._();

  static Result<Money> parsePositive(String input, Currency currency) =>
      _parse(input, currency, allowZero: false);

  static Result<Money> parseNonNegative(String input, Currency currency) =>
      _parse(input, currency, allowZero: true);

  static Result<Money> _parse(
    String input,
    Currency currency, {
    required bool allowZero,
  }) {
    final value = input.trim();
    final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(value);
    if (match == null) return const Failure(FailureCode.invalidAmount);
    final fraction = match.group(2) ?? '';
    if (fraction.length > currency.minorDigits) {
      return const Failure(FailureCode.invalidAmount);
    }
    final scale = BigInt.from(10).pow(currency.minorDigits);
    final units =
        BigInt.parse(match.group(1)!) * scale +
        BigInt.parse(
          fraction.padRight(currency.minorDigits, '0').isEmpty
              ? '0'
              : fraction.padRight(currency.minorDigits, '0'),
        );
    if (units < BigInt.zero ||
        (!allowZero && units == BigInt.zero) ||
        units > BigInt.from(Money.maxMinorUnits)) {
      return const Failure(FailureCode.invalidAmount);
    }
    return Success(Money.fromExactMinorUnits(currency, units));
  }
}
