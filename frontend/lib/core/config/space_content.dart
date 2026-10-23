/// Mutable public copy for the family workspace. Lesson bodies and entity
/// titles come from the server; permissions and transitions remain server-owned.
abstract final class SpaceContent {
  static const brand = 'Moby';
  static const bank = 'МТБанк';
  static const childNav = ['Moby', 'Деньги', 'Дела', 'Цели', 'Учиться'];
  static const home = 'Moby';
  static const money = 'Деньги';
  static const goals = 'Цели';
  static const development = 'Развитие';
  static const more = 'Ещё';
  static const familySpace = 'Семейное пространство';
  static const childSpace = 'Моё пространство';
  static const available = 'На покупки';
  static const adultAvailable = 'Доступно для семьи';
  static const reserved = 'Отложено на дела и поручения';
  static const walletDescription =
      'Общий запас для карманных денег, наград и помощи с целями.';
  static const walletOpeningDescription =
      'Стартовая сумма выделяется один раз. Переводы и награды уменьшают доступный запас.';
  static const savingsSeparate =
      'Накопления на цели хранятся отдельно от денег на покупки.';
  static const errandBudgetSeparate =
      'Бюджет поручения хранится отдельно от денег на покупки.';
  static const week = 'За неделю';
  static const incoming = 'Получено';
  static const spent = 'Потрачено';
  static const saved = 'Отложено на цели';
  static const tasksCompleted = 'Дел завершено';
  static const lessonsCompleted = 'Уроков пройдено';
  static const tasks = 'Дела';
  static const errands = 'Поручения';
  static const allowances = 'Карманные деньги';
  static const installments = 'Ближайшие переводы';
  static const requests = 'Просьбы';
  static const settings = 'Настройки';
  static const lessons = 'Уроки';
  static const skills = 'Навыки';
  static const progress = 'Мой прогресс';
  static const history = 'История';
  static const notifications = 'Уведомления';
  static const profile = 'Профиль';
  static const safety = 'Безопасность';
  static const limits = 'Лимиты и разрешения';
  static const account = 'Карта и счёт';
  static const family = 'Семья';
  static const title = 'Название';
  static const titleHint = 'Коротко опишите';
  static const amount = 'Сумма';
  static const amountHint = '0,00';
  static const targetAmount = 'Сколько нужно накопить';
  static const savedAmount = 'Уже накоплено';
  static const matchedAmount = 'Добавлено родителем';
  static const matchingAvailable = 'Можно добавить к цели';
  static const reward = 'Награда';
  static const budget = 'Бюджет покупки';
  static const actualAmount = 'Сколько потрачено';
  static const returnedAmount = 'Возвращено';
  static const remainder = 'Остаток бюджета';
  static const funding = 'Деньги на покупку';
  static const deadline = 'Дата';
  static const nextDate = 'Первый перевод';
  static const dueDate = 'Дата перевода';
  static const frequency = 'Как часто';
  static const weekdays = 'Дни недели';
  static const monthDay = 'День месяца';
  static const retryLimit = 'Повторы при нехватке денег';
  static const receipt = 'Покупка и сумма';
  static const reimbursement = 'Купить за свои с возвратом';
  static const ownMoneyConsent =
      'Согласен купить за свои деньги. После подтверждения родитель вернёт сумму покупки.';
  static const ownMoneyConsentRequired =
      'Для покупки за свои деньги нужно ваше согласие.';
  static const returnConfirmation = 'Подтвердить возврат остатка';
  static const returnHint =
      'Верните оставшийся бюджет перед подтверждением поручения.';
  static const matching = 'Помощь с целями';
  static const matchingEnabled = 'Добавлять деньги к накоплениям';
  static const matchingPercent = 'Процент помощи';
  static const matchingCap = 'Максимум помощи на цель';
  static const matchingHint =
      'Вы сами подтверждаете каждое добавление. Деньги берутся из семейного запаса.';
  static const learningHint = 'Разбирайтесь с деньгами в своём темпе.';
  static const learningRightsHint = 'Уроки не меняют лимиты и разрешения.';
  static const policyRequest = 'Попросить изменить лимиты';
  static const helpRequest = 'Попросить помощи';
  static const requestTitle = 'О чём попросить';
  static const proposedPolicy = 'Предложенные лимиты';
  static const pendingRequests = 'Ждут ответа';
  static const newGoal = 'Новая цель';
  static const newTask = 'Новое дело';
  static const newErrand = 'Новое поручение';
  static const newAllowance = 'Настроить переводы';
  static const newRequest = 'Новая просьба';
  static const transferMoney = 'Перевести ребёнку';
  static const requestMoney = 'Попросить денег';
  static const checkAnswer = 'Проверить ответ';
  static const chooseAnswer = 'Выберите ответ';
  static const answerCorrect = 'Верно! Урок пройден.';
  static const create = 'Создать';
  static const save = 'Сохранить';
  static const cancel = 'Отмена';
  static const close = 'Закрыть';
  static const back = 'Назад';
  static const confirm = 'Подтвердить';
  static const refresh = 'Обновить';
  static const retry = 'Повторить';
  static const open = 'Открыть';
  static const done = 'Готово';
  static const seeAll = 'Смотреть все';
  static const logout = 'Выйти';
  static const busy = 'Сохраняем…';
  static const loading = 'Загружаем…';
  static const success = 'Изменения сохранены';
  static const unavailable = 'Пространство пока недоступно';
  static const unavailableBody = 'Обновите данные и попробуйте ещё раз.';
  static const invalidResponse =
      'Не удалось проверить данные. Обновите пространство.';
  static const amountInvalid =
      'Введите сумму больше нуля, не более двух знаков после запятой.';
  static const titleRequired = 'Добавьте название.';
  static const dateInvalid = 'Выберите сегодня или будущую дату.';
  static const emptyGoals = 'Пока нет целей';
  static const emptyGoalsBody =
      'Выберите, на что хотите накопить, и создайте первую цель.';
  static const emptyTasks = 'Пока нет дел';
  static const emptyTasksBody = 'Новые предложения от родителя появятся здесь.';
  static const emptyErrands = 'Пока нет поручений';
  static const emptyErrandsBody =
      'Здесь будут покупки для семьи с отдельным бюджетом.';
  static const emptyAllowances = 'Регулярные переводы пока не настроены';
  static const emptyInstallments = 'Пока нет запланированных переводов';
  static const emptyRequests = 'Пока нет просьб';
  static const emptyRequestsBody =
      'Здесь можно попросить помощи или обсудить лимиты.';
  static const emptyLessons = 'Уроки пока недоступны';
  static const emptyProgress = 'Прогресс появится после первого урока';
  static const emptyHistory = 'Пока нет операций';
  static const noChild = 'Выберите профиль ребёнка';
  static const completedLesson = 'Урок пройден';
  static const completeLesson = 'Я разобрался';
  static const pendingReview = 'Ждёт ответа родителя';
  static const notAvailable = 'Недоступно';
  static const unknownStatus = 'Статус обновляется';

  static const statusLabels = <String, String>{
    'offered': 'Предложено',
    'accepted': 'В работе',
    'submitted': 'На проверке',
    'approved': 'Подтверждено',
    'paid': 'Выплачено',
    'clarification': 'Нужно уточнить',
    'disputed': 'Нужно обсудить',
    'canceled': 'Отменено',
    'cancelled': 'Отменено',
    'pending': 'Ждёт ответа',
    'denied': 'Отклонено',
    'rejected': 'Отклонено',
    'declined': 'Отклонено',
    'done': 'Выполнено',
    'settled': 'Переведено',
    'insufficient': 'Не хватает денег',
    'missed': 'Перевод пропущен',
    'active': 'Действует',
    'paused': 'На паузе',
    'completed': 'Завершено',
    'funded': 'Бюджет выделен',
    'awaiting_funds': 'Ждёт выделения денег',
    'reimburse': 'Покупка за свои с возвратом',
    'available': 'Можно добавить',
    'not_eligible': 'Пока нельзя добавить',
    'disabled': 'Помощь выключена',
    'cap_reached': 'Лимит помощи достигнут',
    'goal_complete': 'Цель достигнута',
    'no_contribution': 'Сначала пополните цель',
  };
  static const actionLabels = <String, String>{
    'deposit': 'Пополнить цель',
    'withdraw': 'Вернуть на покупки',
    'match': 'Помочь с целью',
    'accept': 'Взяться',
    'submit': 'Отправить на проверку',
    'dispute': 'Обсудить',
    'agree_cancel': 'Согласиться на отмену',
    'approve': 'Подтвердить',
    'decline': 'Отклонить',
    'clarify': 'Попросить уточнить',
    'cancel': 'Отменить',
    'request_cancel': 'Предложить отмену',
    'fund': 'Выделить деньги',
    'return': 'Вернуть остаток',
    'pause': 'Приостановить',
    'resume': 'Возобновить',
    'settle': 'Перевести сейчас',
  };
  static const frequencyLabels = <String, String>{
    'daily': 'Каждый день',
    'weekly': 'Каждую неделю',
    'monthly': 'Каждый месяц',
  };
  static const weekdayLabels = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
  static const skillLabels = <String, String>{
    'planning': 'Планирование',
    'saving': 'Накопления',
    'safety': 'Безопасность',
    'budgeting': 'Бюджет',
  };
  static const errorMessages = <String, String>{
    'pending_family_obligations':
        'Сначала завершите расчёты по делам и поручениям и верните деньги из целей.',
    'wrong_answer': 'Попробуйте ещё раз. Подсказка есть в уроке.',
    'not_eligible': 'Помощь пока недоступна для этой цели.',
    'insufficient_adult_balance': 'В семейном запасе не хватает денег.',
    'insufficient_balance': 'Не хватает денег на покупки.',
    'insufficient_goal_balance': 'В цели не хватает денег для возврата.',
    'matching_limit': 'Сумма превышает доступную помощь для этой цели.',
    'feature_disabled': 'Родитель пока отключил этот раздел.',
    'child_agreement_required': 'Отмену должен подтвердить ребёнок.',
    'child_return_required': returnHint,
    'own_money_consent_required': ownMoneyConsentRequired,
    'expense_locked': 'Сумма покупки уже сохранена.',
    'expense_requires_settlement': 'Сначала нужно завершить расчёт за покупку.',
    'balance_limit': 'Сумма превышает допустимый остаток.',
    'request_terminal': 'По этой просьбе уже принято решение.',
    'installment_terminal': 'Этот перевод уже завершён.',
    'invalid_task_state': 'Дело уже изменилось. Обновите данные.',
    'invalid_errand_state': 'Поручение уже изменилось. Обновите данные.',
    'invalid_action': 'Действие сейчас недоступно. Обновите данные.',
    'invalid_amount': amountInvalid,
    'invalid_actual_amount': 'Укажите потраченную сумму в пределах бюджета.',
    'invalid_reward': 'Проверьте сумму награды.',
    'invalid_schedule_date': dateInvalid,
    'invalid_allowance': 'Проверьте сумму и расписание переводов.',
    'invalid_frequency': 'Выберите частоту переводов.',
    'invalid_weekdays': 'Выберите дни недели.',
    'invalid_month_day': 'Выберите день месяца от 1 до 31.',
    'invalid_goal': 'Проверьте название и сумму цели.',
    'invalid_errand': 'Проверьте название, бюджет и награду.',
    'invalid_settings': 'Проверьте настройки помощи и разделов.',
    'invalid_policy': 'Проверьте предложенные лимиты.',
    'invalid_request': 'Проверьте текст просьбы.',
    'invalid_decision': 'Не удалось сохранить ответ. Обновите данные.',
    'invalid_command_type': 'Обновите приложение и попробуйте снова.',
    'space_unavailable': unavailableBody,
    'invalid_space_response': invalidResponse,
    'insufficient_funds': 'Не хватает доступных денег.',
    'not_found': 'Запись больше недоступна. Обновите данные.',
    'forbidden': 'Это действие недоступно для вашего профиля.',
    'unauthorized': 'Войдите снова, чтобы продолжить.',
    'invalid_input': 'Проверьте заполненные поля.',
    'invalid_command': 'Не удалось выполнить действие. Обновите данные.',
    'invalid_state': 'Состояние уже изменилось. Обновите данные.',
    'idempotency_conflict': 'Это действие уже изменилось. Обновите данные.',
    'matching_disabled': 'Помощь с целями пока выключена.',
    'return_required': 'Сначала подтвердите возврат остатка бюджета.',
    'consent_required': ownMoneyConsentRequired,
    'request_failed': 'Не удалось сохранить. Попробуйте ещё раз.',
    'network_error': 'Нет связи. Проверьте подключение и повторите попытку.',
  };

  static String statusLabel(String value) =>
      statusLabels[value] ?? unknownStatus;
  static String actionLabel(String value) => actionLabels[value] ?? confirm;
  static String frequencyLabel(String value) =>
      frequencyLabels[value] ?? notAvailable;
  static String skillLabel(String value) => skillLabels[value] ?? skills;
  static String errorMessage(String? code) =>
      errorMessages[code] ?? errorMessages['request_failed']!;
  static String greeting(String name) => 'Привет, $name';
  static String childTitle(String name) => 'Пространство: $name';
  static String lessonCount(int completed, int total) =>
      '$completed из $total уроков';
  static String goalProgress(String saved, String target) =>
      '$saved из $target';
}
