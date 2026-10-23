#!/usr/bin/env bash
set -euo pipefail
task_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$task_root/tools/lib/toolchain.sh"
task_protoc="$(moby_resolve_tool MOBY_PROTOC_BIN protoc "$task_root/.tools/protoc-36.2/bin/protoc")"
task_dart="$(moby_resolve_tool MOBY_DART_BIN dart "$task_root/.tools/flutter-3.44.6/bin/dart")"
if [[ "$("$task_protoc" --version)" != 'libprotoc 36.2' ]]; then
  echo 'Dart generation requires pinned protoc 36.2.' >&2
  exit 2
fi
export PUB_CACHE="${PUB_CACHE:-$task_root/.tools/pub-cache}"
cd "$task_root/frontend"
"$task_dart" pub deps --json | python3 -c 'import json,sys; d=json.load(sys.stdin); assert any(p["name"]=="protoc_plugin" and p["version"]=="25.1.0" for p in d["packages"]), "Pinned protoc_plugin 25.1.0 required"'
task_tmp="$(mktemp -d)"
trap 'rm -rf -- "$task_tmp"' EXIT
cat > "$task_tmp/protoc-gen-dart" <<'PLUGIN'
#!/usr/bin/env bash
set -euo pipefail
exec "$MOBY_CODEGEN_DART" run protoc_plugin:protoc_plugin
PLUGIN
chmod +x "$task_tmp/protoc-gen-dart"
export MOBY_CODEGEN_DART="$task_dart"
mapfile -d "" proto_sources < <(find "$task_root/proto/moby" -name "*.proto" -print0 | sort -z)
"$task_protoc" \
  --proto_path="$task_root/proto" \
  --plugin="protoc-gen-dart=$task_tmp/protoc-gen-dart" \
  --dart_out="grpc:$task_root/frontend/lib/data/server/generated" \
  "${proto_sources[@]}"
