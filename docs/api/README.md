# Контракты API

Moby Space — прототип Space Hackathon с МТБанком с синтетическими данными.

- [Family proto](../../proto/moby/family/v1/family.proto) — native gRPC/HTTP2.
- [OpenAPI](openapi.yaml) — compatibility REST/SSE.
- [Transport и совместимость](grpc-migration.md).
- [Сессии, роли и семейные состояния](family-contract.md).
- [Денежные команды v2](family-space-v2-contract.md).

Оба транспорта вызывают общие Go application-методы и сохраняют idempotency
key/fingerprint. Child scope не включает adult wallet и соседние профили.
Token не передаётся в URL/QR. Неопределённый transport error не является
подтверждённым отказом денежной команды.

Работают профили, pairing, политики, переводы/покупки, цели, задания, поручения,
выплаты, уроки, история и revoke/archive. Настоящий банк не подключён.
[OS notification messages](../../proto/moby/notifications/v1/notifications.proto)
не подключены к доставке. [Сервер](../../backend/README.md).
