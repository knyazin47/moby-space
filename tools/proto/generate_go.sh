#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export GOPATH="${GOPATH:-$project_root/.tools/gopath}"
export GOCACHE="${GOCACHE:-$project_root/.tools/gocache}"
export GOBIN="$project_root/.tools/bin"
source "$project_root/tools/lib/toolchain.sh"
task_go="$(moby_resolve_tool MOBY_GO_BIN go "$project_root/.tools/go/bin/go")"
protoc_bin="${PROTOC:-$(moby_resolve_tool MOBY_PROTOC_BIN protoc "$project_root/.tools/protoc-36.2/bin/protoc")}"
export PATH="$GOBIN:$PATH"
[[ "$("$protoc_bin" --version)" == 'libprotoc 36.2' ]] || { echo 'Expected protoc 36.2' >&2; exit 1; }
"$task_go" install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.12
"$task_go" install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.6.2
mkdir -p "$project_root/backend/gen"
mapfile -d "" proto_sources < <(find "$project_root/proto/moby" -name "*.proto" -print0 | sort -z)
"$protoc_bin" -I "$project_root/proto" --go_out="$project_root/backend/gen" --go_opt=paths=source_relative --go-grpc_out="$project_root/backend/gen" --go-grpc_opt=paths=source_relative "${proto_sources[@]}"
