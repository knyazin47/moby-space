# Семейный backend Moby Space

Go/SQLite сервер командного проекта Space Hackathon с МТБанком. Начальное
состояние: один взрослый, ноль детей, конечный синтетический бюджет.
Нет настоящих SMS/KYC, банковских документов, счетов, карт или платежей.

## Запуск

Нужен Go1.27.3. Из `backend/`:

```sh
go build -o bin/moby-api ./cmd/moby-api
```

Задайте `MOBY_BOOTSTRAP_SECRET` минимум32символа безопасным способом и запустите
`./bin/moby-api`. Не сохраняйте secret в Git, клиентской сборке или URL.
Не передавайте собственные credentials в вывод команд или bug reports.
[Compose example](../deploy/README.md) описывает изолированный локальный запуск.

| Настройка | Default / назначение |
| --- | --- |
| `MOBY_BOOTSTRAP_SECRET` | Обязательный owner secret без default |
| `MOBY_ADDR` | REST/SSE `127.0.0.1:8080` |
| `MOBY_GRPC_ADDR` | Native gRPC `127.0.0.1:9090` |
| `MOBY_DATABASE` | `data/family.sqlite`, только runtime |
| `MOBY_BUSINESS_DATE` | `2026-10-20`, synthetic дата валидации возраста |

Loopback plaintext предназначен для локальной разработки. Внешний доступ
требует собственного TLS/h2 proxy; credentials и request bodies логировать
нельзя. Один bootstrap предоставляет adult-доступ к одной семье — это не
публичная многопользовательская авторизация.

## Слои и контракты

`internal/api/application_*` реализует общие методы с role/scope, SQLite
транзакциями и денежной идемпотентностью. REST handlers и `internal/grpcapi`
вызывают эти методы. [Family proto](../proto/moby/family/v1/family.proto) —
новый wire-контракт; [OpenAPI](../docs/api/openapi.yaml) — compatibility REST.
`/healthz` находится на REST listener. Reflection gRPC не включён.

QR create/poll/cancel не являются выдачей adult-доступа; consume требует
взрослого. Детские snapshots не содержат adult wallet/данных других детей.
Logout/revoke проверяются повторно в потоках. Переподключение и повтор команды
не создают повторную выплату. Неподтверждённый transport error после commit
требует повторить исходный ключ, а не создать новый intent.

## Денежная модель

Суммы — integer minor BYN. Цели, свободный остаток, резерв награды,
бюджет поручения и ожидаемая компенсация различаются. Задания резервируют
деньги; выплата однократная. Использование своих денег ребёнком требует
явного согласия. При недостатке на группу выплат решение принимает взрослый.
Уроки и optional presets не выдают права автоматически.

Архивирование блокируется при деньгах в целях, открытых резервах и
некомпенсированных расходах. Защитная блокировка карты доступна ребёнку
отдельно от необязательных обучающих правил; разблокирует взрослый.

[Доменный контракт](../docs/api/family-space-v2-contract.md) описывает команды,
а [границы прототипа](../docs/product/safety-boundaries.md) отделяют synthetic
статусы от настоящего юридического оформления.

## Transport budgets

`api.Config.TransportLimits` — типизированные operator-owned ограничения:
pairings1000, REST streams6всего/2на session/6на peer. Нули выбирают defaults,
отрицательные значения отклоняются до открытия DB. Истёкшие pairing удаляются
при следующем create; действующий delivery retry сохраняется до своего TTL.
REST возвращает429 `watch_limit` при переполнении и освобождает lease при
отключении, отзыве и ошибке записи. Эти значения не управляются продуктовым Admin.

gRPC имеет отдельные admission budgets:8projection leases,16MiB serialized,
watch6всего/2на session/6на peer. Общий peer rate учитывает REST и gRPC;
forwarded headers не используются как доверенный источник адреса.
Ограничения snapshots/request и send timeouts не являются замером production RSS.

## Проверки

```sh
go vet ./...
go test ./...
CGO_ENABLED=1 go test -race ./...
```

Race требует C compiler. SQLite tests используют временные данные.
[Общий gate](../docs/development/testing.md) включает vulnerability scan,
generated drift и настоящий Go↔Dart loopback interop. Runtime DB, WAL,
ключи и резервные копии не входят в Git.
