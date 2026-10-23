import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/clock.dart';
import 'package:ledger/core/currency.dart';
import 'package:ledger/core/exact_fx_rate.dart';
import 'package:ledger/core/local_id.dart';
import 'package:ledger/core/money.dart';

final class FixedClock implements Clock {
  FixedClock(this.instant);
  final DateTime instant;
  @override
  DateTime nowUtc() => instant;
}

void main() {
  test('Currency precision and strict codes', () {
    expect(Currency.fromCode('JPY').minorDigits, 0);
    for (final code in ['HKD', 'USD', 'EUR', 'GBP', 'THB', 'CNY']) {
      expect(Currency.fromCode(code).minorDigits, 2);
    }
    expect(() => Currency.fromCode('hkd'), throwsFormatException);
    expect(() => Currency.fromCode('ABC'), throwsFormatException);
    expect(Currency.fromCode('HKD'), Currency.hkd);
  });

  test('Money stores exact minor units, zero and signed operations', () {
    final amount = Money.fromMinorUnits(Currency.hkd, 12345);
    expect(amount + Money.zero(Currency.hkd), amount);
    expect(
      amount - Money.fromMinorUnits(Currency.hkd, 45),
      Money.fromMinorUnits(Currency.hkd, 12300),
    );
    expect(Money.fromMinorUnits(Currency.jpy, 500).minorUnits, 500);
    expect(Money.fromMinorUnits(Currency.hkd, -100).compareTo(amount), -1);
    expect(amount.hashCode, Money.fromMinorUnits(Currency.hkd, 12345).hashCode);
  });

  test('Mixed currencies cannot add, subtract or compare', () {
    final hkd = Money.fromMinorUnits(Currency.hkd, 100);
    final usd = Money.fromMinorUnits(Currency.usd, 100);
    expect(hkd, isNot(usd));
    expect(() => hkd + usd, throwsArgumentError);
    expect(() => hkd - usd, throwsArgumentError);
    expect(() => hkd.compareTo(usd), throwsArgumentError);
  });

  test('BigInt intermediate arithmetic rejects SQLite integer overflow', () {
    final high = Money.fromMinorUnits(Currency.hkd, Money.maxMinorUnits);
    expect(
      high + Money.fromMinorUnits(Currency.hkd, -1),
      Money.fromMinorUnits(Currency.hkd, Money.maxMinorUnits - 1),
    );
    expect(
      () => high + Money.fromMinorUnits(Currency.hkd, 1),
      throwsRangeError,
    );
    final low = Money.fromMinorUnits(Currency.hkd, -Money.maxMinorUnits);
    expect(() => low - Money.fromMinorUnits(Currency.hkd, 1), throwsRangeError);
    expect(
      () => Money.fromExactMinorUnits(
        Currency.hkd,
        BigInt.from(Money.maxMinorUnits) + BigInt.one,
      ),
      throwsRangeError,
    );
  });

  test('HALF-EVEN works symmetrically at ties, non-ties and zero', () {
    const halves = [
      (1, 0),
      (3, 2),
      (5, 2),
      (7, 4),
      (-1, 0),
      (-3, -2),
      (-5, -2),
      (-7, -4),
    ];
    for (final (numerator, expected) in halves) {
      expect(
        roundHalfEven(BigInt.from(numerator), BigInt.two),
        BigInt.from(expected),
      );
    }
    expect(roundHalfEven(BigInt.zero, BigInt.two), BigInt.zero);
    expect(roundHalfEven(BigInt.from(23), BigInt.from(10)), BigInt.two);
    expect(() => roundHalfEven(BigInt.one, BigInt.zero), throwsArgumentError);
  });

  test('FX major ratio stays exact; rounds once into target minor units', () {
    final rate = ExactFxRate.majorRatio(
      source: Currency.hkd,
      target: Currency.jpy,
      numerator: BigInt.from(40),
      denominator: BigInt.from(3),
    );
    expect(rate.numerator, BigInt.from(40));
    expect(rate.denominator, BigInt.from(3));
    // HKD 0.15 × (40/3) = JPY 2, no intermediate decimal rounding.
    expect(
      rate.convert(Money.fromMinorUnits(Currency.hkd, 15)),
      Money.fromMinorUnits(Currency.jpy, 2),
    );
    final halves = ExactFxRate.majorRatio(
      source: Currency.jpy,
      target: Currency.usd,
      numerator: BigInt.one,
      denominator: BigInt.from(200),
    );
    expect(halves.convert(Money.fromMinorUnits(Currency.jpy, 1)).minorUnits, 0);
    expect(halves.convert(Money.fromMinorUnits(Currency.jpy, 3)).minorUnits, 2);
    expect(
      halves.convert(Money.fromMinorUnits(Currency.jpy, -3)).minorUnits,
      -2,
    );
    expect(() => halves.convert(Money.zero(Currency.hkd)), throwsArgumentError);
  });

  test('FX normalization, validation and overflow', () {
    final rate = ExactFxRate.majorRatio(
      source: Currency.usd,
      target: Currency.hkd,
      numerator: BigInt.from(156),
      denominator: BigInt.from(20),
    );
    expect(
      (rate.numerator, rate.denominator),
      (BigInt.from(39), BigInt.from(5)),
    );
    expect(
      rate.convert(Money.fromMinorUnits(Currency.usd, 100)),
      Money.fromMinorUnits(Currency.hkd, 780),
    );
    expect(
      () => ExactFxRate.majorRatio(
        source: Currency.usd,
        target: Currency.usd,
        numerator: BigInt.one,
        denominator: BigInt.one,
      ),
      throwsArgumentError,
    );
    expect(
      () => ExactFxRate.majorRatio(
        source: Currency.usd,
        target: Currency.hkd,
        numerator: BigInt.zero,
        denominator: BigInt.one,
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          rate.convert(Money.fromMinorUnits(Currency.usd, Money.maxMinorUnits)),
      throwsRangeError,
    );
  });

  test('Offline IDs are canonical, independent and stable values', () {
    final ids = List.generate(128, (_) => SecureUuidV4Generator().generate());
    expect(ids.map((id) => id.value).toSet(), hasLength(128));
    expect(LocalId(ids.first.value), ids.first);
    expect(() => LocalId('1'), throwsFormatException);
  });

  test('Clock boundary returns a deterministic UTC instant', () {
    final instant = DateTime.utc(2024, 2, 29, 1, 2, 3);
    expect(FixedClock(instant).nowUtc(), instant);
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });
}
