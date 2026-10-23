#!/usr/bin/env bash
set -euo pipefail
task_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$task_root/tools/lib/toolchain.sh"
task_go="$(moby_resolve_tool MOBY_GO_BIN go "$task_root/.tools/go/bin/go")"
task_dart="$(moby_resolve_tool MOBY_DART_BIN dart "$task_root/.tools/flutter-3.44.6/bin/dart")"
task_tmp="$(mktemp -d)"
trap 'rm -rf -- "$task_tmp"' EXIT
cd "$task_root/backend"
"$task_go" build -o "$task_tmp/moby-api" ./cmd/moby-api
cd "$task_root"
MOBY_SMOKE_BINARY="$task_tmp/moby-api" "$task_dart" \
  --packages=frontend/.dart_tool/package_config.json tools/integration/grpc_smoke.dart
