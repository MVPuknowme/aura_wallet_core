#!/usr/bin/env bash
set -uo pipefail

artifact_dir="${NODE_LEDGER_ARTIFACT_DIR:-artifacts/node-ledger}"
log_file="$artifact_dir/node-ledger.log"
summary_file="$artifact_dir/summary.json"
command_to_run="${NODE_LEDGER_COMMAND:-}"

mkdir -p "$artifact_dir"
: > "$log_file"

log() {
  printf '%s\n' "$*" | tee -a "$log_file"
}

json_escape() {
  python3 -c 'import json, sys; print(json.dumps(sys.stdin.read().rstrip("\n")))'
}

write_summary() {
  status="$1"
  exit_code="$2"
  detail="$3"
  escaped_command=$(printf '%s' "$command_to_run" | json_escape)
  escaped_detail=$(printf '%s' "$detail" | json_escape)
  escaped_log=$(printf '%s' "$log_file" | json_escape)
  cat > "$summary_file" <<JSON
{
  "status": "$status",
  "exit_code": $exit_code,
  "command": $escaped_command,
  "detail": $escaped_detail,
  "log": $escaped_log
}
JSON
}

log "Node ledger evidence build started at $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
log "Artifact directory: $artifact_dir"

if [ -z "$command_to_run" ]; then
  detail="NODE_LEDGER_COMMAND was not provided; optional node ledger support skipped."
  log "$detail"
  write_summary "skipped" 0 "$detail"
  exit 0
fi

log "Running node ledger command."
log "Command: $command_to_run"

set +e
bash -lc "$command_to_run" >> "$log_file" 2>&1
code=$?
set -e

if [ "$code" -ne 0 ]; then
  detail="Optional node ledger command failed with exit code $code; continuing preflight."
  log "$detail"
  write_summary "failed_optional" "$code" "$detail"
  exit 0
fi

detail="Node ledger command completed successfully."
log "$detail"
write_summary "success" 0 "$detail"
exit 0
