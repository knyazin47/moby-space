# Изображения README

## Фотографии команды

`team/team-at-hackathon.jpg` и `team/prototype-on-phone.jpg` предоставлены
участником проекта для оформления README. Это фотографии команды на
Space Hackathon with МТбанк в стартап-центре ПВТ. Файлы сохранены без изменений;
EXIF и GPS-метаданных в предоставленных JPEG нет. В README фотографии стоят
рядом по центру с одинаковой высотой, без обрезки; на узком экране переносятся.

Разрешение относится к включению фотографий в README этого проекта.
Они не распространяются по MIT-лицензии исходного кода. Для отдельного
переиспользования нужно согласование с автором фотографии.

## Скриншоты приложения

| Файл | Экран | Источник |
| --- | --- | --- |
| `screenshots/family-overview.png` | Семейный кошелёк | `space_preview_test.dart`: `adult-family-wallet 390px scale 1.0` |
| `screenshots/child-goals.png` | Цели ребёнка | `space_preview_test.dart`: `child-goals 390px scale 1.0` |
| `screenshots/child-learning.png` | Обучение | `space_preview_test.dart`: `child-lessons 390px scale 1.0` |
| `screenshots/replica-home.png` | Локальная главная | `app_flow_test.dart`: `light home, history detail, search and back share fixture operation` |

Это кадры текущего Flutter-интерфейса. Семейные экраны используют in-memory
fixture, локальный режим — demo scenario. К работающему API съёмка не обращается.
Файлы не ретушируются; данные и суммы вымышленные. В README скриншоты показаны
в одном центрированном ряду с одинаковой высотой; на узком экране ряд переносится. Кадры widget tests не
подтверждают работу камеры, secure storage или lifecycle на физических телефонах.

Повторная съёмка из `frontend/` на закреплённом Flutter SDK:

```sh
MOBY_CAPTURE_DIR="$PWD/build/readme-previews/family" flutter test --no-pub test/design/space_preview_test.dart --dart-define=MOBY_API_URL=https://example.invalid --name 'adult-family-wallet 390px scale 1.0|child-goals 390px scale 1.0|child-lessons 390px scale 1.0'
MOBY_PREVIEW_DIR="$PWD/build/readme-previews/local" flutter test --no-pub test/ui/app_flow_test.dart --plain-name 'light home, history detail, search and back share fixture operation'
```

Финальные PNG копируются из результатов съёмки. Изображения ресурсов внутри
скриншотов сохраняют условия, указанные в [реестре приложения](../../tools/assets/README.md).

## Внешние изображения

Навигация в шапке загружается через [Shields.io](https://shields.io/badges).
Кнопки используют обычный регистр и SVG высотой 36 px, с явной шириной
для масштабирования в GitHub и стилем `flat-square` без тени под текстом. Иконки стека —
внешнее SVG-изображение [Skill Icons](https://skillicons.dev/) (`flutter,dart,go,sqlite`, светлая тема);
версии записаны текстом, весь ряд иконок ведёт к описанию стека.
В разделе сборок полный робот [Android](https://cdn.jsdelivr.net/gh/devicons/devicon@v2.17.0/icons/android/android-original.svg)
загружается из Devicon v2.17.0, а [Apple](https://cdn.simpleicons.org/apple/8C96A5) —
из Simple Icons.
Они обозначают целевые платформы и ведут к workflow соответствующей сборки.
Аватары участников загружаются с их GitHub-профилей через `https://github.com/<handle>.png?size=192`;
аватар и ссылка с ником ведут на один профиль. Все пять участников показаны одинаково,
без распределения ролей или сопоставления аккаунтов с людьми на фотографиях.

Широкий баннер в шапке и логотипы StartUp Space, МТбанка и ПВТ ссылаются
на оригиналы [сайта хакатона](https://mtbankhackathon.by/). Локальных копий этих
изображений в репозитории нет. Баннер — анонс мероприятия, а не фотография награждения.

| Изображение | Оригинал |
| --- | --- |
| Space Hackathon with МТбанк — анонс | [PNG](https://static.tildacdn.biz/tild6336-3936-4435-b231-613934666361/___.png) |
| StartUp Space | [SVG](https://static.tildacdn.biz/tild6338-6264-4065-a233-333965353934/Group.svg) |
| МТбанк | [SVG](https://static.tildacdn.biz/tild3030-6664-4237-b436-663639653164/logo_ru.svg) |
| ПВТ | [SVG](https://static.tildacdn.biz/tild3034-6639-4164-b231-373130353538/Group.svg) |

Баннер и логотипы обозначают мероприятие, его организаторов и партнёра.
Открытая лицензия на их повторное распространение не подтверждена; размещение внешней ссылки не предоставляет
прав на марки или изображения и не включает их в MIT-лицензию проекта.

Хеши и основания использования всех локальных изображений находятся в
[`tools/assets/readme.json`](../../tools/assets/readme.json). Проверка
`python3 tools/check_repository.py --public` охватывает ссылки README и
локальный media inventory; условия внешних брендов требуют отдельной проверки.
