/// Inbox presentation and allowlisted section destinations. No provider URLs.
abstract final class SpaceInboxContent {
  static const open = 'Открыть';
  static const markRead = 'Отметить прочитанным';
  static const read = 'Прочитано';
  static const unread = 'Новое';
  static const readFailed = 'Не удалось отметить событие. Попробуйте ещё раз.';
  static const reading = 'Сохраняем…';
  static const minskTime = 'Время Минска';
  static const sectionsByKind = <String, String>{
    'wallet.transfer': 'money',
    'allowance.create': 'money',
    'allowance.update': 'money',
    'allowance.action': 'money',
    'allowance.paid': 'money',
    'allowance.insufficient': 'money',
    'allowance.missed': 'money',
    'request.create': 'money',
    'request.decide': 'money',
    'goal.create': 'goals',
    'goal.move': 'goals',
    'goal.match': 'goals',
    'task.create': 'work',
    'task.action': 'work',
    'errand.create': 'work',
    'errand.action': 'work',
    'lesson.complete': 'growth',
    'settings.update': 'settings',
    'card.block': 'settings',
  };

  /// Europe/Minsk has a fixed UTC+03 offset for the supported product dates.
  static String eventTime(int unixSeconds) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        unixSeconds * 1000,
        isUtc: true,
      ).add(const Duration(hours: 3));
      String pad(int value) => value.toString().padLeft(2, '0');
      return '${pad(date.day)}.${pad(date.month)}.${date.year} · '
          '${pad(date.hour)}:${pad(date.minute)}';
    } on ArgumentError {
      return '';
    }
  }
}
