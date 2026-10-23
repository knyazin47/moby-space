import 'recorded_content.dart';

/// Public shell copy comes from fragment_nembo_exchange/operation and strings.
/// Rates remain the shared synthetic RecordedContent.rates, never a bank feed.
abstract final class SourceExchangeContent {
  static const title = 'Обменник Moby';
  static const calculationTitle = 'Рассчитайте сумму обмена';
  static const inputTitle = 'У меня есть';
  static const outputTitle = 'Мне нужно';
  static const swap = 'Поменять валюты';
  static const chooseCurrency = 'Выберите валюту';
  static const rateTitle = 'Ваш курс обмена:';
  static const improveTitle = 'Улучшить курс';
  static const improveUnavailable =
      'Информация об улучшенном курсе временно недоступна.';
  static const promoTitle = 'Использовать промокод';
  static const promoHint = 'Введите промокод';
  static const promoShort = 'Минимальная длина кода 6 символов';
  static const promoUnavailable =
      'Применение промокода на данный момент недоступно';
  static const promoMinimumLength = 6;
  static const apply = 'Применить';
  static const next = 'Продолжить';
  static const cancel = 'Отмена';
  static const close = 'Закрыть';
  static const confirm = 'Подтвердить';
  static const debitAccount = 'Выберите счёт списания';
  static const creditAccount = 'Выберите счёт зачисления';
  static const debitAmount = 'Сумма списания:';
  static const creditAmount = 'Сумма зачисления:';
  static const confirmation = 'Обмен валют';
  static const noAccounts =
      'Отсутствуют счета в нужных валютах. Для оформления перейдите в раздел "Продукты"';
  static const unavailableTitle = 'Обмен недоступен';
  static const unavailableBody =
      'Не удалось выполнить обмен валют. Повторите попытку позже.';
  static const insufficientFunds = 'Недостаточно средств';
  static const invalidAmount = RecordedContent.amountInvalid;
  static const maximumAmount = RecordedContent.maximumAmount;
  static const initialInputCurrency = 'USD';
  static const initialOutputCurrency = 'BYN';
  static const amountHint = '0.00';
  static const currencies = RecordedContent.converterCurrencies;

  static String formatRate(double rate, String from, String to) =>
      '${rate.toStringAsFixed(4)} $to за 1 $from';

  static String? flagFor(String code) {
    if (code == 'BYN') return 'image_byn';
    for (final rate in RecordedContent.rates) {
      if (rate.code == code) return rate.asset;
    }
    return null;
  }

  /// Selling the source currency uses buy/units; purchasing the destination
  /// uses sell/units. Cross quotes pass through BYN. Preview only: never a
  /// settlement or floating-point mutation of the integer repository ledger.
  static double? rateFor(String from, String to) {
    if (from == to || !currencies.contains(from) || !currencies.contains(to)) {
      return null;
    }
    double? debitPrice = from == 'BYN' ? 1 : null;
    double? creditPrice = to == 'BYN' ? 1 : null;
    for (final rate in RecordedContent.rates) {
      if (rate.units <= 0) return null;
      if (rate.code == from) debitPrice = rate.buy / rate.units;
      if (rate.code == to) creditPrice = rate.sell / rate.units;
    }
    if (debitPrice == null ||
        creditPrice == null ||
        !debitPrice.isFinite ||
        !creditPrice.isFinite ||
        debitPrice <= 0 ||
        creditPrice <= 0) {
      return null;
    }
    return debitPrice / creditPrice;
  }

  static SourceExchangeQuote? calculate({
    required String text,
    required String from,
    required String to,
    bool receivingInput = false,
  }) {
    final normalized = text.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,10}(\.\d{0,2})?$').hasMatch(normalized)) return null;
    final value = double.tryParse(normalized);
    final rate = rateFor(from, to);
    if (value == null ||
        !value.isFinite ||
        value <= 0 ||
        value > maximumAmount ||
        rate == null) {
      return null;
    }
    final debit = receivingInput ? value / rate : value;
    final credit = receivingInput ? value : value * rate;
    if (!debit.isFinite ||
        !credit.isFinite ||
        debit > maximumAmount ||
        credit > maximumAmount) {
      return null;
    }
    final roundedDebit = (debit * 100).round() / 100;
    final roundedCredit = (credit * 100).round() / 100;
    if (roundedDebit <= 0 || roundedCredit <= 0) return null;
    return SourceExchangeQuote(
      from: from,
      to: to,
      debit: roundedDebit,
      credit: roundedCredit,
      rate: rate,
    );
  }
}

final class SourceExchangeQuote {
  const SourceExchangeQuote({
    required this.from,
    required this.to,
    required this.debit,
    required this.credit,
    required this.rate,
  });
  final String from;
  final String to;
  final double debit;
  final double credit;
  final double rate;
  String get debitLabel => '${debit.toStringAsFixed(2)} $from';
  String get creditLabel => '${credit.toStringAsFixed(2)} $to';
  String get rateLabel => SourceExchangeContent.formatRate(rate, from, to);
}
