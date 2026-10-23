# Источники конфигурации и будущий Admin

Moby Space — прототип Space Hackathon с МТБанком. Изменяемые данные описаны
ниже; готовый Admin UI не реализован. Runtime/config и Admin UI оцениваются
отдельно. Будущая админка не должна обходить проверку полномочий и денег.

## Продуктовые данные

| Поверхность | Источник и mutable поля/defaults | Валидация | Будущие controls / permissions | Preview, publish, audit | Runtime/config | Admin UI |
| --- | --- | --- | --- | --- | --- | --- |
| Локальная реплика | `frontend/lib/core/config/` и `data/demo/demo_scenario.dart`, `core/config/demo_artwork.dart`: синтетические профили, каталоги, тексты, порядок, суммы, rates; DemoBanner title/description/actionLabel отдельно от изображения | Типы Dart, bounded input, fixtures only; неизвестные внешние предложения не выдумываются | Редактор demo fixtures/content; роль content editor | Preview empty/error/narrow/large text, reviewed Git publish и история изменений | Реализовано | Не реализован |
| Семейные тексты и навигация | `SpaceContent`, `SpaceNavigationContent`, `SpaceUiCopy`, `FamilyContent`, `ChildrenContent`, `AppCopy` | Типизированные идентификаторы, локализация, allowlisted routes | Редактор копирайта и порядка; editor | Preview обоих actor scopes; публикация Git, без изменения policy | Реализовано | Не реализован |
| Политики ребёнка | Go child policy/SpaceSettings; Flutter формы; поля лимитов, categories, internet, visibility | Server role/scope, диапазоны, daily/monthly/approval; empty categories=deny all | Разрешённые взрослому существующие поля; без обхода ownership/identity | Подтверждение формы; server command/история, child preview | Runtime UI/API реализованы | Отдельный Admin не реализован |
| Необязательные presets | `space_policy_presets.dart`: 1000/5000/500,3000/15000/1500,5000/30000/3000 minor BYN; internet false/false/true | Explicit choice, bounded constructor values; меняются только четыре поля, не age rules | Reviewed preset editor; product editor | Preview diff, ручное применение, Git publish/audit | Реализовано | Не реализован |
| Семейные деньги и цели | Go `space_model.go`/`space.go`, persisted family state; сумма/название/цель/matching | Integer minor units, finite wallet/reserves, scope, idempotency | Existing adult/child commands в пределах ролей; будущий support только audited commands | Предварительная сумма и доступный остаток; transaction+history | Реализовано | Отдельный Admin не реализован |
| Задания и поручения | Persisted tasks/errands; описание, награда, бюджет, причина отмены | Reservation, state transitions, own-money consent, компенсация отдельно | Управление уполномоченным взрослым; child submit/consent | UI confirmation, неизменяемые paid entries, server history | Реализовано | Отдельный Admin не реализован |
| Регулярные выплаты | Persisted allowances/installments; сумма, даты, daily/weekly/monthly, pause, retry | Server bounds, no hidden catch-up, frozen per-installment retry policy | Existing adult controls; ручной выбор при insufficient | Preview будущих периодов; команды/журнал, прошлое не переписывается | Реализовано | Отдельный Admin не реализован |
| Обучение | `SpaceContent`/space config и persisted lesson progress | Completion не выдаёт financial policy | Editor содержания уроков; взрослый отдельно меняет policy | Preview lesson/empty/completed, Git publish, progress audit | Реализовано | Не реализован |
| In-app inbox | `SpaceInboxContent`, persisted notices и allowlisted targets | Actor/child filtering; read не исполняет денежную команду | Разрешённые content labels; пользователь read | Deep-link tests и server history | Реализовано | Не реализован |
| OS notifications | Notification protobuf/models, DisabledNotificationProvider | NotConfigured; preferences/cursor/actor validation | Будущие личные category settings; OS permission отдельно | Delivery/TTL/privacy tests до подключения | Контракт реализован, доставки нет | Не реализован |
| Иллюстрации, fonts, emoji, icon mapping | `tools/assets/*.json`, `source_asset_paths.dart`, semantic Material glyph mapping, `source_emoji_catalog.dart` | Hash/license/runtime binding и package checks | Asset editor только для лицензированных allowlisted файлов; без arbitrary upload | Preview обоих режимов, reviewed Git publish, provenance history | Целостность и eligibility ресурсов проверяются отдельно | Не реализован |
| Темы и анимации | `core/theme`, `DemoMotion`, `tools/assets/brand.json` | Light mode, контраст/layout; timers являются demo config, не bank SLA | Reviewed design-token edits; design editor | Narrow/large text/обе ветви; Git history | Реализовано | Не реализован |

## Системные исключения

| Поверхность | Централизованный источник | Defaults / validation | Класс исключения и safe owner | Runtime/config | Admin UI |
| --- | --- | --- | --- | --- | --- |
| Auth, QR и session scope | Go application auth/pairing, SessionVault, server handlers | Bootstrap без default, минимальная длина32; TTL и role guards в коде | Security policy; разработчик/operator, без контентного Admin | Реализовано | Исключён |
| Pairing и REST SSE budgets | `api.Config.TransportLimits` в `transport_limits.go` | Pairings1000; streams6global/2session/6peer;0 выбирает default, negative rejected до DB open | Security/runtime-management; operator-owned typed config, без arbitrary UI | Реализовано | Исключён |
| gRPC admission | `grpcapi.Options` и admission layer | Request/snapshot bounds,8projection leases/16MiB, watch6global/2session/6peer | Security/runtime-management; transport maintainer | Реализовано | Исключён |
| Денежные guards и seed endowment | Go application/domain + DefaultDemoMoney, immutable ledger rules | Minor units, bounded amounts, migration-once; не редактировать live DB | Security и system-managed derived state; reviewed code/migrations | Реализовано | Исключён |
| Endpoint, SQLite path, бизнес-дата | Backend env config и `MOBY_API_URL` build config | Loopback dev, HTTPS remote; fake date явно synthetic | Infrastructure/runtime; operator, secret значения не публикуются | Реализовано | Исключён |
| Подпись и packaging | Build scripts, `tools/release/android-signing.json`, native projects | Ephemeral/permanent policy, manifests/checksums, bundle identity | Credentials и system-owned build; release maintainer | Реализовано, сборки проверяются отдельно | Исключён |
| SDK, CI и protobuf generation | Lockfiles, `.flutter-version`, `tools/proto/versions.json`, workflows | Pinned toolchains/plugins, generated drift | Infrastructure; developer/release maintainer | Реализовано | Исключён |

В таблицах нет secret values. Предлагаемые будущие controls не обещают готовую
админку и не создают новые полномочия. Права на стороннюю графику отдельно
проверяются перед распространением полного пакета.
