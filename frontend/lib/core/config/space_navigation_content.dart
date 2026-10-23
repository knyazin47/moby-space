/// Navigation copy and ordering. Route keys are system-owned, not admin input.
abstract final class SpaceNavigationContent {
  static const sections = <String, ({String title, String body})>{
    'money': (title: 'Деньги', body: 'Карманные, просьбы и история'),
    'work': (title: 'Дела', body: 'Задания и семейные поручения'),
    'goals': (title: 'Цели', body: 'Накопления и ваша поддержка'),
    'growth': (title: 'Обучение', body: 'Уроки и освоенные темы'),
    'settings': (title: 'Карта и правила', body: 'Лимиты, доступ и блокировка'),
  };
}
