import 'demo_artwork.dart';

/// Demo deposit/loyalty content, separate from interchangeable illustrations.
abstract final class SourceCatalogContent {
  static const depositTitle = 'Открытие вклада';
  static const currency = 'Валюта вклада';
  static const currencies = ['BYN', 'USD', 'EUR'];
  static const amount = 'Сумма вклада';
  static const type = 'Тип вклада';
  static const revocable = 'Отзывной';
  static const irrevocable = 'Безотзывной';
  static const term = 'Срок вклада';
  static const search = 'Подобрать';
  static const empty = 'По заданным критериям вкладов не найдено';
  static const required = 'Поле является обязательным';
  // Local validation copy; the numeric maximum comes from the source input.
  static const invalidAmount =
      'Введите сумму больше 0 и не больше 99 999 999 999';
  static const amountHint = '0.00';
  static const clear = 'Очистить';
  static const maximumAmount = 99999999999.0;
  static const loyaltyTitle = 'Новые возможности с МТкартой';
  static const loyaltySubtitle = 'Подключите Пакет услуг Лайт к своей МТкарте';
  static const loyaltyDescription =
      'Откройте доступ к самым выгодным предложениям от банка';
  static const connect = 'Подключить';
  static const close = 'Закрыть';
  static const packageTitle = 'Пакет услуг';
  static const loyaltyArt = DemoArtwork.reward;
  static const loyaltyError =
      'Не удалось загрузить информацию о Пакете услуг. Повторите попытку позже';
  static const loadingError = 'Не удалось загрузить данные!';
  static const retry = 'Повторить';
  static const chooseCard = 'Выберите карту';
  static const noCardOffers =
      'К сожалению, сейчас для вас нет доступных предложений';

  static String months(int value) {
    final last = value % 10;
    final teen = value % 100;
    final suffix = teen >= 11 && teen <= 14
        ? 'месяцев'
        : last == 1
        ? 'месяц'
        : last >= 2 && last <= 4
        ? 'месяца'
        : 'месяцев';
    return '$value $suffix';
  }
}

/// Local fixture bounds, not recovered bank product terms. The APK obtains
/// these from product data; the offline catalog deliberately has no offers.
final class SourceDepositFixture {
  const SourceDepositFixture({
    this.minMonths = 1,
    this.maxMonths = 36,
    this.loadingDuration = const Duration(milliseconds: 400),
  }) : assert(minMonths > 0),
       assert(maxMonths > minMonths);

  final int minMonths;
  final int maxMonths;
  final Duration loadingDuration;

  bool acceptsAmount(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return value != null &&
        value.isFinite &&
        value > 0 &&
        value <= SourceCatalogContent.maximumAmount;
  }

  String? amountError(String text) {
    if (text.trim().isEmpty) return SourceCatalogContent.required;
    return acceptsAmount(text) ? null : SourceCatalogContent.invalidAmount;
  }
}
