/// Local syntax/checksum checks only; no bank, issuer or card-existence lookup.
enum PanValidationError {
  empty,
  invalidCharacters,
  invalidLength,
  repeatedDigits,
  invalidChecksum,
}

enum ExpiryValidationError { empty, invalidFormat, invalidMonth, expired }

enum CvcValidationError { empty, invalidCharacters, invalidLength }

abstract final class CardValidation {
  static PanValidationError? pan(String value) {
    if (value.trim().isEmpty) return PanValidationError.empty;
    // Only the ASCII grouping spaces introduced by PanInputFormatter are
    // accepted. Unicode digits, tabs, punctuation and mask glyphs are invalid.
    final digits = value.replaceAll(' ', '');
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) {
      return PanValidationError.invalidCharacters;
    }
    if (digits.length != 16) return PanValidationError.invalidLength;
    if (digits.split('').every((digit) => digit == digits[0])) {
      return PanValidationError.repeatedDigits;
    }
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var digit = digits.codeUnitAt(i) - 0x30;
      if (i.isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0 ? null : PanValidationError.invalidChecksum;
  }

  /// MM/YY means 2000..2099. Expiration is inclusive of the entire printed
  /// month; callers inject their clock instead of this method reading time.
  static ExpiryValidationError? expiry(String value, {required DateTime now}) {
    if (value.trim().isEmpty) return ExpiryValidationError.empty;
    if (!RegExp(r'^[0-9]{2}/[0-9]{2}$').hasMatch(value)) {
      return ExpiryValidationError.invalidFormat;
    }
    final month = int.parse(value.substring(0, 2));
    if (month < 1 || month > 12) return ExpiryValidationError.invalidMonth;
    final year = 2000 + int.parse(value.substring(3, 5));
    if (year < now.year || (year == now.year && month < now.month)) {
      return ExpiryValidationError.expired;
    }
    return null;
  }

  static CvcValidationError? cvc(String value) {
    if (value.trim().isEmpty) return CvcValidationError.empty;
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return CvcValidationError.invalidCharacters;
    }
    return value.length == 3 ? null : CvcValidationError.invalidLength;
  }
}
