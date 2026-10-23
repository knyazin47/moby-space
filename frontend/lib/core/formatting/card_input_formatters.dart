import 'package:flutter/services.dart';

/// ASCII PAN input: at most sixteen digits, displayed in groups of four.
final class PanInputFormatter extends _CardDigitsFormatter {
  const PanInputFormatter() : super(16, groupSize: 4, separator: ' ');
}

/// MM/YY input. The slash is inserted as soon as both month digits exist.
final class ExpiryInputFormatter extends _CardDigitsFormatter {
  const ExpiryInputFormatter()
    : super(4, groupSize: 2, separator: '/', trailingAtGroup: true);
}

/// Three ASCII digits; does not claim that the code belongs to a real card.
final class CvcInputFormatter extends _CardDigitsFormatter {
  const CvcInputFormatter() : super(3);
}

abstract class _CardDigitsFormatter extends TextInputFormatter {
  const _CardDigitsFormatter(
    this.maximumDigits, {
    this.groupSize = 0,
    this.separator = '',
    this.trailingAtGroup = false,
  });

  final int maximumDigits;
  final int groupSize;
  final String separator;
  final bool trailingAtGroup;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Flutter formatters must wait for the IME to commit its composing text.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }
    final incoming = _deleteAcrossSeparator(oldValue, newValue);
    final digits = incoming.text.codeUnits
        .where(_isAsciiDigit)
        .take(maximumDigits)
        .toList();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (groupSize > 0 && i > 0 && i % groupSize == 0) {
        buffer.write(separator);
      }
      buffer.writeCharCode(digits[i]);
    }
    if (trailingAtGroup && digits.length == groupSize) {
      buffer.write(separator);
    }
    final formatted = buffer.toString();
    if (formatted == incoming.text) return incoming;
    final selection = incoming.selection;
    return TextEditingValue(
      text: formatted,
      selection: selection.isValid
          ? selection.copyWith(
              baseOffset: _mapOffset(
                incoming.text,
                formatted,
                selection.baseOffset,
              ),
              extentOffset: _mapOffset(
                incoming.text,
                formatted,
                selection.extentOffset,
              ),
            )
          : selection,
      composing: TextRange.empty,
    );
  }

  TextEditingValue _deleteAcrossSeparator(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (separator.isEmpty ||
        !oldValue.selection.isValid ||
        !oldValue.selection.isCollapsed ||
        !newValue.selection.isCollapsed) {
      return newValue;
    }
    final caret = oldValue.selection.extentOffset;
    final removed = caret - 1;
    // Only a one-character backspace directly over an existing separator.
    // Range replacements/pastes must never delete an additional digit.
    if (removed < 0 ||
        caret > oldValue.text.length ||
        newValue.selection.extentOffset != removed ||
        oldValue.text.substring(removed, caret) != separator ||
        newValue.text != oldValue.text.replaceRange(removed, caret, '')) {
      return newValue;
    }
    var digit = removed - 1;
    while (digit >= 0 && !_isAsciiDigit(newValue.text.codeUnitAt(digit))) {
      digit--;
    }
    if (digit < 0) return newValue;
    return newValue.copyWith(
      text: newValue.text.replaceRange(digit, digit + 1, ''),
      selection: TextSelection.collapsed(
        offset: digit,
        affinity: newValue.selection.affinity,
      ),
      composing: TextRange.empty,
    );
  }

  int _mapOffset(String input, String formatted, int offset) {
    final end = offset.clamp(0, input.length);
    final count = input.codeUnits
        .take(end)
        .where(_isAsciiDigit)
        .take(maximumDigits)
        .length;
    if (count == 0) return 0;
    var seen = 0;
    var position = 0;
    while (position < formatted.length && seen < count) {
      if (_isAsciiDigit(formatted.codeUnitAt(position))) seen++;
      position++;
    }
    // Keep an inserted separator behind the caret, including the automatic
    // trailing slash after MM. Unchanged formatted selections are preserved.
    while (position < formatted.length &&
        !_isAsciiDigit(formatted.codeUnitAt(position))) {
      position++;
    }
    return position;
  }
}

bool _isAsciiDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
