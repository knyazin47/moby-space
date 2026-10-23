/// Mutable presentation copy for the server-backed «Детям» tab.
/// Server lifecycle identifiers and access rules remain outside this config.
abstract final class ChildrenContent {
  static const tabLabel = 'Детям';
  static const introTitle = 'Первые деньги.\nВместе с вами.';
  static const introBody =
      'Помогайте ребёнку управлять деньгами: пополняйте счёт и настраивайте покупки.';
  static const introImage = 'assets/brand/family-intro-glass.webp';
  static const start = 'Приступить';
  static const returnToFamily = 'К моей семье';
  static const introBenefits = <ChildrenBenefit>[
    ChildrenBenefit(
      kind: ChildrenBenefitKind.money,
      title: 'Деньги на повседневное',
      body: 'Пополняйте счёт ребёнка',
    ),
    ChildrenBenefit(
      kind: ChildrenBenefitKind.rules,
      title: 'Понятные правила',
      body: 'Настраивайте доступные покупки и лимиты',
    ),
    ChildrenBenefit(
      kind: ChildrenBenefitKind.connection,
      title: 'На связи',
      body: 'Подключите телефон ребёнка по QR',
    ),
  ];

  static const familyTitle = 'Моя семья';
  static const familyBody = 'Деньги и дела ваших детей.';
  static String walletReserved(String amount) => 'В резерве $amount';
  static String moneyRequest(String name, String amount) =>
      '$name просит $amount';
  static const needsDecision = 'Нужно ваше решение';
  static String moreMoneyRequests(int count) => 'Ещё просьб: $count';
  static String childAge(int age) {
    final lastTwo = age % 100;
    final ending = lastTwo >= 11 && lastTwo <= 14
        ? 'лет'
        : age % 10 == 1
        ? 'год'
        : age % 10 >= 2 && age % 10 <= 4
        ? 'года'
        : 'лет';
    return '$age $ending';
  }

  static const howItWorks = 'Как это работает';
  static const childrenTitle = 'Дети';
  static const add = 'Добавить';
  static const addChild = 'Добавить ребёнка';
  static const emptyTitle = 'Добавьте первого\nребёнка';
  static const emptyBody = 'Здесь появятся его счёт,\nпокупки и настройки.';
  static const profileCreated = 'Профиль создан';
  static const unfinished = 'Оформление не завершено';
  static const phoneConnected = 'Телефон подключён';
  static const phoneNotConnected = 'Телефон не подключён';
  static const accessRevoked = 'Доступ отключён';
  static const childFallbackName = 'Ребёнок';

  static const restoring = 'Загружаем вашу семью…';
  static const unavailableTitle = 'Не удалось загрузить настройки';
  static const unavailableBody =
      'Обновите данные, чтобы продолжить работу с семьёй.';
  static const retry = 'Повторить';
  static const refreshing = 'Обновляем…';
  static const completing = 'Сохраняем…';
  static const completionFailed =
      'Не удалось сохранить знакомство с разделом. Попробуйте ещё раз.';
  static const refreshFailed =
      'Не удалось обновить данные. Проверьте интернет и повторите.';
  static const disconnected = 'Соединение прервано. Восстанавливаем…';
}

enum ChildrenBenefitKind { money, rules, connection }

final class ChildrenBenefit {
  const ChildrenBenefit({
    required this.kind,
    required this.title,
    required this.body,
  });

  final ChildrenBenefitKind kind;
  final String title;
  final String body;
}
