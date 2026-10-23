# Стек и версии

Moby Space — прототип Space Hackathon с МТБанком. Закреплённые версии:

| Компонент | Версия / источник |
| --- | --- |
| Flutter / Dart | 3.44.6 / 3.12.2; `.flutter-version`, `frontend/pubspec.yaml` |
| Riverpod / GoRouter | `frontend/pubspec.lock` |
| Go | 1.27.3; `backend/go.mod` |
| SQLite | pure-Go `modernc.org/sqlite`, modules в `backend/go.mod`/`go.sum` |
| grpc-go / protobuf-go | 1.84.0 / 1.36.12 |
| Dart grpc / protobuf | 5.2.0 / 6.1.0 |
| protoc / Dart plugin | 36.2 / 25.1.0; `tools/proto/versions.json` |
| Android | Gradle wrapper и SDK targets в `frontend/android/` |
| iOS | macOS/Xcode; deployment target в native Xcode project |

Выполняйте `flutter pub get --enforce-lockfile`; не обновляйте общий lockfile
неявно через `pub upgrade`. Generated Go/Dart хранятся в Git. Служебные иконки используют встроенный
Material Icons; неиспользуемая зависимость flutter_svg исключена.

`.tools/` — необязательный игнорируемый cache. Скрипты поддерживают PATH
и явные `MOBY_GO_BIN`/`MOBY_DART_BIN` overrides. Installer protoc проверяет
SHA256 Linux x86_64 архива; для других ОС нужен проверенный protoc36.2.

Генерация контрактов выполняется на Linux с Bash 4.4+; штатный macOS Bash 3.2
не поддерживает используемый `mapfile -d`. Race detector требует C compiler.
Linux source-проверки не заменяют macOS сборку IPA. [Сборки и подпись](development/releases.md).
