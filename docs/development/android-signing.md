# Подпись Android

Официальные build helpers поддерживают два явных режима. Это внутренняя подпись
APK, без Google Play/App Signing или банковской интеграции.

## Одноразовая подпись по умолчанию

Без настроенных permanent secrets CI создаёт отдельный RSA3072 key в закрытой
временной директории, подписывает APK, проверяет подпись через `apksigner` и
удаляет key после сборки. Случайный пароль скрывается в Actions log. Manifest
содержит `signing_mode: ephemeral`, фактический certificate digest и сообщение
`disposable identity; no update compatibility with other builds`.

Каждый такой APK имеет другую identity. Для установки вместо ранее подписанного
приложения может понадобиться ручное удаление старого приложения с потерей его
локальных данных. Build helper никогда не удаляет приложение на устройстве.
Одноразовый ключ не заменяет постоянную release identity.

## Постоянная подпись

Для совместимых обновлений владелец настраивает оба encrypted repository secrets:

- `MOBY_ANDROID_KEYSTORE_BASE64` — PKCS12 keystore с alias `moby-internal`;
- `MOBY_ANDROID_SIGNING_PASSWORD` — пароль хранилища и key.

Должны быть настроены оба значения либо ни одного; частичная конфигурация
останавливает сборку. CI восстанавливает временный keystore только на trusted
release/manual build, а pull-request source workflow не получает эти secrets.
Public SHA-256 certificate pin в `tools/release/android-signing.json` должен
соответствовать заранее проверенной release identity. Новый ключ или смена pin —
осознанное решение владельца с оценкой совместимости; автоматической ротации нет.
Private keystore и пароль не включаются в Git, manifests или release artifacts.

Для локальной сборки с существующим утверждённым keystore задайте
`MOBY_ANDROID_SIGNING_MODE=permanent`, `MOBY_ANDROID_STORE_FILE` и
`MOBY_ANDROID_STORE_PASSWORD`. Передавайте пароль через закрытую среду процесса,
не через аргументы команды и не через tracked env-файл. Скрипт проверяет
certificate pin перед упаковкой; manifest указывает `signing_mode: permanent`.
Если передан keystore без явного permanent mode, скрипт завершится с ошибкой.

Прямой `flutter build apk --release` без signing env использует development
debug identity Gradle и не создаёт проверенный manifest release helper.
Подписанный APK, совпадение certificate pin и прохождение тестов не доказывают
приёмку обновления на физическом устройстве.
