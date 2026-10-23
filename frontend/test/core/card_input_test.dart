import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/core/formatting/card_input_formatters.dart';
import 'package:moby_demo/core/validation/card_validation.dart';

TextEditingValue edit(String text, {int? cursor, int? base, int? extent}) =>
    TextEditingValue(
      text: text,
      selection: base == null
          ? TextSelection.collapsed(offset: cursor ?? text.length)
          : TextSelection(baseOffset: base, extentOffset: extent!),
    );

void main() {
  group('PAN formatter', () {
    const formatter = PanInputFormatter();
    test('pastes raw/formatted PAN, bounds length and accepts ASCII only', () {
      final raw = formatter.formatEditUpdate(
        TextEditingValue.empty,
        edit('4111111111111111'),
      );
      expect(raw.text, '4111 1111 1111 1111');
      expect(raw.selection.extentOffset, 19);
      expect(
        formatter
            .formatEditUpdate(
              TextEditingValue.empty,
              edit('4111-1111 1111\n1111 99'),
            )
            .text,
        raw.text,
      );
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, edit('１２٣4a1')).text,
        '41',
      );
    });
    test('maps paste selection by digit positions and preserves direction', () {
      final value = formatter.formatEditUpdate(
        TextEditingValue.empty,
        edit('4111111111111111', base: 8, extent: 4),
      );
      expect(value.selection.baseOffset, 10);
      expect(value.selection.extentOffset, 5);
      final formatted = edit('4111 1111 1111 1111', base: 1, extent: 4);
      expect(formatter.formatEditUpdate(formatted, formatted), formatted);
    });
    test('middle replacement and backspace across a group separator', () {
      final replaced = formatter.formatEditUpdate(
        edit('4111 1111', base: 2, extent: 7),
        edit('4191', cursor: 3),
      );
      expect(replaced.text, '4191');
      expect(replaced.selection.extentOffset, 3);
      final deleted = formatter.formatEditUpdate(
        edit('4111 1111', cursor: 5),
        edit('41111111', cursor: 4),
      );
      expect(deleted.text, '4111 111');
      expect(deleted.selection.extentOffset, 3);
    });
  });

  group('expiry formatter', () {
    const formatter = ExpiryInputFormatter();
    test('automatically inserts slash and supports raw or separated paste', () {
      expect(formatter.formatEditUpdate(edit('1'), edit('12')), edit('12/'));
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, edit('1227')),
        edit('12/27'),
      );
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, edit('12/27')),
        edit('12/27'),
      );
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, edit('12-27x99')),
        edit('12/27'),
      );
    });
    test(
      'backspace slash removes previous month digit instead of trapping caret',
      () {
        expect(formatter.formatEditUpdate(edit('12/'), edit('12')), edit('1'));
        final middle = formatter.formatEditUpdate(
          edit('12/27', cursor: 3),
          edit('1227', cursor: 2),
        );
        expect(middle.text, '12/7');
        expect(middle.selection.extentOffset, 1);
      },
    );
    test('range deletion does not remove an extra month digit', () {
      final value = formatter.formatEditUpdate(
        edit('12/27', base: 2, extent: 3),
        edit('1227', cursor: 2),
      );
      expect(value.text, '12/27');
      expect(value.selection.extentOffset, 3);
      expect(
        formatter.formatEditUpdate(edit('12/27'), edit('12/2')),
        edit('12/2'),
      );
    });
  });

  group('CVC and IME/selection boundaries', () {
    test('CVC pastes digits only and limits to three', () {
      const formatter = CvcInputFormatter();
      expect(
        formatter
            .formatEditUpdate(TextEditingValue.empty, edit('0a1 2٣4'))
            .text,
        '012',
      );
      final replaced = formatter.formatEditUpdate(
        edit('123', base: 0, extent: 2),
        edit('93', cursor: 1),
      );
      expect(replaced, edit('93', cursor: 1));
    });
    test(
      'all formatters leave active composing value untouched until commit',
      () {
        const composing = TextEditingValue(
          text: '１２3a45',
          selection: TextSelection.collapsed(offset: 6),
          composing: TextRange(start: 0, end: 6),
        );
        for (final formatter in <TextInputFormatter>[
          const PanInputFormatter(),
          const ExpiryInputFormatter(),
          const CvcInputFormatter(),
        ]) {
          expect(
            identical(
              formatter.formatEditUpdate(TextEditingValue.empty, composing),
              composing,
            ),
            isTrue,
          );
          final committed = formatter.formatEditUpdate(
            composing,
            composing.copyWith(composing: TextRange.empty),
          );
          expect(committed.text, isNot(contains('a')));
          expect(committed.text, isNot(contains('１２')));
        }
      },
    );
    test(
      'invalid selection remains invalid; removed Unicode never breaks offsets',
      () {
        const formatter = PanInputFormatter();
        const invalid = TextEditingValue(text: '4111-1111');
        expect(
          formatter.formatEditUpdate(TextEditingValue.empty, invalid).selection,
          const TextSelection.collapsed(offset: -1),
        );
        final value = formatter.formatEditUpdate(
          TextEditingValue.empty,
          edit('😀41111', cursor: 7),
        );
        expect(value.text, '4111 1');
        expect(value.selection.extentOffset, 6);
      },
    );
  });

  group('local card validation', () {
    test('PAN length, Luhn, identical-digit and ASCII boundaries', () {
      expect(CardValidation.pan('4111111111111111'), isNull);
      expect(CardValidation.pan('4111 1111 1111 1111'), isNull);
      expect(CardValidation.pan(''), PanValidationError.empty);
      expect(
        CardValidation.pan('411111111111111'),
        PanValidationError.invalidLength,
      );
      expect(
        CardValidation.pan('41111111111111111'),
        PanValidationError.invalidLength,
      );
      expect(
        CardValidation.pan('4111111111111112'),
        PanValidationError.invalidChecksum,
      );
      expect(
        CardValidation.pan('0000000000000000'),
        PanValidationError.repeatedDigits,
      );
      expect(
        CardValidation.pan('1111111111111111'),
        PanValidationError.repeatedDigits,
      );
      expect(
        CardValidation.pan('４111111111111111'),
        PanValidationError.invalidCharacters,
      );
      expect(
        CardValidation.pan('4111-1111-1111-1111'),
        PanValidationError.invalidCharacters,
      );
    });
    test('expiry current month inclusive, last month and year transition', () {
      final now = DateTime(2026, 12, 31, 23, 59);
      expect(CardValidation.expiry('12/26', now: now), isNull);
      expect(
        CardValidation.expiry('11/26', now: now),
        ExpiryValidationError.expired,
      );
      expect(CardValidation.expiry('01/27', now: now), isNull);
      expect(
        CardValidation.expiry('12/26', now: DateTime(2027, 1, 1)),
        ExpiryValidationError.expired,
      );
      expect(
        CardValidation.expiry('01/27', now: DateTime(2027, 1, 31)),
        isNull,
      );
    });
    test('expiry format, invalid month, old year and no hidden clock', () {
      final now = DateTime.utc(2026, 10);
      expect(CardValidation.expiry('', now: now), ExpiryValidationError.empty);
      for (final text in ['00/27', '13/27']) {
        expect(
          CardValidation.expiry(text, now: now),
          ExpiryValidationError.invalidMonth,
        );
      }
      for (final text in ['1/27', '1227', '12/2027', '１２/27', '12/27 ']) {
        expect(
          CardValidation.expiry(text, now: now),
          ExpiryValidationError.invalidFormat,
        );
      }
      expect(
        CardValidation.expiry('12/25', now: now),
        ExpiryValidationError.expired,
      );
      expect(
        CardValidation.expiry('02/28', now: DateTime(2028, 2, 29)),
        isNull,
      );
    });
    test(
      'CVC exactly three ASCII digits; zero is a syntactically valid digit',
      () {
        expect(CardValidation.cvc('123'), isNull);
        expect(CardValidation.cvc('000'), isNull);
        expect(CardValidation.cvc(''), CvcValidationError.empty);
        expect(CardValidation.cvc('12'), CvcValidationError.invalidLength);
        expect(CardValidation.cvc('1234'), CvcValidationError.invalidLength);
        expect(CardValidation.cvc('１２３'), CvcValidationError.invalidCharacters);
        expect(CardValidation.cvc('1 2'), CvcValidationError.invalidCharacters);
      },
    );
  });
}
