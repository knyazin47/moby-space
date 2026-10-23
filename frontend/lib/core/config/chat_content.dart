/// Source UI copy and explicit local-demo behavior for the chat surface.
abstract final class ChatContent {
  static const title = 'Чат';
  static const empty = 'Отправьте сообщение чтобы начать чат';
  static const messageHint = 'Новое сообщение';
  static const search = 'Поиск';
  static const cancel = 'Отмена';
  static const clearSearch = 'Очистить поиск';
  static const previousMatch = 'Предыдущее совпадение';
  static const nextMatch = 'Следующее совпадение';
  static const attach = 'Прикрепить';
  static const attachmentTitle = 'Отправить';
  static const emoji = 'Эмодзи';
  static const keyboard = 'Клавиатура';
  static const recent = 'Недавние';
  static const backspace = 'Удалить символ';
  static const close = 'Закрыть';
  static const attachmentDemo = 'Нет доступных файлов';
  static const maxMessageLength = 32000;
  static const maxSearchLength = 255;
  static const maxRecentEmoji = 32;
  static const searchFade = Duration(milliseconds: 150);
  // Recording114s projects to ~300dp at360×800. Until real IME metrics arrive,
  // use this bounded replay fallback; it is not an exact device/API metric.
  static const initialEmojiPanelHeight = 300.0;
  static const attachments = <ChatAttachmentAction>[
    ChatAttachmentAction('camera', 'Камера', 'ic_camera', 24, 24),
    ChatAttachmentAction('gallery', 'Галерея', 'ic_gallery', 26, 20),
    ChatAttachmentAction('document', 'Документ', 'ic_document', 18, 24),
  ];
  static const categoryLabels = <String>[
    'Смайлы и люди',
    'Животные и природа',
    'Еда и напитки',
    'Занятия',
    'Путешествия и места',
    'Предметы',
    'Символы',
    'Флаги',
  ];

  static String matchCount(int current, int total) => '$current из $total';
}

final class ChatAttachmentAction {
  const ChatAttachmentAction(
    this.id,
    this.label,
    this.icon,
    this.iconWidth,
    this.iconHeight,
  );
  final String id;
  final String label;
  final String icon;
  final double iconWidth;
  final double iconHeight;
}
