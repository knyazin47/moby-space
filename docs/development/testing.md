# Проверки исходников

Moby Space — командный прототип Space Hackathon с МТБанком. Команды ниже
проверяют synthetic сценарии без работающего публичного стенда.

## Flutter

Из `frontend/` на закреплённом SDK:

```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
flutter test test/server test/design/space_preview_test.dart test/design/children_tab_preview_test.dart --dart-define=MOBY_API_URL=https://api.example.invalid
```

`.invalid` включает сетевую маршрутизацию; тесты подставляют локальные transports
и sessions. Соединение с этим адресом не требуется. Suite сохраняет проверки
обоих режимов, денежных правил, QR, sessions и outbox. Design-тесты проверяют
layout/действия. PNG сохраняются только при явном `MOBY_CAPTURE_DIR` для
design-тестов или `MOBY_PREVIEW_DIR` для `test/ui/app_flow_test.dart`.
UI suite также проверяет прокрутку ошибки оформления карты до кнопки закрытия
на экране 320×740 при масштабе текста 1.3.

## Go

Из `backend/`:

```sh
go vet ./...
go test ./...
CGO_ENABLED=1 go test -race ./...
go run golang.org/x/vuln/cmd/govulncheck@v1.9.0 ./...
```

Race требует C compiler. Tests используют временные SQLite/порты без runtime
credentials. Vulnerability scan требует актуальной базы advisories.

## Контракты и ресурсы

Из корня после разрешения Flutter-зависимостей. Генерация Go/Dart-контрактов
требует Linux и Bash 4.4+ (`mapfile -d`); штатный macOS Bash 3.2 для этих
скриптов не подходит. Это отдельное требование codegen, а не сборки iOS:

```sh
python3 tools/check_assets.py --public
python3 tools/test_build_config.py
python3 tools/test_repository.py
python3 tools/assets/test_asset_support.py
python3 tools/check_ios_artifacts.py --self-test
tools/proto/generate_go.sh
tools/proto/generate_dart.sh
git diff --exit-code -- backend/gen frontend/lib/data/server/generated
tools/integration/run_grpc_smoke.sh
python3 tools/check_repository.py
```

Interop запускает временный Go-процесс и настоящий Dart на loopback.
Опциональный TLS proxy также изолирован и не меняет хост. Analysis/tests,
Android APK build, macOS IPA build и физическая приёмка — разные результаты.
Камера, Keystore/Keychain, фон и работа телефонов требуют отдельной проверки.

Source CI запускается на каждом push в main и на pull request. Проверка
публикуемых путей отклоняет runtime-файлы, включая SQLite WAL/SHM/journal,
даже если они принудительно добавлены в Git вопреки ignore-правилам.
