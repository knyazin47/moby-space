/// Presentation copy for goals, agreed work and family purchases.
abstract final class SpaceWorkContent {
  static const adultGoals = 'Цели ребёнка';
  static const childGoals = 'Мои цели';
  static const goalsBody = 'Небольшие шаги к тому, что важно.';
  static const remaining = 'Осталось накопить';
  static const goalReached = 'Сумма собрана';
  static const matchingDisabled = 'Родитель пока не включил поддержку целей.';
  static const matchingLifetime = 'Лимит поддержки действует на всю цель.';
  static const matchingWaiting = 'Поддержка ждёт доступных средств.';
  static const matchingNotEligible =
      'Пока нет суммы для дополнительной поддержки.';
  static const matchingHistory = 'Поддержка уже в накоплениях';
  static const goalMoveBody =
      'Деньги переходят между доступным балансом и этой целью.';
  static const confirmGoalMove = 'Подтвердить перемещение';
  static const taskConditions = 'Что сделать и при каких условиях';
  static const taskBody =
      'Дела по договорённости. Карманные деньги от них не зависят.';
  static const adultTasksEmpty = 'Предложите первое дело';
  static const adultTasksEmptyBody =
      'Опишите результат и фиксированную награду. Ребёнок сам решит, браться ли.';
  static const taskRewardHint = 'Награда поступит после проверки взрослым.';
  static const taskAcceptedHint = 'Награда зарезервирована до завершения дела.';
  static const taskPaidHint = 'Награда зачислена на деньги для покупок.';
  static const taskCancel = 'Отменить дело';
  static const cancelReason = 'Причина отмены';
  static const cancelReasonTitle = 'Почему отменяем';
  static const cancelReasonBody =
      'Причина останется в истории и будет видна ребёнку. Выплаченные деньги сохраняются.';
  static const canceledBecause = 'Причина отмены';
  static const cancelRequest = 'Взрослый предложил отменить';
  static const acceptTaskTitle = 'Взяться за дело';
  static const submitTaskBody =
      'Результат готов? Взрослый проверит дело перед выплатой награды.';
  static const approveTaskBody =
      'Награда будет переведена ребёнку один раз из зарезервированных денег.';
  static const clarifyBody =
      'Дело вернётся на уточнение. Награда останется в резерве.';
  static const errandBody =
      'Семейные покупки с отдельным бюджетом и понятной наградой.';
  static const adultErrandsEmpty = 'Поручите семейную покупку';
  static const adultErrandsEmptyBody =
      'Согласуйте бюджет, способ оплаты и награду до начала покупки.';
  static const errandPaidHint =
      'Покупка подтверждена, награда и компенсация зачислены по условиям поручения.';
  static const expenseLocked =
      'Сумма покупки уже записана. При повторной отправке укажите ту же сумму.';
  static const expenseNotRecorded =
      'Укажите фактически потраченную сумму в пределах бюджета.';
  static const zeroExpenseHint = 'Если покупки не было, можно указать 0.';
  static const returnWaiting =
      'Для завершения ребёнку нужно подтвердить возврат остатка.';
  static const returned = 'Возврат остатка подтверждён';
  static const errandCancel = 'Отменить поручение';
  static const expenseProtected =
      'Покупка уже записана. Сначала нужно завершить расчёт.';
  static const fundBody =
      'Бюджет покупки и награда перейдут в резерв семейного кошелька.';
  static const approveErrandBody =
      'Покупка будет учтена, награда и согласованная компенсация поступят ребёнку.';
  static const acceptErrandBody =
      'Проверьте бюджет и награду перед началом покупки.';
  static const consentConfirm = 'Согласиться и взяться';
  static const familyBudget = 'Бюджет семьи';
  static const fundingLater = 'Ждём бюджет от взрослого';
  static const rewardFixed = 'Награда за результат';
  static const disabledTasks =
      'Новые дела с наградой сейчас выключены. История остаётся здесь.';
  static const disabledErrands =
      'Новые поручения сейчас выключены. История остаётся здесь.';
  static const matchingAvailable = 'Можно добавить сейчас';
  static const goalHelpTitle = 'Поддержать цель';
  static String percent(int value) => '$value% от подходящих накоплений';
  static String moneyLine(String label, String amount) => '$label: $amount';
}
