# Protobuf-контракты

Moby Space — прототип Space Hackathon с МТБанком. FamilyService — типизированный
native mobile transport; notification namespace содержит только неподключённые
messages. Generated Go/Dart входят в Git.

Pins protoc36.2, Go plugins и Dart plugin находятся в `tools/proto/versions.json`.
С Linux/Bash из корня, после разрешения Flutter dependencies:

```sh
python3 tools/proto/install_compiler.py
tools/proto/generate_go.sh
tools/proto/generate_dart.sh
git diff --exit-code -- backend/gen frontend/lib/data/server/generated
```

Скрипты выбирают явные `MOBY_GO_BIN`, `MOBY_DART_BIN`, `MOBY_PROTOC_BIN`,
потом PATH, затем необязательные project-local инструменты. Installer скачивает
только проверенный по SHA256 Linux x86_64 protoc. Для других ОС установите
проверенный protoc36.2 самостоятельно.

Сохраняйте field numbers, reserve удалённых полей и presence/false/zero/empty.
Transport не должен обходить доменную идемпотентность или actor scope.
[Схема transport](../docs/api/grpc-migration.md), [проверки](../docs/development/testing.md).
