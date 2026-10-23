/// Shared interface copy; scenario-specific content lives in DemoScenario.
abstract final class AppCopy {
  static const appName = 'Moby Space';
  static const halva = 'Халва';
  static const applyCard = 'Оформить карту';
  static const applicationUnavailable = 'Оформление недоступно';
  static const applicationUnavailableHint =
      'К сожалению, Вам недоступно оформление карты. Пожалуйста, повторите попытку или обратитесь в банк';
  static const contactBank = 'Сообщить\nв банк';
  static const home = 'Главная';
  static const products = 'Продукты';
  static const chat = 'Чат';
  static const more = 'Ещё';
  static const history = 'История операций';
  static const details = 'Детали операции';
  static const search = 'Поиск';
  static const refill = 'Пополнить';
  static const transfer = 'Перевести';
  static const pay = 'Оплатить';
  static const points = 'Баллы';
  static const apply = 'Оформить';
  static const addCard = 'Добавить карту';
  static const cards = 'Карты и счета';
  static const card = 'Карта';
  static const account = 'Карта / счет';
  static const operationType = 'Тип операции';
  static const operationResult = 'Результат операции';
  static const completed = 'Успешно';
  static const pending = 'Выполняется';
  static const declined = 'Отклонено';
  static const mcc = 'MCC-код';
  static const outgoing = 'Списание';
  static const purchaseType = 'Оплата товаров и услуг';
  static const incoming = 'Зачисление';
  static const version = 'Версия приложения 1.2.1';
  static const back = 'Назад';
  static const close = 'Закрыть';
  static const showBalance = 'Показать баланс';
  static const hideBalance = 'Скрыть баланс';
  static const hiddenBalance = '****';
  static const noOperations = 'Операции не найдены';
  static const filter = 'Фильтр';
  static const allOperations = 'Все операции';
  static const onlyOutgoing = 'Списания';
  static const onlyIncoming = 'Зачисления';
  static const amount = 'Сумма';
  static const recipient = 'Получатель';
  static const recipientHint = 'Имя или номер получателя';
  static const amountHint = '0,00';
  static const confirmTransfer = 'Подтвердить перевод';
  static const confirmRefill = 'Пополнить счет';
  static const localActionHint =
      'Не удалось загрузить данные. Повторите попытку позже.';
  static const operationSuccess = 'Операция выполнена';
  static const emptyChat = 'Отправьте сообщение чтобы начать чат';
  static const message = 'Сообщение';
  static const send = 'Отправить';
  static const reset = 'Сбросить демонстрацию';
  static const demoControls = 'Демонстрация';
  static const demoDescription =
      'Все профили, счета и операции вымышлены. '
      'Действия выполняются локально. Сброс восстанавливает исходный сценарий.';
  static const resetDone = 'Исходный сценарий восстановлен';
  static const emptyProducts = 'У вас пока нет оформленных продуктов';
  static const productInfo = 'Информация о продукте';
  static const profile = 'Личные данные';
  static const settings = 'Настройки';
  static const firstName = 'Имя';
  static const lastName = 'Фамилия';
  static const phone = 'Телефон';
  static const safety = 'Ваша безопасность';
  static const noItem = 'Запись не найдена';
  static const available = 'Доступно';
  static const allHistory = 'Вся история';
  static const chooseProduct = 'Выберите продукт';
  static const cardNumber = 'Номер карты';
  static const cardHolder = 'Держатель';
  static const cardExpiry = 'Действует до';
  static const commission = 'Комиссия';
  static const infoDescription =
      'Не удалось загрузить информацию. Повторите попытку позже.';
  static const recipientRequired = 'Укажите получателя';
  static const amountInvalid =
      'Введите положительную сумму, не более двух знаков после запятой';
  static const insufficientFunds = 'Недостаточно средств';
  static const transferFailed = 'Проверьте введенные данные';
}

final class InfoPageContent {
  const InfoPageContent(
    this.title,
    this.description, {
    this.empty = false,
    this.assetName,
    this.actionLabel,
    this.actionAsset,
    this.actionRoute,
    this.iconWidth = 25,
    this.iconHeight = 24,
    this.replayLoad = false,
  });
  final String? assetName;
  final String? actionLabel;
  final String? actionAsset;
  final String? actionRoute;
  final double iconWidth;
  final double iconHeight;
  final bool replayLoad;
  final String title;
  final String description;
  final bool empty;
}

abstract final class DemoContent {
  static const infoPages = <String, InfoPageContent>{
    '/products/credits': InfoPageContent(
      'Кредиты',
      'У вас нет действующих кредитов',
      empty: true,
      assetName: 'ic_credits_empty_list',
      actionLabel: 'Оформить кредит',
      actionAsset: 'ic_apply_credit',
      actionRoute: '/forms/credit',
      replayLoad: true,
    ),
    '/products/deposits': InfoPageContent(
      'Вклады',
      'У вас нет действующих вкладов',
      empty: true,
      assetName: 'ic_deposits_empty_list',
      iconWidth: 28,
      iconHeight: 28,
      actionLabel: 'Открыть вклад',
      actionAsset: 'ic_open_deposit',
      actionRoute: '/deposits/open',
      replayLoad: true,
    ),
    '/products/requests': InfoPageContent(
      'Заявки на продукты',
      'На данный момент заявки отсутствуют',
      empty: true,
      assetName: 'ic_empty_requests',
    ),
    '/products/halva': InfoPageContent(
      'Халва',
      'Карта для повседневных покупок.',
    ),
    '/products/salary': InfoPageContent(
      'Зарплатная карта',
      'Управляйте своими повседневными расходами и просматривайте историю в одном приложении.',
    ),
    '/documents': InfoPageContent(
      'Документы',
      'У вас пока нет документов',
      empty: true,
    ),
    '/notifications': InfoPageContent(
      'Уведомления',
      'Новых уведомлений нет',
      empty: true,
    ),
    '/currency': InfoPageContent('Курсы валют', 'BYN · USD · EUR'),
    '/currency/exchange': InfoPageContent('Обмен валют', 'Обмен валют'),
    '/loyalty': InfoPageContent(
      'Программа лояльности',
      'Здесь собраны ваши бонусы и предложения. В текущем сценарии бонусных начислений нет.',
    ),
    '/branches': InfoPageContent(
      'Отделения и банкоматы',
      'Информационный раздел отделений и банкоматов.',
    ),
    '/about': InfoPageContent('О приложении', 'Moby Space'),
    '/settings': InfoPageContent(
      'Настройки',
      'Уведомления\n\nПереводы по номеру телефона\n\nНастройки операций',
    ),
  };
}
