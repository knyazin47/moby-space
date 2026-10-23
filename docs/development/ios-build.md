# iOS: сборка и установка

`mobile-release.yml` собирает Android APK и unsigned device IPA вместе.
`ios-unsigned.yml` позволяет отдельно запустить iOS build вручную. Source workflows
находятся только в `.github/workflows/`; используются Flutter3.44.6/Dart3.12.2
и macOS runner с Xcode.

По умолчанию сборка запускает локальную реплику. Собственный семейный API можно
задать через input `api_url` либо repository variable `MOBY_API_URL` без credentials.
Непустой input имеет приоритет. Сервер нужен отдельно; [локальный backend](../../deploy/README.md)
не предоставляет публичный TLS endpoint.

## Сборка на Mac

Из корня чистого committed checkout с установленными Flutter и Xcode:

```bash
bash tools/build_ios_unsigned.sh
```

Для сетевого режима предварительно задайте `MOBY_API_URL` со своим gRPC URI.
Helper выполняет `flutter build ios --release --no-codesign`, затем упаковывает
новый `Payload/Runner.app` с executable modes и framework symlinks. Выходной
каталог `frontend/build/ios/moby-unsigned/` содержит IPA, checksum и manifest
с точным source commit, API URI и build mode. Apple account для компиляции
unsigned пакета не нужен.

```bash
python3 tools/check_ios_artifacts.py /absolute/path/package.manifest.json
python3 tools/check_ios_artifacts.py --self-test
```

Checker проверяет iPhoneOS arm64 Mach-O, plist/version/id/label, frameworks,
безопасные ZIP paths, executable permissions и отсутствие embedded provisioning
profile. Self-test проверяет parser, не компиляцию или устройство.

## Установка

Bundle ID — `dev.knyazin47.moby`, название — Moby Space. Перед установкой IPA
нужно подписать собственной Apple development identity и provisioning profile
с помощью подходящего локального инструмента. Apple Account, пароль и 2FA
вводятся только в доверенной локальной среде; в Git и Actions их нет.
Срок и условия подписи зависят от используемой Apple account/program.
App Store/TestFlight distribution в этом проекте не настроена.

После установки отдельно проверяются запуск, камера/QR, Keychain, клавиатура,
lifecycle, повторный вход и работа нескольких устройств. Сборка и package checker
не подтверждают эти сценарии; `physical_device_verified` в manifest остаётся `false`.
