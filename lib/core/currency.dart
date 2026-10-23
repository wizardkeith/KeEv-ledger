/// ISO-style currency units currently accepted by KeEv's local foundation.
/// Unknown codes require an explicit reviewed registry update.
final class Currency {
  const Currency._(this.code, this.minorDigits);

  final String code;
  final int minorDigits;

  static const hkd = Currency._('HKD', 2);
  static const usd = Currency._('USD', 2);
  static const eur = Currency._('EUR', 2);
  static const gbp = Currency._('GBP', 2);
  static const jpy = Currency._('JPY', 0);
  static const thb = Currency._('THB', 2);
  static const cny = Currency._('CNY', 2);

  static const supported = [hkd, usd, eur, gbp, jpy, thb, cny];

  static Currency fromCode(String code) {
    for (final currency in supported) {
      if (currency.code == code) return currency;
    }
    throw FormatException('Unsupported currency code', code);
  }

  @override
  bool operator ==(Object other) =>
      other is Currency &&
      other.code == code &&
      other.minorDigits == minorDigits;

  @override
  int get hashCode => Object.hash(code, minorDigits);
}
