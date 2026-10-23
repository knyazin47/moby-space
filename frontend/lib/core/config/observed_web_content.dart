/// Public fragment observed at ~164.50s. Its entry and remote document are
/// unknown. No unseen login fields, submission, or bank consent are recreated.
abstract final class ObservedWebContent {
  static const toolbarTitle = '';
  static const operatorLabel = 'Наблюдаемый веб-экран';
  static const heading = 'Вход в личный кабинет';
  static const introduction =
      'Для регистрации и входа в личный кабинет, пожалуйста, ознакомься и '
      'подтверди свое согласие с документами';
  static const selectAll = 'Выбрать все';
  static const close = 'Закрыть';
  static const localNotice =
      'Не удалось загрузить документ. Повторите попытку позже.';
  static const headlessNotice =
      'Локальная HTML-страница отображается в нативном WebView. '
      'В этом режиме предпросмотра она недоступна.';
  static const sourceBoundary =
      'Воспроизведён только видимый фрагмент записи. Исходный переход неизвестен. '
      'Последний текст обрезан границей исходного кадра.';
  static const consents = <ObservedWebConsent>[
    ObservedWebConsent([
      ObservedWebText('Я ознакомлен с '),
      ObservedWebText(
        'Условиями обработки персональных данных при заключении договоров '
        'в соответствии с Публичной офертой *',
        link: true,
      ),
    ]),
    ObservedWebConsent([
      ObservedWebText('Я даю своё '),
      ObservedWebText(
        'Согласие на предоставление сведений, составляющих банковскую тайну '
        'физического лица *',
        link: true,
      ),
    ]),
    ObservedWebConsent([
      ObservedWebText('Я даю своё '),
      ObservedWebText('Согласие на передачу персональных данных *', link: true),
    ]),
    ObservedWebConsent([
      ObservedWebText('Я принимаю условия '),
      ObservedWebText('Публичной оферты *', link: true),
      ObservedWebText(' и '),
      ObservedWebText('Порядка начисления Бонусных баллов*', link: true),
    ]),
    ObservedWebConsent([
      ObservedWebText(
        'Я даю свое согласие на получение рассылки рекламно-информационного характера в',
      ),
    ], completeInRecording: false),
  ];

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  static String _consentHtml(int index) {
    final text = consents[index].runs.map((run) {
      final content = _escape(run.text);
      return run.link
          ? '<a href="#" onclick="showLocalNotice(); return false;">$content</a>'
          : '<span>$content</span>';
    }).join();
    return '<section class="consent">'
        '<div class="check-line"><input type="checkbox" id="consent-$index" '
        'class="consent-check" aria-labelledby="label-$index"></div>'
        '<div class="consent-copy" id="label-$index">$text</div></section>';
  }

  /// The observed unstyled fragment uses sans-serif text, not a web font.
  /// There are no external URLs, credentials, storage, or form submissions.
  static final html =
      '''<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'none'; img-src 'none'; font-src 'none'; base-uri 'none'; form-action 'none'">
<title>${_escape(heading)}</title>
<style>
* { box-sizing: border-box; }
html, body { margin: 0; min-height: 100%; background: #fffdff; }
body { color: #000; font-family: Arial, sans-serif; font-size: 18px; font-weight: 400; }
.web-frame { min-height: 100vh; border: 1px solid #e5e3eb; padding: 8px; }
.dialog { border: 4px solid #e5e3eb; background: #fffdff; }
.close-row { height: 32px; border-bottom: 4px solid #e5e3eb; }
.close { display: inline-block; width: 24px; height: 24px; margin: 0; border: 1px solid #e5e3eb; position: relative; vertical-align: top; }
.close::before, .close::after { position: absolute; content: ''; width: 20px; height: 1.5px; background: #000; left: 1px; top: 10px; transform: rotate(45deg); }
.close::after { transform: rotate(-45deg); }
.content { padding: 50px 10px 0; }
h1 { margin: 0 0 20px; border: 1px solid #e5e3eb; color: #3e3d4c; text-align: center; font-size: 20px; line-height: 22px; font-weight: 700; }
.intro { border: 2px solid #e5e3eb; line-height: 20px; }
.select-all, .consent { border: 2px solid #e5e3eb; }
.check-line { min-height: 20px; border-bottom: 1px solid #e5e3eb; line-height: 20px; }
input[type=checkbox] { width: 20px; height: 20px; margin: 0 1px; vertical-align: top; accent-color: #2677bd; }
.select-copy { display: inline-block; margin-left: 12px; border: 1px solid #e5e3eb; font-size: 16px; line-height: 18px; }
.consent-copy { margin-left: 12px; font-size: 16px; line-height: 17px; }
.consent-copy span, .consent-copy a { border: 1px solid #e5e3eb; }
a { color: #2b70b2; text-decoration: underline; }
</style>
</head>
<body>
<div class="web-frame"><div class="dialog">
  <div class="close-row"><a class="close" href="#" aria-label="${_escape(close)}" onclick="showLocalNotice(); return false;"></a></div>
  <main class="content" aria-description="${_escape(sourceBoundary)}">
    <h1>${_escape(heading)}</h1>
    <div class="intro">${_escape(introduction)}</div>
    <section class="select-all">
      <div class="check-line"><input type="checkbox" id="select-all" aria-labelledby="select-all-label"></div>
      <label class="select-copy" id="select-all-label" for="select-all">${_escape(selectAll)}</label>
    </section>
    ${List.generate(consents.length, _consentHtml).join('\n')}
  </main>
</div></div>
<div id="local-notice" hidden>${_escape(localNotice)}</div>
<script>
function showLocalNotice() { window.alert(document.getElementById('local-notice').textContent); }
const all = document.getElementById('select-all');
const checks = Array.from(document.querySelectorAll('.consent-check'));
all.addEventListener('change', function () {
  checks.forEach(function (box) { box.checked = all.checked; });
  all.indeterminate = false;
});
checks.forEach(function (box) {
  box.addEventListener('change', function () {
    const count = checks.filter(function (item) { return item.checked; }).length;
    all.checked = count === checks.length;
    all.indeterminate = count > 0 && count < checks.length;
  });
});
</script>
</body>
</html>''';
}

final class ObservedWebText {
  const ObservedWebText(this.text, {this.link = false});
  final String text;
  final bool link;
}

final class ObservedWebConsent {
  const ObservedWebConsent(this.runs, {this.completeInRecording = true});
  final List<ObservedWebText> runs;
  final bool completeInRecording;
}
