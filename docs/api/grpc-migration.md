# Native gRPC и compatibility REST

Moby Space, прототип Space Hackathon с МТБанком, использует типизированный
native gRPC/HTTP2 для Flutter. REST/SSE сохранён для совместимости.

Wire — protobuf, без generic method/path или JSON в bytes. FamilyService
вызывает общие Go application-методы; role/ownership, данные и денежные guards
проверяются внутри транзакции. Bearer идёт только в metadata/header.
SessionGrant выдаётся при login/pair delivery, SessionSummary не содержит token.

`FamilyApi.request(method,path,...)` — локальная совместимая facade Flutter;
transport превращает её в конкретные RPC до отправки. Endpoint входит в
идентичность secure session/outbox. HTTPS обязателен, кроме allowlisted localhost
и Android Emulator loopback. RPC reflection выключен.

`WatchSnapshots` передаёт полный scoped snapshot, затем revisions/heartbeat.
Смена сеанса, logout/revoke, slow consumer и disconnect закрывают подписку.
REST SSE и gRPC имеют отдельные ограниченные budgets; подробнее в
[сервере](../../backend/README.md).

Ошибка соединения после commit не отменяет финансовое действие. Клиент
сохраняет исходный intent/idempotency key и повторяет его после восстановления.
Присутствие false/zero/empty category policy не стирается protobuf defaults.
Generated файлы хранятся в Git; версии и воспроизводимая генерация описаны
в [proto](../../proto/README.md).

[Проверки](../development/testing.md) включают REST↔gRPC replay, child isolation,
restart, stream budgets, transport cancel и реальный Go↔Dart loopback smoke.
Запуск публичного сервера не требуется, сведения о прежнем размещении
не являются частью переносимого контракта.
