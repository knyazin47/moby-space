#!/usr/bin/env bash
# Explicit overrides win over PATH; ignored project caches are a final fallback.
moby_resolve_tool() {
  local override_name="$1" command_name="$2" fallback="$3" selected
  selected="${!override_name:-}"
  if [[ -n "$selected" ]]; then
    command -v -- "$selected" || { echo "Unavailable $override_name tool" >&2; return 2; }
  elif command -v -- "$command_name" >/dev/null 2>&1; then
    command -v -- "$command_name"
  elif [[ -x "$fallback" ]]; then
    printf '%s\n' "$fallback"
  else
    echo "Install $command_name or set $override_name" >&2
    return 2
  fi
}
