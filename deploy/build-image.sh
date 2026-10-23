#!/usr/bin/env bash
set -Eeuo pipefail
task_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
task_tag="${MOBY_IMAGE_TAG:-dev}"
docker build --tag "moby-local-api:${task_tag}" --file "$task_root/deploy/Dockerfile" "$task_root"
