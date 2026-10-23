/// Interface copy recovered from the allowed video range and named APK layouts.
/// Contacts, employers and calculator defaults below are invented local fixtures.
final class RecordedActionItem {
  const RecordedActionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String route;
}

final class RecordedContact {
  const RecordedContact(this.name, this.maskedPhone, this.initials);
  final String name;
  final String maskedPhone;
  final String initials;
  String get section => name[0];
}

abstract final class RecordedFormsContent {
  static const salaryTitle = 'Наименование работодателя';
  static const salaryDescription =
      'Для оформления зарплатной карты введите наименование организации '
      'или отсканируйте QR-код.';
  static const employerLabel = 'Наименование работодателя';
  static const employerHint = 'Введите наименование';
  static const salaryConsent =
      'Прошу сообщить номер счета моему работодателю для перечисления мне '
      'заработной платы и иных выплат.';
  static const employers = ['ООО «Липовый сад»', 'ООО «Городской сервис»'];
  static const next = 'Далее';
  static const cancel = 'Отмена';
  static const scanQr = 'Сканировать QR-код';
  static const clear = 'Очистить';
  static const creditTitle = 'Оформить кредит';
  static const creditName = 'Кредит «Проще простого»';
  static const amountLabel = 'Сумма кредита, BYN';
  static const amountHint = 'Введите сумму кредита';
  static const termLabel = 'Срок кредита, месяцев';
  static const termHint = 'Введите срок кредита';
  static const amountRange = 'от 500.00 - до 25 000.00 BYN';
  static const termRange = 'от 6 - до 60 месяцев';
  static const monthlyPayment = 'Ежемесячный платеж';
  static const rateLabel = 'Процентная ставка';
  static const annualRateSuffix = '% годовых';
  static const currency = 'BYN';
  // Illustrative local calculator values, not a bank tariff or recorded values.
  static const initialAmount = '1500.00';
  static const initialTerm = '12';
  static const minimumAmount = 500.0;
  static const maximumAmount = 25000.0;
  static const minimumTerm = 6;
  static const maximumTerm = 60;
  static const illustrativeAnnualRate = 18.0;
  static const calculationDelay = Duration(milliseconds: 450);
  static const contactsDelay = Duration(milliseconds: 400);
  static const transferTitle = 'Перевести';
  static const paymentTitle = 'Оплатить';
  // App-owned rationale from contacts_rationale_*; never an OS permission UI.
  static const contactsRationaleTitle =
      'Нужно разрешение на чтение ваших контактов';
  static const contactsRationaleDescription =
      'Чтобы выбрать номер из списка контактов, предоставьте приложению '
      'доступ к Контактам';
  static const contactsRationaleContinue = 'Продолжить';
  static const contactsTitle = 'Выбор контакта';
  static const contactsSearch = 'Номер телефона или имя';
  static const contactsEmpty =
      'Контакты не загружены.\nПотяните вниз для загрузки контактов';
  static const contactsLoading = 'Загружаем ваши контакты…';
  static const contactsNotFound = 'Контакт не найден';
  static const eripTitle = 'Переводы через ЕРИП';
  static const cardReplenishment = 'Пополнение карты';
  static const accountReplenishment = 'Пополнение текущего счета';
  static const cardReplenishmentRoute = '/refill?kind=card';
  static const accountReplenishmentRoute = '/refill?kind=account';
  static const contacts = [
    RecordedContact('Анна Соколова', '+375 •• ••• 00 11', 'АС'),
    RecordedContact('Борис Волков', '+375 •• ••• 00 22', 'БВ'),
    RecordedContact('Вера Белова', '+375 •• ••• 00 33', 'ВБ'),
    RecordedContact('Глеб Орлов', '+375 •• ••• 00 44', 'ГО'),
  ];
  static const transferItems = [
    RecordedActionItem(
      id: 'transfer-card',
      title: 'По номеру карты и счета',
      subtitle: 'Переводы между картами и счетами',
      icon: 'ic_transfer_by_card',
      route: '/transfer/local',
    ),
    RecordedActionItem(
      id: 'transfer-phone',
      title: 'По номеру телефона',
      subtitle: 'Перевод клиентам МТБанка',
      icon: 'ic_transfer_by_phone',
      route: '/transfer/phone',
    ),
    RecordedActionItem(
      id: 'transfer-ips',
      title: 'Мгновенный платёж',
      subtitle: 'Перевод по системе СМП',
      icon: 'ic_ips_transfer',
      route: '/transfer/local?method=ips',
    ),
  ];
  static const paymentItems = [
    RecordedActionItem(
      id: 'payment-mobile',
      title: 'Мобильная связь',
      subtitle: 'Оплата услуг связи',
      icon: 'ic_transfer_by_phone',
      route: '/payments/mobile',
    ),
    RecordedActionItem(
      id: 'payment-erip',
      title: 'ЕРИП',
      subtitle: 'Оплата услуг в системе ЕРИП',
      icon: 'ic_erip_payment',
      route: '/payments/erip',
    ),
    RecordedActionItem(
      id: 'payment-credit',
      title: 'Погашение кредита',
      subtitle: 'Погашение активных кредитных обязательств',
      icon: 'ic_credit_repayment',
      route: '/payments/credit',
    ),
    RecordedActionItem(
      id: 'payment-arbitrary',
      title: 'Произвольный платёж',
      subtitle: 'Оплата платежа через данные заказчика',
      icon: 'ic_arbitrary_payment',
      route: '/payments/arbitrary',
    ),
    RecordedActionItem(
      id: 'payment-qr',
      title: 'QR оплата',
      subtitle: 'Оплата по скану QR кода',
      icon: 'ic_qr_code_scan',
      route: '/payments/qr',
    ),
    RecordedActionItem(
      id: 'payment-templates',
      title: 'Шаблоны',
      subtitle: 'Управляйте своими шаблонами',
      icon: 'ic_pay_template',
      route: '/payments/templates',
    ),
  ];
}
