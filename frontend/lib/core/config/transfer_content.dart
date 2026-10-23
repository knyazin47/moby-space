import '../validation/card_validation.dart';

final class SyntheticExternalCard {
  const SyntheticExternalCard({
    required this.number,
    required this.expiry,
    required this.cvv,
  });
  final String number;
  final String expiry;
  final String cvv;
}

/// Mutable demo copy/defaults. These are not bank validation or network settings.
abstract final class TransferContent {
  static const from = 'Откуда';
  static const to = 'Куда';
  static const favourites = 'Избранные';
  static const numberHint = 'XXXX XXXX XXXX XXXX';
  static const expiryHint = 'ММ/ГГ';
  static const cvvHint = 'CVV';
  static const sourceNumber = 'Номер карты-источника';
  static const recipientNumber = 'Номер карты или счета получателя';
  static const expiry = 'Срок действия';
  static const cvv = 'Код CVV';
  static const camera = 'Сканировать карту';
  static const nfc = 'NFC';
  static const amount = 'Сумма, BYN';
  static const amountHint = '0.00';
  static const countries = 'Доступные страны для перевода';
  static const countriesDescription =
      'Информация временно недоступна. Повторите попытку позже.';
  static const close = 'Закрыть';
  static const points = '0.00 баллов';
  static const cards = 'Карты';
  static const reorder = 'Изменить порядок карты';
  static const moveEarlier = 'Переместить выше';
  static const moveLater = 'Переместить ниже';
  static const swipeTransfer = 'Проведите пальцем\nдля совершения платежа';
  static const swipeRefill = 'Проведите пальцем\nдля совершения платежа';
  static const confirmTransfer = 'Подтвердить перевод';
  static const confirmRefill = 'Подтвердить пополнение';
  static const externalCardRequired = 'Заполните данные карты';
  static const syntheticRecipient = 'Получатель';
  static const externalCard = SyntheticExternalCard(
    number: '4111 1111 1111 1111',
    expiry: '12/30',
    cvv: '000',
  );
  static const swipeHeight = 44.0;
  static const swipeStartZone = .3;
  static const swipeCompleteThreshold = .7;
  static const swipeReturnDuration = Duration(milliseconds: 250);

  static String commission(String amount) => 'Комиссия МТБанка: $amount';
  static String amountLabel(String currency) => 'Сумма, $currency';
  static String cardPageLabel(int page, int total) => 'Карта $page из $total';

  // Local syntax/checksum/date checks; never card existence or bank verification.
  static bool externalInputComplete(
    String number,
    String expiry,
    String cvv, {
    DateTime? now,
  }) =>
      CardValidation.pan(number) == null &&
      CardValidation.expiry(expiry, now: now ?? DateTime.now()) == null &&
      CardValidation.cvc(cvv) == null;

  static String? cardNumberError(String? value) =>
      switch (CardValidation.pan(value ?? '')) {
        null => null,
        PanValidationError.empty => 'Введите номер карты',
        PanValidationError.invalidLength => 'Введите 16 цифр',
        _ => 'Проверьте номер карты',
      };
  static String? expiryError(String? value, {DateTime? now}) =>
      switch (CardValidation.expiry(value ?? '', now: now ?? DateTime.now())) {
        null => null,
        ExpiryValidationError.empty => 'Укажите срок',
        ExpiryValidationError.invalidMonth => 'Месяц 01–12',
        ExpiryValidationError.expired => 'Срок истёк',
        _ => 'Укажите ММ/ГГ',
      };
  static String? cvcError(String? value) =>
      CardValidation.cvc(value ?? '') == null ? null : '3 цифры';
}

/// Medium CardsSliderView design tokens recovered from APK 1.0.199.
abstract final class TransferCardMetrics {
  static const pagerInset = 12.0;
  static const cardSideMargin = 8.0;
  static const cardTop = 12.0;
  static const cardBottom = 24.0;
  static const cardRadius = 17.0;
  static const cardElevation = 6.0;
  static const accessibleMinHeight = 128.0;
  static const cardSurface = 0xFFEFF5FB;
  static const cardBorder = 0xFFE1E5E9;
  static const cardDivider = 0xFFDFE3EC;
  static const dotSize = 5.0;
  static const dotWidthFactor = 1.9;
  static const dotRadius = 2.5;
  static const dotSideMargin = 1.5;
  static const dotTopOverlap = 16.0;
  static const dotBottom = 8.0;
  static const dotInactive = 0xFFD3D7DC;
  static const dotActive = 0xFF202020;
  // Local smooth navigation duration; native ViewPager duration is not asserted.
  static const pageNavigationDuration = Duration(milliseconds: 250);
}
