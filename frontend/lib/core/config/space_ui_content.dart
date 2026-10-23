/// Mutable presentation copy; domain permissions and monetary rules live on the server.
abstract final class SpaceUiCopy {
  static const monthNames = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  static String paymentDate(String value) {
    final date = DateTime.tryParse(value);
    return date == null ? value : '${date.day} ${monthNames[date.month - 1]}';
  }

  static const myMoby = 'Мой Moby';
  static const familyBack = 'Моя семья';
  static const manage = 'Управление';
  static const now = 'Сейчас';
  static const maximum = 'Максимум';
  static const moneySource = 'Источник: семейный кошелёк';
  static const moneyTransfer = 'Перевести';
  static const goalDeposit = 'Пополнить цель';
  static const goalWithdraw = 'Вернуть на покупки';
  static const goalAvailable = 'Можно отложить';
  static const goalTagline = 'На то, что тебе важно.';
  static String depositAvailable(String amount) =>
      'Для пополнения доступно $amount';
  static String rewardAfterReview(String amount) =>
      'Награда $amount после проверки';
  static String amountRange(String maximum) => maximum == '0,00 BYN'
      ? 'Нет доступных средств для этой операции.'
      : 'Введите сумму от 0,01 до $maximum';

  static const manageWallet = 'Управлять бюджетом';
  static const toGoal = 'Перевести в цель';
  static const familyWallet = 'Семейный кошелёк';
  static const distribute = 'Перевести ребёнку';
  static const topUpChild = 'Пополнить счёт';
  static String waitingRequests(int count) => 'Ждут решения: $count';
  static const overview = 'Обзор';
  static const chooseChild = 'Выберите ребёнка';
  static const spaceEntry = 'Деньги, дела и цели';
  static const spaceEntryBody =
      'Карманные, поручения и поддержка самостоятельности';
  static const hello = 'Привет';
  static const myMoney = 'Мои деньги';
  static const childMoney = 'Деньги ребёнка';
  static const canSpend = 'Можно потратить';
  static const available = 'Доступно';
  static const inGoals = 'В целях';
  static const promised = 'Награды после проверки';
  static const next = 'Ближайшее';
  static const ownGoal = 'Твоя цель';
  static const allGoals = 'Открыть цели';
  static const createGoal = 'Новая цель';
  static const goalIntro = 'Маленькие шаги к большим планам';
  static const goalBody =
      'Отложенные деньги не расходуются на обычные покупки. Ты можешь вернуть их отдельным действием.';
  static const goalName = 'На что копишь';
  static const noGoals = 'Выбери, на что хочется накопить';
  static const noGoalsBody = 'Создай цель и двигайся к ней в своём темпе.';
  static const matching = 'Поддержка родителя';
  static const matchingBody =
      'Поддержка добавляется отдельным переводом. До зачисления она не входит в накопления.';
  static const matchingCap = 'Максимальная поддержка одной цели';
  static const matchingPercent = 'Процент поддержки';
  static const moveMoney = 'Переложить деньги';
  static const askMoney = 'Попросить деньги';
  static const askMoneyBody =
      'Укажи сумму и для чего она нужна. Пока просьба не исполнена, деньги не входят в баланс.';
  static const requestReason = 'Для чего';
  static const purchase = 'Оплатить покупку';
  static const purchaseBody =
      'Сумма будет списана с денег на покупки. Если нужно согласование, появится запрос взрослому.';
  static const merchant = 'Покупка';
  static const category = 'Категория';
  static const internet = 'Покупка в интернете';
  static const noHistory = 'Здесь появятся операции';
  static const noHistoryBody =
      'Пополнения, покупки и их результаты сохраняются в истории.';
  static const noTasks = 'Пока нет предложенных дел';
  static const noTasksBody =
      'За согласованные дела можно получить дополнительную награду. Карманные деньги от них не зависят.';
  static const newTask = 'Предложить дело';
  static const taskTitle = 'Что нужно сделать';
  static const taskHint =
      'Условия и награда останутся такими после принятия. Резерв создаётся, когда ребёнок берётся за дело.';
  static const newErrand = 'Новое поручение';
  static const errandHint =
      'Бюджет покупки и награда учитываются отдельно. Деньги на поручение не смешиваются с личными тратами.';
  static const noErrands = 'Поручений пока нет';
  static const noErrandsBody =
      'Здесь будут семейные покупки с выделенным бюджетом или согласованной компенсацией.';
  static const funded = 'Выделить бюджет сейчас';
  static const waitFunding = 'Перевести позже';
  static const reimburse = 'Предложить покупку за свои';
  static const ownConsentTitle = 'Сначала покупка за свои';
  static const ownConsentBody =
      'Ты добровольно используешь свои деньги в пределах бюджета. Компенсация поступит после подтверждения взрослым. Обещанная компенсация пока не доступна для трат.';
  static const ownConsent = 'Согласен использовать свои деньги';
  static const submitExpense = 'Указать сумму покупки';
  static const confirmReturn = 'Подтвердить возврат остатка';
  static const returnBody =
      'Возвращается только неиспользованный бюджет этого поручения. Остальные деньги ребёнка не затрагиваются.';
  static const discuss = 'Нужно обсудить';
  static const disputeBody =
      'Будет сохранён спорный статус. Резерв и история остаются до согласованного решения.';
  static const cancelBody =
      'Родитель может отменить невыплаченную награду, указав причину. Уже полученные деньги и компенсация расходов ребёнка сохраняются.';
  static const confirmMoney = 'Подтвердить перевод';
  static const confirmMoneyBody =
      'Проверь сумму и получателя. Действие изменит семейный бюджет и сохранится в истории.';
  static const createSchedule = 'Настроить карманные';
  static const scheduleHint =
      'Пропущенные выплаты показываются отдельно. После пополнения они не отправятся все сразу без решения взрослого.';
  static const noSchedules = 'Расписание ещё не настроено';
  static const noSchedulesBody =
      'Согласуйте регулярную сумму и дни. Ближайший перевод будет виден здесь.';
  static const retryHint =
      '0 — только ручной повтор. До трёх повторов в следующие дни; без массовой выплаты старых пропусков.';
  static const firstDate = 'Дата первого перевода';
  static const missingFunds = 'Выплаты требуют решения';
  static const noRequests = 'Новых просьб пока нет';
  static const newRequest = 'Обсудить правило';
  static const requestPolicy = 'Попросить изменить лимиты';
  static const requestHelp = 'Обратиться за помощью';
  static const policyHint =
      'Взрослый увидит предложенные значения. До подтверждения действуют прежние правила.';
  static const settingsHint =
      'Настройки индивидуальны. Изменения действуют после сохранения и видны ребёнку.';
  static const tasksEnabled = 'Дела с наградой';
  static const errandsEnabled = 'Семейные поручения';
  static const learningEnabled = 'Учебные задания';
  static const notifyEnabled = 'Уведомления о семейных событиях';
  static const matchingEnabled = 'Помогать с накоплениями';
  static const dailyLimit = 'Лимит на день';
  static const monthlyLimit = 'Лимит на месяц';
  static const approval = 'Согласование покупок от суммы';
  static const payments = 'Покупки';
  static const transfers = 'Переводы';
  static const familyRules = 'Твои правила';
  static const rulesBody =
      'Здесь видно, какие действия доступны и какие суммы согласуются. Изменение можно обсудить со взрослым.';
  static const safetyTitle = 'Если что-то пошло не так';
  static const safetyBody =
      'Не сообщай коды и данные карты в переписке. При подозрительной покупке заблокируй карту и обратись за помощью.';
  static const blockCard = 'Заблокировать карту';
  static const unblockCard = 'Разблокировать карту';
  static const blocked = 'Карта заблокирована';
  static const blockRequested = 'Запросить блокировку';
  static const setup = 'Оформление и телефон';
  static const setupBody =
      'Проверка данных, соглашение, карта и подключение устройства';
  static const unfinished = 'Сначала завершим оформление';
  static const unfinishedBody =
      'Профиль сохранён. Денежные действия появятся после необходимых этапов оформления.';
  static const growthTitle = 'Учись на своих решениях';
  static const growthBody =
      'Разбирайся с деньгами в удобном темпе. Уроки не меняют лимиты и не оценивают тебя.';
  static const lessonAction = 'Разобрать ситуацию';
  static const lessonSubmit = 'Проверить ответ';
  static const reviewed = 'Тема разобрана';
  static const skillsBody =
      'Прогресс показывает разобранные темы, а не оценку характера или размер твоих денег.';
  static const support = 'Помощь';
  static const supportBody =
      'Отправь вопрос взрослому. Для банковских вопросов используй официальный канал помощи банка.';
  static const products = 'Возможности пакета';
  static const productsBody = 'Накопления, защита и семейные предложения';
  static const longTerm = 'Долгосрочные накопления';
  static const insurance = 'Защита ребёнка';
  static const benefits = 'Семейные предложения';
  static const productBoundary =
      'Условия и оформление этого банковского продукта требуют отдельного согласования. Здесь можно обсудить интерес с семьёй.';
  static const logout = 'Выйти';
  static const logoutBody =
      'Завершится сеанс на этом телефоне. Семья, деньги, цели и история сохранятся.';
  static const save = 'Сохранить';
  static const create = 'Создать';
  static const cancel = 'Отмена';
  static const continueLabel = 'Продолжить';
  static const refresh = 'Обновить';
  static const done = 'Готово';
  static const noData = 'Загружаем пространство';
  static const noDataBody =
      'Обновите данные. Денежные действия доступны после получения актуального состояния.';
  static const offline = 'Нет соединения. Показаны последние данные.';
  static const pendingTitle = 'Уточняем последнее действие';
  static const pendingBody =
      'Команда сохранена. Повтор проверит тот же результат и не создаст второй перевод.';
  static const retryPending = 'Проверить результат';
  static const pendingConflict =
      'Сначала уточните результат предыдущего действия.';
  static const fieldRequired = 'Заполните поле';
  static const invalidAmount =
      'Сумма должна быть положительной, до двух знаков после запятой';
  static const invalidNumber = 'Проверьте число';
  static const notificationsBody =
      'События обновляются внутри приложения. Уведомления телефона зависят от разрешений и отдельной доставки.';
  static const inboxEmpty = 'Пока нет новых событий';
  static const inboxEmptyBody =
      'Здесь сохраняются решения, переводы и изменения семейных правил.';
  static const markRead = 'Прочитано';
  static const weeklyScope =
      'В расходах учтены личные покупки и семейные поручения. Переводы в цели показаны отдельно.';
  static const activityTitle = 'Движение семейных денег';
  static const operationLabels = <String, String>{
    'purchase': 'Покупка',
    'topup': 'Пополнение',
    'goal_deposit': 'Перевод в цель',
    'goal_withdraw': 'Возврат из цели',
    'goal_match': 'Поддержка накоплений',
    'task_reward': 'Награда за дело',
    'task_complete': 'Дело завершено',
    'errand_own_spend': 'Покупка за свои',
    'errand_budget_spend': 'Покупка по поручению',
    'errand_reimbursement': 'Компенсация покупки',
    'errand_reward': 'Награда за поручение',
    'allowance': 'Карманные деньги',
  };
  static String operationLabel(String kind) =>
      operationLabels[kind] ?? fallbackTitle;
  static const fallbackTitle = 'Семейное действие';
  static String greeting(String name, bool teen) =>
      teen ? name : '$hello, $name!';
  static String ofAmount(String current, String target) =>
      '${current.replaceFirst(RegExp(r'\s*BYN$'), '')} из $target';
  static String percent(int value) => '$value%';
  static String childAge(String name, int age) => '$name · $age';
  static String availableAmount(String amount) => '$available: $amount';
}
