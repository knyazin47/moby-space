# Локальный API

Docker Compose запускает отдельный Go API с SQLite и синтетическими данными.
Нужны Docker и Compose v2. Скопируйте `deploy/.env.example` в `deploy/.env`,
замените bootstrap secret случайным значением и из корня проекта выполните:

```bash
docker compose --env-file deploy/.env -f deploy/compose.yaml up --build -d
curl http://127.0.0.1:18080/healthz
```

REST доступен на loopback18080, native gRPC без TLS — на loopback19090.
Секрет первого входа вводится в приложении; не включайте его в URL или сборку.
Для клиента на том же компьютере сетевой режим включается явно:

```bash
cd frontend
flutter run --dart-define=MOBY_API_URL=http://127.0.0.1:19090
```

Порт в `MOBY_API_URL` относится к gRPC. Адрес127.0.0.1 на телефоне указывает на
сам телефон. Для Android через USB можно использовать `adb reverse tcp:19090 tcp:19090`; для других устройств нужен свой безопасный transport. Этот Compose
публикует порты только на loopback и не настраивает внешний TLS или домены.
Без `MOBY_API_URL` клиент запускает локальную реплику без общей семьи.

Данные хранятся в отдельном named volume проекта `moby-local`. Остановка сохраняет их:

```bash
docker compose --env-file deploy/.env -f deploy/compose.yaml stop api
```

Не добавляйте `down -v`, если данные должны сохраниться. Для изменения портов,
image tag и бизнес-даты используйте локальный `deploy/.env`; значения и ограничения
API описаны в [backend README](../backend/README.md).

`build-image.sh` только собирает `moby-local-api:<MOBY_IMAGE_TAG>` и не запускает
контейнер. Образ использует Go1.27.3, read-only root filesystem и uid65532.
Локальные env-файлы, SQLite и ключи подписи не должны попадать в Git или build context.
