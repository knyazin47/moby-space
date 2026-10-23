# Уведомления

Moby Space — прототип Space Hackathon с МТБанком. Семейный inbox и OS-доставка
имеют разные контракты.

## Работающий inbox

События сохраняются на сервере и фильтруются по роли/ребёнку. У взрослого
показывается контекст ребёнка, время и тип. Переходы ограничены разрешёнными
разделами. Прочтение не исполняет финансовую команду: решение отдельно.

## Неподключённая основа OS push

`proto/moby/notifications/v1/notifications.proto` содержит сообщения без service.
Generated Go/Dart, immutable модели и `DisabledNotificationProvider` не подключены
к FamilySession, сети или ОС. Provider возвращает `notConfigured`.
OS permissions, FCM/HMS/APNs и фоновая доставка не реализованы.

Контракт разделяет actor-bound preferences, read, delivery ACK и cursor.
Будущая доставка должна учитывать logout, смену пользователя, повтор, TTL
и privacy preview. Foreground stream не доказывает доставку при закрытом app.
Подключение provider и проверка background/tap — отдельная будущая работа.
