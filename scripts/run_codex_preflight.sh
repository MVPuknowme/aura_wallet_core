#!/usr/bin/env bash
set -uo pipefail

record_result() {
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf 'mode=%s\nattempt_result=%s\n' "$1" "$2" >> "$GITHUB_OUTPUT"
  fi
}

if [ "${USER_INPUT_FLAG:-false}" != "true" ]; then
  record_result "reference-only" "blocked"
  echo "Aura Core gate blocked execution."
  exit 1
fi

for attempt in 1 2 3; do
  echo "Attempt $attempt"
  if bash -lc "${TARGET_COMMAND:-exit 1}"; then
    record_result "execute" "success"
    exit 0
  fi
  if [ "$attempt" -lt 3 ]; then
    bash -lc "${REPAIR_COMMAND:-true}" || true
  fi
done

record_result "reference-only" "failed"
exit 1
