/// Mutable copy for the child draft and later synthetic identity step.
abstract final class ChildrenFormContent {
  static const title = 'Добавить ребёнка';
  static const description = 'Укажите имя и дату рождения.';
  static const name = 'Имя';
  static const birthDate = 'Дата рождения';
  static const birthDatePlaceholder = 'ДД.ММ.ГГГГ';
  static const documentHint = 'Данные по документу проверим при оформлении.';
  static const create = 'Создать профиль';
  static const creating = 'Создаём профиль…';
  static const retry = 'Повторить создание профиля';
  static const cancel = 'Отмена';
  static const invalidName = 'Введите имя ребёнка';
  static const invalidDate = 'Укажите дату рождения.';
  static const restoreError = 'Не удалось восстановить незавершённое действие.';
  static const restoreRetry = 'Повторить восстановление';
  static const pending =
      'Результат создания уточняется. Данные сохранены; повторная проверка не создаст второй профиль.';
  static const legalTitle = 'Данные по документу';
  static const legalName = 'Фамилия, имя и отчество';
  static const legalHint = 'Для показа используйте только вымышленные данные.';
  static const legalConfirm = 'Продолжить проверку';
  static const legalInvalid = 'Укажите фамилию и имя';
}
