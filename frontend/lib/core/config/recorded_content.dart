/// Screen copy and synthetic values for the surfaces observed in the recording.
/// Personal values are invented. Public bank contacts are static APK UI copy,
/// not a current-directory lookup. No action in these screens contacts the bank.
abstract final class RecordedContent {
  static const settings = 'Настройки';
  static const profile = 'Персональные данные';
  static const documents = 'Документы';
  static const notifications = 'Уведомления';
  static const currency = 'Курсы валют';
  static const about = 'О Банке';
  static const transferByPhone = 'Переводы по номеру телефона';
  static const biometric = 'Вход по биометрии';
  static const darkTheme = 'Темная тема';
  static const changeCode = 'Изменить смарт-код';
  static const changeEmail = 'Изменить Email';
  static const screenshot = 'Запрет скриншотов';
  static const logout = 'Выйти';
  static const emailTitle = 'Изменение Email';
  static const email = 'Email';
  static const emailPlaceholder = 'Ваш e-mail';
  static const emailHint = 'Например: ivan@example.com';
  static const initialEmail = 'ivan@example.com';
  static const initialBiometric = true;
  static const initialScreenshot = false;
  static const initialBuyCurrency = 'USD';
  static const initialSellCurrency = 'BYN';
  static const zeroAmount = '0,00';
  static const initialConversionAmount = '100.00';
  static const demoRate = 'Курс';
  static const visaNickname = 'Ваше имя в сервисе переводов';
  static const transferSettingsRoute = '/settings/transfers';
  static const cardForTransfer = 'Карта для зачислений';
  static const transferProduct =
      'Выберите продукт для получения переводов по системе мгновенных платежей:';
  static const transferConsent =
      'Я согласен (-на) с предоставлением персональных данных сервису';
  static const ipsConsent =
      'Я согласен (-на) с предоставлением персональных данных сервису СМП';
  static const transferLocalSaved = 'Настройка сохранена';
  static const eripTitle = 'Переводы через ЕРИП';
  static const transferMethods = <RecordedTransferMethod>[
    RecordedTransferMethod(
      'moby',
      'Переводы в Moby',
      'Выберите карту для получения мгновенных переводов по номеру телефона в Moby. '
          'Карту можно сменить в любой момент в данном разделе или в настройках карты.',
      '',
      alwaysEnabled: true,
    ),
    RecordedTransferMethod(
      'ips',
      'Мгновенные платежи СМП',
      'Выберите счет, на который вы хотите получать переводы по системе мгновенных платежей (СМП)',
      'Включить переводы СМП',
      requiresConsent: true,
    ),
    RecordedTransferMethod(
      'erip-card',
      'Пополнение карты',
      'Выберите карту, на которую вы хотите получать переводы через ЕРИП по номеру телефона',
      'Привязать карту',
      requiresConsent: true,
    ),
    RecordedTransferMethod(
      'erip-account',
      'Пополнение текущего счета',
      'Выберите счет, на который вы хотите получать переводы через ЕРИП по номеру телефона',
      'Привязать счет',
      requiresConsent: true,
    ),
    RecordedTransferMethod(
      'visa',
      'Переводы через сервис Visa',
      'Сервис Visa позволяет получать денежные переводы на вашу карту по номеру телефона. '
          'Чтобы воспользоваться сервисом, привяжите карту в этом разделе.',
      'Привязать карту к сервису',
    ),
  ];
  static const emailInfo =
      'Используется для отправки выписки движения бонусных баллов, '
      'выписки по карт-счёту, специальных предложений Банка и т.п.';
  static const localEmailInfo = 'Укажите адрес электронной почты';
  static const emailInvalid = 'Введите email в формате name@example.com';
  static const emailSaved = 'Email изменён';
  static const save = 'Сохранить';
  static const cancel = 'Отмена';
  static const close = 'Закрыть';
  static const update = 'Актуализировать';
  static const fullName = 'ФИО';
  static const phone = 'Мобильный телефон';
  static const profileSaved = 'Данные обновлены';
  static const localSetting = 'Настройка сохранена';
  static const lightOnly = 'Используется светлая тема';
  static const codeNotice =
      'Изменение смарт-кода временно недоступно. Повторите попытку позже.';
  static const logoutQuestion = 'Вы уверены, что хотите выйти?';
  static const noDocuments = 'Документов нет';
  static const demoNotice = RecordedNotice(
    title: 'Быть внимательным — это просто',
    summary:
        'Не сообщайте другим людям пароли и коды. Проверяйте адреса сайтов.',
    body:
        'Не сообщайте другим людям пароли '
        'и коды подтверждения. Проверяйте адрес сайта перед вводом данных.',
    date: '19.10.2026 12:00',
  );
  static const profileFields = <RecordedField>[
    RecordedField('Документ', 'Паспорт\n•• •••••••'),
    RecordedField('Место рождения', 'г. Минск'),
    RecordedField('Адрес регистрации', 'г. Минск, ул. Садовая, д. 12'),
    RecordedField('Адрес проживания', 'г. Минск, ул. Садовая, д. 12'),
  ];
  static const tabs = <RecordedCurrencyTab>[
    RecordedCurrencyTab('Обменник Moby', RecordedCurrencyKind.exchange),
    RecordedCurrencyTab('МТБанк', RecordedCurrencyKind.bank),
    RecordedCurrencyTab('НБРБ', RecordedCurrencyKind.centralBank),
  ];
  static const exchange = 'Обмен валют';
  static const conversion = 'Конверсия';
  static const currencyLabel = 'Валюта';
  static const buy = 'Покупка';
  static const sell = 'Продажа';
  static const rate = 'Курс';
  static const converter = 'Конвертер валют';
  static const buying = 'Я покупаю';
  static const selling = 'Я продаю';
  static const exchangeAction = 'Обменять';
  static const chooseCurrencies = 'Изменить список валют';
  // Synthetic timestamp; source presentation format, no live bank rate feed.
  static const demoRates = 'Обновлено 19.10.2026 в 12:00';
  static const ratesInfo =
      'Данные курсы применимы только для операций, совершаемых в Обменнике Moby. '
      'С курсами валют по прочим операциям в каналах СДБО и отделениях банка можно ознакомиться ';
  static const ratesSiteLabel = 'на сайте';
  static const ratesSiteNotice =
      'Страница временно недоступна. Повторите попытку позже.';
  static const exchangeNotice = 'Выберите счёт для обмена валют';
  static const amountInvalid = 'Введите положительную сумму до 1 000 000 000';
  static const maximumAmount = 1000000000.0;
  // A deterministic demo delay, not the measured duration of a bank request.
  static const loadingDuration = Duration(milliseconds: 450);
  // The recording keeps the parent list under a loader, then briefly shows
  // disabled IPS content before the disconnected state. No request is made.
  static const ipsParentLoadingDuration = Duration(milliseconds: 2750);
  static const ipsTransientDuration = Duration(milliseconds: 250);
  static const rates = <RecordedRate>[
    RecordedRate('USD', 1, 'image_usd', 3.0000, 3.1000, 3.0500),
    RecordedRate('EUR', 1, 'image_eur', 3.3000, 3.4000, 3.3500),
    RecordedRate('RUB', 100, 'image_rub', 3.4000, 3.6000, 3.5000),
  ];
  static const converterCurrencies = ['USD', 'EUR', 'RUB', 'BYN'];
  static const bankName = 'ЗАО "МТБанк"';
  static const bankAddress = '220007, г. Минск, улица Толстого, 10';
  static const bankRequisites =
      'БИК/SWIFT: MTBKBY22\nУНП 100394906\nОКПО 14619370';
  static const bankContacts = <RecordedField>[
    RecordedField('тел:', '509 99 99'),
    RecordedField('e-mail:', 'moby@mtbank.by'),
    RecordedField('сайт:', 'https://www.mtbank.by'),
  ];
  static const offer = 'Публичная оферта';
  static const privacy = 'Политика конфиденциальности';
  static const copied = 'Скопировано';
  static const localDocumentTitle = 'Документы';
  static const localDocumentBody =
      'Не удалось загрузить документ. Повторите попытку позже.';
}

final class RecordedField {
  const RecordedField(this.label, this.value);
  final String label;
  final String value;
}

final class RecordedNotice {
  const RecordedNotice({
    required this.title,
    required this.summary,
    required this.body,
    required this.date,
  });
  final String title;
  final String summary;
  final String body;
  final String date;
}

enum RecordedCurrencyKind { exchange, bank, centralBank }

final class RecordedCurrencyTab {
  const RecordedCurrencyTab(this.label, this.kind);
  final String label;
  final RecordedCurrencyKind kind;
}

final class RecordedRate {
  const RecordedRate(
    this.code,
    this.units,
    this.asset,
    this.buy,
    this.sell,
    this.central,
  );
  final String code;
  final int units;
  final String? asset;
  final double buy;
  final double sell;
  final double central;
}

final class RecordedTransferMethod {
  const RecordedTransferMethod(
    this.id,
    this.title,
    this.description,
    this.switchLabel, {
    this.alwaysEnabled = false,
    this.requiresConsent = false,
  });
  final String id;
  final String title;
  final String description;
  final String switchLabel;
  final bool alwaysEnabled;
  final bool requiresConsent;
}
