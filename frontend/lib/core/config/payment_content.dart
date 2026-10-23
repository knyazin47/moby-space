/// Packaged UI labels from fragment_mobile_payment/templates_list and strings.
/// Local validation is a prototype contract, never a bank/operator lookup.
abstract final class PaymentContent {
  static const arbitrary = 'Произвольный платёж';
  static const unp = 'УНП';
  static const iban = 'Счёт получателя (IBAN)';
  static const bic = 'БИК банка получателя';
  static const recipient = 'Получатель';
  static const purpose = 'Назначение';
  static const code = 'Код назначения платежа';
  static const codeHint = '5 цифр';
  static const codebook = 'Справочник кодов назначения платежа';
  static const chooseCode = 'Выбрать из справочника кодов';
  static const noCode = 'Код назначения платежа не найден';
  static const searchLimit = 255;
  static const codebookUnavailable =
      'Не удалось загрузить данные. Повторите попытку позже.';
  static const localBic = 'MTBKBY22';
  static const refund = 'Возврат';
  static const recipientHint = 'Организация или ИП';
  static const purposeHint = 'Назначение платежа';
  static const arbitrarySwipe = 'Проведите пальцем\nдля совершения операции';
  static const arbitraryWarning =
      'Обращаем внимание, что осуществление платежа возможно только на счета, открытые в национальной валюте в банках-резидентах Республики Беларусь';
  static const refundExplanation =
      'Выберите Возврат, если вам нужно вернуть:\n - излишне уплаченные денежные средства;\n - ошибочно совершенный платеж;\n - средства за ранее оплаченный товар;\n - средства за неоказанные услуги.';
  static const ibanError = 'Введите IBAN в формате BY…';
  static const required = 'Заполните поле';
  // Local editing bounds where the source gets server BillDetail maxLength.
  static const localTextLimit = 255;
  static const localUnpLimit = 32;
  static bool validIban(String value) =>
      RegExp(r'^BY\d{2}[A-Z0-9]{4}\d{4}[A-Z0-9]{16}$').hasMatch(value);
  static const mobile = 'Мобильная связь';
  static const phone = 'Номер телефона';
  static const phoneHint = '(__) ___-__-__';
  static const operators = ['A1', 'MTC', 'Life:)', 'Определить'];
  static const operatorAssets = [
    'ic_operator_active_a1',
    'ic_operator_active_mtc',
    'ic_operator_life_active',
    'ic_operator_determine',
  ];
  static const determineError = 'Не удалось определить оператора';
  static const contactNumbers = [
    '290000011',
    '290000022',
    '290000033',
    '290000044',
  ];
  static const phoneError = 'Введите номер телефона';
  static const amount = 'Сумма, BYN';
  static const commission = 'Комиссия МТБанка: 0,00 BYN';
  static const swipe = 'Проведите пальцем\nдля совершения оплаты';
  static const confirm = 'Подтвердить оплату';
  static const templates = 'Шаблоны';
  static const noTemplates = 'На данный момент шаблоны отсутствуют';
  static const credit = 'Погашение кредита';
  static const noCredits = 'У вас нет действующих кредитов';
  static const qr = 'QR оплата';
  static const qrHint = 'Наведите камеру на QR-код';
  static const cameraUnavailable = 'Камера недоступна';
  static const repeat = 'Повторить';
  static const close = 'Закрыть';
  static const determineDelay = Duration(milliseconds: 600);
  static bool validPhone(String text) =>
      RegExp(r'^\d{9}$').hasMatch(text.replaceAll(RegExp(r'\D'), ''));
}
