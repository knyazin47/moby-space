/// Initial contract lookup shell from fragment_credit_repayment.xml.
/// Contract format/lookup and the recipient/debt payload are runtime unknown.
abstract final class SourceCreditRepaymentContent {
  static const title = 'Погашение кредита';
  static const information =
      'Введите номер договора, заключенного с ЗАО «МТБанк»';
  static const contractNumber = 'Номер договора';
  static const continueAction = 'Продолжить';
  static const clear = 'Очистить';
  static const errorTitle = 'Ошибка';
  static const unavailable =
      'Погашение недоступно. Не удалось определить продукты для совершения операции.';
  static const retry = 'Повторить';
  static const close = 'Закрыть';
  // Local scheduling only, not a bank request or an observed response SLA.
  static const lookupDuration = Duration(milliseconds: 450);

  /// Only local completeness is checked; this is not bank contract validation.
  static bool canContinue(String value) => value.trim().isNotEmpty;
}
