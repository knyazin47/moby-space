/// Тексты детско-семейного банкинга. Экраны — lib/features/family/.
abstract final class FamilyContent {
  // Точка входа на наблюдаемом экране входа/регистрации.
  static const iAmChild = 'Я ребёнок';

  // Экран ребёнка с QR.
  static const childPairTitle = 'Привязка профиля';
  static const childPairHint =
      'Покажите этот код родителю — он отсканирует его в приложении Moby';
  static const childPairWaiting = 'Ждём подтверждения родителя';
  static const childPairSimulate =
      'Демо: удерживайте QR-код, чтобы сымитировать подтверждение';
  static const childPairCodeLabel = 'Код для ручного ввода';

  // Заглушка детской главной.
  static const childHomeTitle = 'Мои деньги';
  static const childHomeGreeting = 'Привет!';
  static const childHomeStub =
      'Это демо-заглушка детского кабинета. Родитель ещё настраивает профиль.';
  static const childMyCard = 'Моя карта';
  static const childAskMoney = 'Попросить денег у родителя';
  static const childMyOperations = 'Мои операции';

  // Родительский вход.
  static const addChild = 'Добавить ребёнка';
  static const addChildDescription = 'Карта и счёт для ребёнка 7–17 лет';
  static const familySection = 'Семья';

  // Сканер.
  static const scanTitle = 'Добавить ребёнка';
  static const scanHint = 'Наведите камеру на QR-код на экране ребёнка';
  static const cameraUnavailable = 'Камера недоступна в демо-режиме';
  static const simulateScan = 'Имитировать скан';
  static const manualCode = 'Ввести код вручную';
  static const manualCodeTitle = 'Код привязки';
  static const manualCodeHint = 'Введите код с экрана ребёнка';
  static const manualCodeInvalid =
      'Код не найден. Проверьте код и попробуйте ещё раз';
  static const manualCodeConfirm = 'Привязать';

  // Визард.
  static const wizardTitle = 'Профиль ребёнка';
  static const stepData = 'Данные ребёнка';
  static const stepConsents = 'Согласия';
  static const stepLimits = 'Лимиты';
  static const stepSummary = 'Проверьте данные';
  static const childName = 'Имя ребёнка';
  static const childNameHint = 'Например, Миша';
  static const birthDate = 'Дата рождения';
  static const birthDateHint = 'Выберите дату';
  static const ageGroup = 'Возрастная группа';
  static const ageGroup7to13 = '7–13 лет';
  static const ageGroup14to17 = '14–17 лет';
  static const ageOutOfRange =
      'Детский продукт доступен для детей от 7 до 17 лет';
  static const ageGroupMismatch =
      'Дата рождения не соответствует выбранной возрастной группе';

  // Правовые рамки (ГК РБ): формулировки согласованы с юридическим
  // блоком ТЗ. Что меняет возраст — показывается в визарде и в кабинете.
  static const legalRightsTitle = 'Права по возрасту';
  static const legalJuniorCard =
      'Договор с банком заключает родитель как законный представитель, '
      'сделки по счёту совершает родитель. Ребёнок пользуется картой '
      'только для мелких бытовых покупок в рамках лимитов. Все продукты, '
      'кроме карты, выпускает только родитель.';
  static const legalTeenCard =
      'Договор заключает ребёнок с согласия родителя в приложении. '
      'Подросток может сам оформлять разрешённые продукты, родитель '
      'может ограничить и в любой момент изменить права.';
  static const legalTeenEarningsNote =
      'Собственным заработком и стипендией подросток распоряжается сам. '
      'Ограничения действуют на средства, переводимые родителем.';

  // Согласия: набор зависит от возрастной группы.
  static const consentDealJunior =
      'Я — законный представитель ребёнка. Договор с банком заключаю я, '
      'сделки по счёту ребёнка совершаю от его имени';
  static const consentDealTeen =
      'Даю согласие на заключение ребёнком договора с банком и на его '
      'сделки в рамках установленных мной ограничений';
  static const consentDataProcessing =
      'Согласен на обработку персональных данных ребёнка';
  static const consentPackage = 'Согласен с условиями семейного пакета Moby';
  static const dailyLimit = 'Дневной лимит трат';
  static const monthlyLimit = 'Лимит трат в месяц';
  static const approvalThreshold = 'Подтверждать операции дороже';
  static const categoriesLabel = 'Запрещённые категории';
  static const adultBlocked = 'Азартные игры и категории 18+ запрещены';
  static const adultBlockedNote = 'Этот запрет нельзя отключить';
  static const next = 'Далее';
  static const confirm = 'Подтвердить';
  static const cancel = 'Отмена';
  static const status = 'Статус';

  // Лендинг семейного пакета (/family).
  static const packageTitle = 'Семейный пакет Moby';
  static const packageSubtitle =
      'Карта и сервисы для ребёнка под его возраст — вы управляете правами и лимитами';
  static const packageComposition = 'Что в пакете';
  static const packageConditions = 'Условия для семьи';
  static const packageSafety = 'Безопасность';
  static const packageCardItem = 'Карта ребёнка — физическая или цифровая';
  static const packagePocketItem =
      'Карманные деньги — регулярные переводы на траты';
  static const packageGoalItem = 'Копилка — накопление на цель';
  static const packageInsuranceItem =
      'Страхование ребёнка — предложение для пакета';
  static const packageEducationItem = 'Обучающий контент по финансам';
  static const packagePartnersItem =
      'Семейные предложения — после подключения партнёров';
  static const packageJuniorRights =
      'Оформление с законным представителем; порядок зависит от продукта';
  static const packageTeenRights =
      'Самостоятельные действия зависят от возраста, продукта и оснований';
  static const packageConditionsBody =
      'Предлагаем единый семейный пакет. Стоимость обслуживания, бонусные категории и правила начислений согласуются с банком.';
  static const packageSafetyBody =
      'Азартные игры и категории 18+ запрещены всегда. Лимиты, категории и права меняются в один тап.';
  static const issuePackage = 'Оформить пакет';

  // Визард: состав пакета, разрешения, лимиты, SMS-подтверждение.
  static const stepPackage = 'Состав пакета';
  static const stepPermissions = 'Разрешения';
  static const cardTypeLabel = 'Карта';
  static const cardDelivery = 'Получение карты';
  static const deliveryOffice = 'В отделении';
  static const deliveryCourier = 'Курьером';
  static const servicesLabel = 'Сервисы в пакете';
  static const canIssueProducts = 'Ребёнок может оформлять';
  static const canDoActions = 'Ребёнок может';
  static const pocketMoneyTitle = 'Карманные деньги';
  static const pocketAmount = 'Сумма перевода';
  static const pocketPeriod = 'Периодичность';
  static const otpTitle = 'Подтверждение оформления';
  static const otpHint = 'Введите код из SMS. Демо: 1234';
  static const otpAction = 'Оформить';

  // Доступ ребёнка в Moby.
  static const accessTitle = 'Доступ в Moby';
  static const accessHint =
      'Отсканируйте QR-код на экране ребёнка или введите код вручную';
  static const accessConsentTitle = 'Разрешить вход в Moby';
  static const accessGrantedBody =
      'Ребёнок может входить в Moby и пользоваться сервисами в рамках заданных вами ограничений';
  static const accessGrantedChip = 'Доступ открыт';
  static const accessNone = 'Нет доступа в Moby';
  static const accessGive = 'Дать доступ';

  // Успех.
  static const successTitle = 'Пакет оформлен';
  static const successBody =
      'Карта выпускается и будет готова в течение пары минут';
  static const toProducts = 'К продуктам';
  static const openChild = 'Открыть профиль ребёнка';
  static const grantAccessAction = 'Дать ребёнку доступ в Moby';
  static const later = 'Позже';

  // Кабинет ребёнка.
  static const manageTitle = 'Карта ребёнка';
  static const manageBalance = 'Баланс';
  static const manageOperations = 'Операции';
  static const freezeCard = 'Заблокировать';
  static const unfreezeCard = 'Разблокировать';
  static const limitsSection = 'Лимиты';
  static const permissionsSection = 'Разрешения';
  static const requestsSection = 'Запросы ребёнка';
  static const pendingOpsSection = 'Ждут подтверждения';
  static const requestApprove = 'Разрешить';
  static const requestDeny = 'Отклонить';
  static const opApprove = 'Подтвердить';
  static const opDeclined = 'Отклонено';
  static const opPending = 'Ждёт подтверждения';
  static const notificationsTitle = 'Уведомления';
  static const notificationsEmpty = 'Пока нет уведомлений';
  static const securitySection = 'Безопасность';
  static const lostCard = 'Карта потеряна';
  static const lostCardBody =
      'Карта будет заблокирована мгновенно. Перевыпуск бесплатный — новая карта привяжется к тому же счёту.';
  static const reissueCard = 'Перевыпустить карту';
  static const disputeOperation = 'Спорная операция';
  static const disputeBody =
      'Заявка принята. Ответим в течение 3 рабочих дней.';
  static const disputeFiled = 'Подать заявку';
  static const topUp = 'Пополнить';
  static const demoPanel = 'Демо';
  static const demoBuy = 'Покупка 15 BYN';
  static const demoBuyOver = 'Покупка 80 BYN (выше порога)';
  static const demoCasino = 'Попытка в казино';
  static const demoRequest = 'Запрос ребёнка';
}
