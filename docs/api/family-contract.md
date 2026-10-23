# Семейный backend: ответственность и инварианты

20.10.2026. [Продуктовый план](../product/family-space-v2.md).
Реализованный REST/SSE контракт описан в [OpenAPI](openapi.yaml), расширение семейных денег — в [APIv2](family-space-v2-contract.md). Этот документ фиксирует границы ответственности. Реальные банковские endpoints не подключены.

## Сущности и команды

- Actor/session/device binding: server-issued identity, роль и разрешённая область.
- Child identity/draft: неизменяемый ID, display name отдельно от verified identity,
  дата рождения/источник/статус; в стенде только synthetic data.
- Representation, family membership и scoped grants: основание и жизненный цикл
  отдельно от наличия ребёнка в списке. Прекращение связи не удаляет банковский ledger.
- Onboarding: независимые identity/representation/agreement/account/card/access states.
- Pair request: случайный challenge, исходное устройство, срок, cancel/consume status;
  reusable session token в QR не помещается.
- Policy/capabilities: ограничения банка отдельно от допустимых семейных настроек;
  возрастная группа клиента не является доказательством полномочий.
- Синтетические ledger intents/решения/история: Money в bounded positive minor units,
  BYN и источник средств; не реальные платежи банка.

Нужны команды создать/изменить child draft, отправить на synthetic verification,
подтвердить согласованную стадию оформления, создать/погасить/отменить pairing,
изменить разрешённые настройки, завершить/отозвать session/device, прекратить
семейную связь, создать и однократно решить запрос/денежный intent.
Клиент не передаёт доверенные `role`, `ownerId`, `ageGroup`, `verified=true`.

## Security и consistency gates

1. Каждая REST-команда и live-подписка проверяют session, ownership, актуальные
   scoped grants. Детский клиент не получает adult/другого ребёнка snapshot или events.
2. Pair request выдаёт доступ только исходному ожидающему устройству после
   подтверждения взрослым конкретного ребёнка. TTL проверяет сервер; cancel,
   expired и уже consumed request не активируются. Два consume конкурируют атомарно.
3. Обязательные проверки суммы/валюты/баланса/карты/канала/permissions/categories/
   лимитов выполняются сервером и повторно при решении pending intent.
   Родительское одобрение не отменяет банковский запрет или чужую область прав.
4. Решение только из pending, один intent — одно исполнение. Баланс, история,
   статус и версия меняются в одной транзакции; retry возвращает прежний результат.
5. После commit формируется событие с revision. Подписчики видят только свою
   область; reconnect получает разрешённый snapshot и не теряет изменения.
   Событие не выдаётся до успешной записи состояния.
6. Logout отзывает session/stream и очищает scoped client cache, сохраняет семью.
   Device revoke/membership removal пересчитывают именно соответствующие grants;
   их не смешивают с удалением личности/счёта или банковских обязательных записей.
7. Сетевой стенд: TLS, закрытый adult bootstrap, ограничение попыток и bounded
   запросы. Demo «любой код» изолирован от реальной банковской авторизации и
   не открыт как публичная выдача взрослой роли. Секреты не находятся в APK/Git/URL/logs.
8. QR-камера/сеть проверяются на Android/iOS release с минимальными platform
   permissions. Отказ камеры имеет ручной fallback с тем же TTL/one-time контролем.

Схема SQLite, endpoint paths, error codes, token lifecycle и transport
зафиксированы в OpenAPI и реализации Go/SQLite; не выполняются от имени
банка. Полный банковский KYC-архив, реальные документы, биометрия и карты
в семейном сервисе хакатона не хранятся.
