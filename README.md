<a href="https://mtbankhackathon.by/"><img src="https://static.tildacdn.biz/tild6336-3936-4435-b231-613934666361/___.png" width="100%" alt="Space Hackathon with МТбанк — 20–22 октября"></a>

<div align="center">

# Moby Space

**Карманные деньги, цели и дела в одном семейном пространстве.**

<p align="center">
  <a href="docs/stack.md"><img src="https://skillicons.dev/icons?i=flutter,dart,go,sqlite&amp;theme=light" width="288" height="64" alt="Технологии: Flutter, Dart, Go и SQLite"></a>
</p>

<p align="center">
  <strong>Flutter 3.44.6 · Dart 3.12.2 · Go 1.27.3 · SQLite</strong>
</p>

<p align="center">
  <a href="#приложение"><img src="https://img.shields.io/badge/%D0%9F%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5-2334C8?style=flat-square" width="146" height="36" alt="Приложение"></a>
  <a href="#быстрый-запуск"><img src="https://img.shields.io/badge/%D0%97%D0%B0%D0%BF%D1%83%D1%81%D1%82%D0%B8%D1%82%D1%8C-2334C8?style=flat-square" width="121" height="36" alt="Запустить"></a>
  <a href="#сборки-android-и-ios"><img src="https://img.shields.io/badge/Android%20%C2%B7%20iOS-2334C8?style=flat-square" width="149" height="36" alt="Android · iOS"></a>
  <a href="#команда"><img src="https://img.shields.io/badge/%D0%9A%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%B0-2334C8?style=flat-square" width="106" height="36" alt="Команда"></a>
</p>

</div>

Командный прототип детско-семейного банкинга для **Space Hackathon with МТбанк**.
Взрослый управляет бюджетом и правилами, ребёнок копит на цели, выполняет задания
и учится обращаться с деньгами. Flutter-клиент для Android и iOS, сервер на Go и SQLite.
Все деньги и банковские операции — демонстрационные.

## Приложение

**У взрослого — семейный бюджет. У ребёнка — свои деньги и цели.**

<p align="center">
  <a href="docs/assets/screenshots/family-overview.png"><img src="docs/assets/screenshots/family-overview.png" height="360" alt="Семейный кошелёк взрослого: доступные деньги и резервы"></a>
  <a href="docs/assets/screenshots/child-goals.png"><img src="docs/assets/screenshots/child-goals.png" height="360" alt="Цели ребёнка: накопления на наушники"></a>
  <a href="docs/assets/screenshots/child-learning.png"><img src="docs/assets/screenshots/child-learning.png" height="360" alt="Уроки финансовой грамотности и прогресс ребёнка"></a>
  <a href="docs/assets/screenshots/replica-home.png"><img src="docs/assets/screenshots/replica-home.png" height="360" alt="Главная локальной демоверсии с вымышленными данными"></a>
</p>

Взрослый создаёт задание и назначает награду. Когда ребёнок принимает задание,
деньги резервируются; после выполнения взрослый подтверждает выплату. Накопления,
доступные деньги и резервы учитываются отдельно; повтор команды не создаёт вторую выплату.

Есть лимиты расходов, регулярные карманные выплаты, уроки с сохранением прогресса
и уведомления внутри приложения. [Подробнее о семейных сценариях →](docs/product/family-space-v2.md)

## Быстрый запуск

Нужны **Flutter 3.44.6 / Dart 3.12.2** и SDK выбранной платформы.
Из корня репозитория:

```sh
cd frontend
flutter pub get --enforce-lockfile
flutter run
```

**Без сервера** откроется локальная демоверсия: главная, продукты, формы,
история и чат. Данные живут в памяти и не синхронизируются между устройствами.

**С собственным API** доступен семейный режим: отдельные сеансы взрослого
и ребёнка, сохранение состояния в SQLite и синхронизация.
При сетевой ошибке он не переключается в локальный режим.

<details>
<summary><strong>Подключить семейный режим</strong></summary>

Запустите [API через Compose](deploy/README.md) или [Go backend](backend/README.md).
Для Android Emulator и gRPC-порта Compose:

```sh
flutter run --dart-define=MOBY_API_URL=http://10.0.2.2:19090
```

Первый вход взрослого требует собственного bootstrap secret. Он вводится
в приложении и не должен попадать в URL, сборку или Git.
[Адреса для iOS Simulator и физических устройств](frontend/README.md).

</details>

## Сборки Android и iOS

Общий workflow собирает **Android APK** на Linux и **iOS device IPA** на macOS.
Пакеты, SHA-256 и manifest с версией и исходным коммитом сохраняются в Actions artifacts.
Тег `v<version>` выпускает prerelease после проверок.

iOS IPA не подписана: для установки нужна собственная Apple identity.
Для Android предусмотрена временная или постоянная подпись.
Работа на физических устройствах проверяется отдельно.

<p align="center">
  <a href=".github/workflows/mobile-release.yml"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon@v2.17.0/icons/android/android-original.svg" width="56" height="56" align="middle" alt="Android — workflow сборки APK"></a>
  &emsp; <a href="docs/development/releases.md"><strong>Сборки и артефакты →</strong></a> &emsp;
  <a href=".github/workflows/ios-unsigned.yml"><img src="https://cdn.simpleicons.org/apple/8C96A5" width="56" height="56" align="middle" alt="iOS — workflow сборки IPA"></a>
</p>

<p align="center">
  <a href="docs/development/android-signing.md">Android-подпись</a> · <a href="docs/development/ios-build.md">Установка iOS</a>
</p>

## Под капотом

```mermaid
flowchart LR
    App["Flutter · Android / iOS"] -->|"gRPC / protobuf"| API["Go API"]
    API --> DB[(SQLite)]
    App -->|"Локальный режим"| Memory["Данные в памяти"]
```

Семейный клиент использует gRPC/HTTP2; REST/SSE сохранён для совместимости.
Сервер проверяет права и денежные ограничения до записи в SQLite.
Сеансы клиента хранятся через Keystore/Keychain.

<p align="center">
  <a href="docs/architecture.md"><strong>Архитектура →</strong></a> &emsp; <a href="docs/api/README.md"><strong>API →</strong></a> &emsp; <a href="docs/development/testing.md"><strong>Разработка и тесты →</strong></a>
</p>

<details>
<summary><strong>Каталоги и проверки</strong></summary>

- [frontend](frontend/README.md) — Flutter, экраны обоих режимов, gRPC и outbox.
- [backend](backend/README.md) — Go API, SQLite, семейные команды и потоки обновлений.
- [proto](proto/moby/family/v1/family.proto) — версионированный protobuf-контракт.
- [deploy](deploy/README.md) — переносимый пример локального запуска.
- [docs](docs/architecture.md) — архитектура, продуктовые правила и инструкции.
- [tools](tools/assets/README.md) — ресурсы, сборка и генерация контрактов.

[Source CI](.github/workflows/source-checks.yml) проверяет Flutter и Go, оба режима,
Go race detector, известные Go-уязвимости, генерацию контрактов и взаимодействие
Go/Dart-клиентов. Отдельный gate проверяет ссылки, происхождение и хеши локальных изображений.

```sh
python3 tools/check_repository.py --public
cd frontend
flutter analyze --fatal-infos
flutter test
```

[Стек](docs/stack.md) · [Технические решения](docs/decisions.md)

</details>

## Хакатон

**20–22 октября 2026 · Минск · стартап-центр ПВТ**

На Space Hackathon with МТбанк мы работали над детско-семейным банкингом:
самостоятельным пакетом услуг или решением внутри Moby.

<p align="center">
  <a href="https://mtbankhackathon.by/"><img src="https://static.tildacdn.biz/tild6338-6264-4065-a233-333965353934/Group.svg" width="200" height="90" alt="StartUp Space — организатор"></a> &emsp;&emsp;
  <a href="https://www.mtbank.by/"><img src="https://static.tildacdn.biz/tild3030-6664-4237-b436-663639653164/logo_ru.svg" width="200" height="90" alt="МТбанк — генеральный партнёр хакатона"></a> &emsp;&emsp;
  <a href="https://park.by/"><img src="https://static.tildacdn.biz/tild3034-6639-4164-b231-373130353538/Group.svg" width="200" height="90" alt="Парк высоких технологий — организатор"></a>
</p>

<p align="center">
  Организаторы: <a href="https://mtbankhackathon.by/">StartUp Space</a> и <a href="https://park.by/">Парк высоких технологий</a><br>
  Генеральный партнёр: <a href="https://www.mtbank.by/">МТбанк</a>
</p>

<p align="center">
  <a href="https://mtbankhackathon.by/"><strong>О хакатоне →</strong></a> &emsp; <a href="https://spacemedia.by/news/chetvyortyj-hakaton-i-rekordnyj-interes-kak-proshyol-space-hackathon-with-mtbank-4-0/"><strong>Репортаж Space Media →</strong></a>
</p>

## Команда

<p align="center">
  <a href="docs/assets/team/team-at-hackathon.jpg"><img src="docs/assets/team/team-at-hackathon.jpg" width="46%" alt="Участники команды за рабочим столом на хакатоне"></a>
  <a href="docs/assets/team/prototype-on-phone.jpg"><img src="docs/assets/team/prototype-on-phone.jpg" width="46%" alt="Участники команды показывают прототип на телефоне"></a>
</p>

Над Moby Space работали:

<p align="center">
  <a href="https://github.com/knyazin47"><img src="https://github.com/knyazin47.png?size=192" width="96" height="96" alt="knyazin47" title="knyazin47"></a>
  <a href="https://github.com/lolmmmtech"><img src="https://github.com/lolmmmtech.png?size=192" width="96" height="96" alt="lolmmmtech" title="lolmmmtech"></a>
  <a href="https://github.com/zhalobitskaia"><img src="https://github.com/zhalobitskaia.png?size=192" width="96" height="96" alt="zhalobitskaia" title="zhalobitskaia"></a>
  <a href="https://github.com/koloideal"><img src="https://github.com/koloideal.png?size=192" width="96" height="96" alt="koloideal" title="koloideal"></a>
  <a href="https://github.com/Armovit"><img src="https://github.com/Armovit.png?size=192" width="96" height="96" alt="Armovit" title="Armovit"></a>
</p>

<p align="center">
  <a href="https://github.com/knyazin47">knyazin47</a> · <a href="https://github.com/lolmmmtech">lolmmmtech</a> · <a href="https://github.com/zhalobitskaia">zhalobitskaia</a> · <a href="https://github.com/koloideal">koloideal</a> · <a href="https://github.com/Armovit">Armovit</a>
</p>

<p align="center">
  <a href="AUTHORS.md"><strong>Участники проекта →</strong></a> &emsp; <a href="CONTRIBUTING.md"><strong>Как внести вклад →</strong></a>
</p>

## Статус и лицензия

Это хакатонный прототип на один демонстрационный семейный стенд.
Настоящих платежей, SMS/KYC,, выпуска счетов и карт нет. Уведомления работают
внутри приложения; OS push и автоматические возрастные переходы не реализованы.
[Границы данных и доступа](docs/product/safety-boundaries.md).

Код и документация — **[MIT](LICENSE)**. У фотографий и сторонних ресурсов
[отдельные условия](NOTICE.md); [источники изображений](docs/assets/README.md)
собраны отдельно.
