# Мобильный клиент Moby Space

Flutter Android/iOS прототип Space Hackathon с МТБанком. Оба режима используют
синтетические личности и деньги, без банковского подключения.

## Локальный режим

Нужны Flutter3.44.6/Dart3.12.2 и platform SDK. Из `frontend/`:

```sh
flutter pub get --enforce-lockfile
flutter run
```

Без `MOBY_API_URL` доступны локальные главная, продукты, формы, история и чат.
Данные находятся в памяти и не синхронизируются между телефонами.

## Семейный режим

Запустите собственный [backend](../backend/README.md) или используйте
[переносимый Compose example](../deploy/README.md). Для Android Emulator,
если native gRPC сервера слушает loopback9090:

```sh
flutter run --dart-define=MOBY_API_URL=http://10.0.2.2:9090
```

Для iOS Simulator на том же компьютере используйте `http://127.0.0.1:9090`.
Compose example публикует native gRPC на19090, поэтому URL для него должен
содержать19090. На физических устройствах нужен собственный HTTPS/h2 endpoint;
публичный plaintext запрещён клиентом. Старое размещение не требуется.

Bootstrap secret вводится взрослым при первом входе; не помещайте его в
Git, dart-define, APK/IPA, URL или QR. Сеанс сохраняется через Keystore/Keychain.
Logout отзывает сеанс и сохраняет семью. Детский QR создаёт короткоживущий
запрос подключения к конкретному профилю, подтверждаемый взрослым.

Новый клиент использует native gRPC; Go сохраняет REST/SSE compatibility.
Локальная реплика не служит fallback при сетевой ошибке. Родительский стенд
односемейный, его bootstrap нельзя раздавать посетителям как общий demo login.

## Код и проверки

`lib/app` — routing/session, `core/config` — типизированный контент,
`core/theme`/`core/ui` — оформление, `features` — экраны,
`data/family` — локальная модель, `data/server` — transport/vault/outbox.

[Проверки](../docs/development/testing.md) охватывают оба режима. Snapshot-тесты
интерфейса используют локальные fixtures; opt-in PNG не нужны для обычного suite.
[Ресурсы](../tools/assets/README.md) проверяются отдельно от функциональности.

## Сборки

[Общий Android/iOS pipeline](../docs/development/releases.md) по умолчанию
собирает локальную реплику. Семейный endpoint задаётся явно. Android APK может
использовать временную development-подпись или согласованный постоянный ключ.
iOS device IPA собирается на macOS/Xcode без подписи и требует переподписи.
Успешная сборка не подтверждает физическую приёмку камеры, secure storage и фона.
