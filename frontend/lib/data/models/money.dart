/// An exact value in a currency's minor units. No floating-point arithmetic.
final class Money {
  Money(this.minorUnits, {this.currency = 'BYN'}) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw ArgumentError.value(currency, 'currency', 'Use a currency code');
    }
  }

  final int minorUnits;
  final String currency;

  Money operator +(Money other) {
    _checkCurrency(other);
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _checkCurrency(other);
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  void _checkCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot combine $currency and ${other.currency}');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      minorUnits == other.minorUnits &&
      currency == other.currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);
}
