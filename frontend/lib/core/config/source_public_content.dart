/// Public article visible at 171s of the supplied recording. No account data.
/// Link labels are observed; destinations except mtbank.by are not recorded.
abstract final class SourceSafetyContent {
  static const title = 'Ваша безопасность';
  static const heading = 'Как уберечь свои счета от мошенников?';
  static const paragraphs = <List<SafetyRun>>[
    [
      SafetyRun(
        'Уважаемый клиент! Команда специалистов МТБанка каждый день работает над тем, чтобы ваши средства хранились и приумножались в условиях максимальной безопасности. К сожалению, мошенники тоже стараются не отставать: мы постоянно получаем информацию о новых способах обмана и отъема денежных средств.',
      ),
    ],
    [
      SafetyRun(
        'Давайте договоримся: мы продолжим усиливать меры безопасности, а вы, со своей стороны, будете внимательными и бдительными. Пожалуйста, запомните несколько важных правил.',
      ),
    ],
    [
      SafetyRun(
        '1) Не переходите по подозрительным ссылкам и не скачивайте непроверенные файлы. Если вам нужно узнать о каком-либо продукте МТБанка или установить одно из наших приложений, найдите нужную ссылку с помощью сайта ',
      ),
      SafetyRun('mtbank.by', link: true),
      SafetyRun('.'),
    ],
    [
      SafetyRun(
        '2) Даже если собеседник представляется сотрудником банка, не передавайте ему конфиденциальную информацию: паспортные данные, пин-коды.',
      ),
    ],
    [
      SafetyRun(
        '3) Никогда не торопитесь с принятием решения: мошенники зачастую используют волнение и тревогу как дополнительные факторы давления. Подробные сценарии мошенничества описаны ',
      ),
      SafetyRun('тут', link: true),
      SafetyRun('.'),
    ],
    [
      SafetyRun('4) Изучайте наши новости о безопасности персональных '),
      SafetyRun('данных', link: true),
      SafetyRun(' и как избежать телефонного '),
      SafetyRun('мошенничества', link: true),
      SafetyRun(
        ' - чем больше вы будете знать, тем сложнее будет вас ввести в заблуждение.',
      ),
    ],
    [
      SafetyRun(
        'Мы будем регулярно напоминать вам о правилах безопасности. Сохранение и приумножение ваших средств - наше общее дело!',
      ),
    ],
    [
      SafetyRun(
        'Ознакомиться с Политикой ЗАО «МТБанк» в отношении обработки персональных данных можно ',
      ),
      SafetyRun('здесь', link: true),
      SafetyRun('.'),
    ],
  ];
  static const previewTitle = 'Ссылка из статьи';
  static const previewDescription =
      'Страница временно недоступна. Повторите попытку позже.';
  static const siteDescription = 'https://www.mtbank.by';
  static const close = 'Закрыть';
  static const depositUnavailable = 'Каталог вкладов';
  static const depositDescription =
      'Не удалось загрузить предложения. Повторите попытку позже.';
}

final class SafetyRun {
  const SafetyRun(this.text, {this.link = false});
  final String text;
  final bool link;
}
