# Ресурсы приложения

Реестр содержит используемые приложением шрифты, emoji, собственные семейные
иллюстрации и штатную иконку приложения. Банковские UI assets, промобаннеры и
исходная банковская launcher-графика удалены. Контекст МТБанка и Space Hackathon
в описании проекта не означает права на их товарные знаки или официальный выпуск.

## Проверка

```sh
python3 tools/check_assets.py
python3 tools/check_assets.py --public
python3 tools/assets/generate_emoji_catalog.py --check
python3 tools/assets/package_native_icons.py --check
```

Оба режима проверяют SHA-256, native bindings и обратный inventory: каждый файл
изображения или шрифта в `frontend/assets` должен быть в реестре. Также охвачены
все media в Android resources и всех iOS asset catalogs, включая неиспользуемые
ресурсы; текущие launcher bindings проверяются отдельно. `--public` требует
отсутствия ресурсов с неустановленной лицензией. Сейчас asset gate проходит;
права команды на конкурсный результат и корректность attribution проверяются
отдельно. Проверка не является физической приёмкой приложения.

## Реестры и лицензии

| Реестр | Что сохранено | Условия |
| --- | --- | --- |
| `reference.json` | Девять Inter/Montserrat TTF с прежними весами и байтами | Встроенная SIL OFL 1.1 подтверждена; copyright и полные лицензии в `licenses/*-reference-OFL.txt` |
| `promo.json` | Пустой список: 11 банковских/рекламных файлов удалены | Промослоты используют существующие семейные иллюстрации проекта |
| `emoji.json`, `emoji-upstream.json` | 3011 emoji crops и 10 controls | Pinned Vanniktech Emoji 0.9.0, Apache-2.0; полная лицензия и attribution в `licenses/Emoji-*` |
| `launcher.json`, `ios-icons.json` | 18 Android resources и 15 iOS PNG | Растровые экспорты официального Material `account_balance_wallet`; Apache-2.0, источник в `material/source.json` |
| `runtime.json` | Family illustrations, TikTok Sans, Inter/Montserrat variable fonts и три прозрачных iOS LaunchImage | Иллюстрации проекта по MIT, шрифты с OFL, точные Flutter template PNG с BSD-3-Clause |
| `brand.json` | Палитра и типографика существующих новых экранов | Дизайн-токены сохранены; это не лицензия на бренд банка |
| `readme.json` | Локальные изображения из `docs/assets`: фотографии команды и реальные снимки интерфейса | SHA-256, отдельная группа и явно зафиксированное основание публикации; фотографии не получают MIT автоматически |

`../release/android-signing.json` содержит публичный pin сертификата внутренней
Android-подписи. Закрытый ключ и пароли не входят в этот реестр.

## Изображения README

Любое изображение в `docs/assets`, включая ещё не подключённый к README файл,
должно иметь запись в `readme.json`. Формат записи:

```json
{
  "schema_version": 1,
  "files": [
    {
      "path": "docs/assets/screenshots/example.png",
      "sha256": "64 lowercase hexadecimal characters",
      "group": "project_screenshot",
      "public_distribution": "manual_review_required",
      "rights_basis": "Фактический источник и основание публикации"
    }
  ]
}
```

Допустимы группы `team_photo` и `project_screenshot`. Основание `rights_basis`
заполняется по подтверждённому источнику: отдельно для пользовательских фотографий
и снимков работающих Flutter widgets с синтетическими данными. Генератор реестра
и проверка hash сами не устанавливают права, авторство или состав команды.
`eligible` означает явно принятое решение о публикации; `manual_review_required`
сохраняет открытый вопрос и блокирует `--public`, даже когда hash верен.

Обычный gate также отклоняет отсутствующий/неверный hash, незарегистрированное
изображение, неизвестную группу и пустое основание. Полный
`python3 tools/check_repository.py --public` дополнительно проверяет Markdown и
HTML image/picture paths в README. Внешние оригинальные brand marks остаются
внешними ссылками: они не входят в этот локальный manifest и не объявляются MIT.

## Штатная иконка приложения

[Официальный Material Design SVG](https://github.com/google/material-design-icons/blob/10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7/src/action/account_balance_wallet/materialicons/24px.svg)
сохранён без изменений в `material/account_balance_wallet.svg`. Полная Apache-2.0
и NOTICE находятся в `licenses/Material-Icons-*`. Это общий значок кошелька,
не новый логотип и не товарный знак МТБанка/Moby.

PNG отрисованы непосредственно из SVG в каждом целевом размере. Полные иконки
имеют белый фон; Android adaptive foreground получает штатный прозрачный отступ.
iOS 1024px экспортируется из вектора, без увеличения маленькой банковской картинки.
Имена используемых native resources, application ID и manifest bindings сохранены.
Пять неиспользуемых Android `ic_launcher.png` удалены. Три iOS LaunchImage
сохранены: это полностью прозрачные PNG 1×1, побайтно совпадающие с официальным
Flutter template. Их источник и BSD-3-Clause записаны в `runtime.json` и
`licenses/Flutter-BSD-3-Clause.txt`; storyboard bindings сохранены.

Повторная упаковка требует CairoSVG и Pillow; обычные проверки и сборка используют
готовые PNG и стандартную библиотеку Python. Зависимости ставятся только локально:

```sh
python3 -m venv .tools/icon-rasterizer
.tools/icon-rasterizer/bin/python -m pip install -r tools/assets/requirements-native.txt
.tools/icon-rasterizer/bin/python tools/assets/package_native_icons.py
python3 tools/check_assets.py --public
```

`tools/package_ios_icons.py` сохранён как совместимый вход в ту же упаковку Android
и iOS. Синтетические Android/iOS проверки находятся в `test_asset_support.py`.
Private APK extract/import scripts удалены; закрытые оригиналы для сборки не нужны.

## Emoji: независимое подтверждение

Все 56 spritesheets совпали с официальным upstream по SHA-256. Все 3011 crops
совпали по RGBA-пикселям; восемь category icons совпали побайтно. Recent/backspace
имеют идентичные RGBA-пиксели при другом PNG encoding. Размеры, Unicode, порядок
категорий и variants сохранены. Проверка зафиксирована в `emoji-upstream.json`.

Повторная проверка требует сети и Pillow, не использует APK/Java exports и
обновляет только manifest и receipt:

```sh
python3 tools/assets/verify_emoji_upstream.py
```

Официальный [Vanniktech Emoji](https://github.com/vanniktech/Emoji/tree/a411844b60060174c7826ca9ec77035b8f18abb1)
распространяется по Apache-2.0. [Noto Emoji](https://github.com/googlefonts/noto-emoji#license)
различает image resources и font files; здесь используются PNG images.

Типизированный Dart-каталог строится только из публичного `emoji.json`:

```sh
python3 tools/assets/generate_emoji_catalog.py
python3 tools/assets/generate_emoji_catalog.py --check
```

Asset gate проверяет отсутствие дрейфа между JSON и Dart. Генератор сохраняет
порядок категорий, Unicode и вложенные варианты; APK parsing ему не нужен.
