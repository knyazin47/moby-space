# Выпуски Android и iOS

Версия `1.6.0+18` предназначена для первого публичного снимка Moby Space:
оба режима сохранены, ресурсы и документация подготовлены к распространению.
Пакеты этой версии собираются заново из опубликованного коммита.

Единственный источник CI — `.github/workflows/`. `mobile-release.yml` проверяет
Go backend, известные Go-уязвимости, Flutter analysis и тесты, затем собирает
Android APK и unsigned iOS IPA. Тег `v<version>` должен совпадать с версией
в `frontend/pubspec.yaml`. После успешных проверок тег создаёт prerelease;
ручной запуск сохраняет Actions artifacts без публикации release.

## Режим приложения

По умолчанию `MOBY_API_URL` пуст: сборки запускают локальную реплику с данными
в памяти. Для сетевого семейного режима задайте свой API URI через repository
variable `MOBY_API_URL` либо input `api_url` ручного запуска. Непустой input имеет приоритет.
Не включайте в URI пароль, token, query или fragment. Публичный сервер не
предоставляется: для разработки есть [локальный API](../../deploy/README.md).
Build helpers и release staging проверяют URI до подписи и упаковки: допустимы
HTTPS с корневым path или HTTP только на localhost/127.0.0.1/10.0.2.2.
Некорректный endpoint отклоняется без вывода его значения.

Тесты configured routing используют отдельный `https://api.example.invalid`
с подменённым transport. Они не обращаются к реальному endpoint и выполняются
независимо от режима собираемого приложения. Реальная Go↔Dart интеграция
проверяется в изолированной fixture в source workflow.

## Артефакты и подписи

Каждая платформа выдаёт пакет, SHA-256 и JSON manifest. Manifest содержит точный
source commit, version/build, application ID, API URI и режим приложения.
Android дополнительно указывает certificate digest, `signing_mode` и границы
совместимости обновлений. Если постоянные Actions secrets отсутствуют,
создаётся временный Android key для одной сборки. APK с такой подписью нельзя
считать совместимым обновлением ранее установленных сборок.
[Настройка постоянной подписи](android-signing.md).

IPA не подписана для установки: её нужно переподписать своей Apple identity.
[Сборка и установка iOS](ios-build.md). Build runners: Flutter3.44.6/Dart3.12.2,
Go1.27.3; Android использует JDK17, iOS — macOS/Xcode.

`prepare_mobile_release.py` перед публикацией проверяет ровно шесть файлов,
совпадение version/source/API у обеих платформ, package/checksum contracts и
signing policy. Для permanent APK дополнительно сверяется утверждённый public
certificate pin; ephemeral APK обязан явно сообщать об отсутствии update guarantee.
Существующие release assets автоматически не перезаписываются.

## Локальные сборки

Release helpers требуют чистый committed source tree, установленный Flutter
и платформенный SDK. Перед Android build выполните проверки и укажите реальное
число пройденных тестов в `MOBY_VERIFIED_TEST_COUNT`:

```bash
read -r -p "Число пройденных тестов: " MOBY_VERIFIED_TEST_COUNT
export MOBY_VERIFIED_TEST_COUNT
bash tools/build_android_release.sh
bash tools/build_ios_unsigned.sh  # только на macOS с Xcode
```

Опциональный `MOBY_API_URL` включает network build; без него получается replica.
Локальная Android сборка по умолчанию также получает одноразовую подпись.
Результаты: `frontend/build/mobile-release/` и `frontend/build/ios/moby-unsigned/`.
Проверить manifest можно без GitHub credentials:

```bash
python3 tools/check_release_artifacts.py /absolute/path/android.manifest.json
python3 tools/check_ios_artifacts.py /absolute/path/ios.manifest.json
```

Сборка, проверка package contract и физическая приёмка различаются. Камеру,
QR, Keychain/Keystore, lifecycle и работу нескольких устройств проверяют на
самих устройствах. В manifests `physical_device_verified` остаётся `false`.

Подготовка нового публичного репозитория описана в [порядке публикации](publishing.md).
