/// Copy for schedules, permissions, requests and learning. Server data remains
/// authoritative for amounts, catalogues, permissions and state transitions.
abstract final class SpaceControlContent {
  static const scheduleTitle = 'На что переводить';
  static const chooseWeekday = 'Дни регулярных переводов';
  static const chooseAtLeastOneDay = 'Выберите хотя бы один день';
  static const weekdayNames = [
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];
  static const editSchedule = 'Изменить расписание';
  static const reviewSchedule = 'Проверьте расписание';
  static const confirmSchedule = 'Сохранить расписание';
  static const scheduleStart = 'Начиная с';
  static const schedulePreviewBody =
      'Изменения относятся только к будущим начислениям. Уже созданные выплаты, их суммы и решения останутся прежними.';
  static const scheduleStartHint =
      'Первый перевод будет в выбранный день, не раньше указанной даты.';
  static const policyPreview = 'Проверьте новые правила';
  static const policyPreviewBody =
      'Правила изменятся только после подтверждения. Остальные возможности банковского обслуживания не добавляются.';
  static const confirmPolicy = 'Применить правила';
  static const policyProfiles = 'Стартовые профили';
  static const chooseProfile = 'Выбрать стартовый профиль';
  static const policyProfilesBody =
      'Это необязательные примеры для обсуждения. Выберите подходящий вариант и проверьте суммы перед применением.';
  static const presetPreviewBody =
      'Изменятся лимит на день, лимит на месяц, порог согласования и покупки в интернете. Остальные настройки и категории сохранятся. Возраст не включает профиль автоматически.';
  static const scheduleActive = 'Расписание действует';
  static const schedulePaused = 'Расписание на паузе';
  static const installmentDecision = 'Что сделать с переводом';
  static const installmentSettle =
      'Перевести эту выплату сейчас из семейного запаса? Пропущенные выплаты не отправляются вместе с ней.';
  static const installmentCancel =
      'Отменить только эту выплату? Расписание продолжит действовать.';
  static const noInstallments =
      'Завершённые и пропущенные выплаты появятся здесь.';
  static const rulesUnavailable = 'Правила пока не получены. Обновите данные.';
  static const monthTooSmall = 'Лимит на месяц должен быть не меньше дневного.';
  static const allowed = 'Разрешено';
  static const forbidden = 'Отключено';
  static const categories = 'Категории покупок';
  static const editPolicy = 'Изменить правила';
  static const editSettings = 'Настроить разделы и помощь';
  static const matchingLifetime =
      'Предел помощи действует на всю жизнь одной цели. Каждое добавление подтверждается отдельно.';
  static const notificationsPreference =
      'Сохраняется пожелание получать семейные события. Доставка уведомлений телефона пока не подключена.';
  static const lessonsUnavailable =
      'Обновите данные, чтобы получить доступные темы.';
  static const lessonReadOnly =
      'Ребёнок сам выбирает ответ в своём приложении.';
  static const lessonQuestionUnavailable =
      'Вопрос пока недоступен. Обновите данные.';
  static const requestsHint =
      'Просьбы и ответы сохраняются здесь. Пока взрослый не подтвердил просьбу, действуют прежние правила и баланс.';
  static const requestApprove = 'Подтвердить просьбу';
  static const requestReject = 'Отклонить просьбу';
  static const approvePolicy =
      'Будут сохранены именно предложенные ниже правила. Других банковских прав это не добавляет.';
  static const approveHelp =
      'Отметить просьбу о помощи подтверждённой? Это не меняет лимиты и не переводит деньги.';
  static const rejectRequest =
      'Просьба будет отклонена. Деньги и действующие правила не изменятся.';
  static const pendingRequest = 'Просьба отправлена взрослому';
  static const noRequestsBody = 'Новые просьбы и решения появятся здесь.';
  static const weeklyDays =
      'Можно выбрать несколько дней. Дата первого перевода должна быть сегодня или позже.';
  static const monthlyHint =
      'Если в месяце нет выбранного дня, перевод назначается на последний день месяца.';
  static const nextDate = 'Следующий перевод';
  static const retryCount = 'Дополнительных попыток';
  static const readTopic = 'Открыть тему';
  static const completedTopics = 'Разобранные темы';
  static const childLearningTitle = 'Учиться';
  static const adultLearningTitle = 'Обучение';
  static const learningBody = 'Разбирайся в деньгах на своих примерах.';
  static const yourProgress = 'Твой прогресс';
  static const childProgress = 'Прогресс ребёнка';
  static const beginLesson = 'Начать урок';
  static const otherTopics = 'Другие темы';
  static const allTopicsCompleted =
      'Все темы разобраны. К любой можно вернуться и повторить.';
  static String topicProgress(int done, int total) => '$done из $total тем';
  static String progressPercent(double progress) =>
      '${(progress * 100).round()}%';

  static String dated(String date) => date.split('-').reversed.join('.');
  static String nextTransfer(String date) => '$nextDate: ${dated(date)}';
  static String monthDay(int day) => '$day-го числа';
  static String attempts(int count) => '$retryCount: $count';
  static String approveMoney(String amount) =>
      'Перевести $amount из доступного семейного запаса? До подтверждения эти деньги не входят в баланс ребёнка.';
  static String skillProgress(int done, int total) =>
      '$completedTopics: $done из $total';
}
