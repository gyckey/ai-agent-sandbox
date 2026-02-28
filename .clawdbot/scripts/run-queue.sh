#!/usr/bin/env bash
set -euo pipefail

MAX_PARALLEL="${1:-3}"
TASK_FILE=".clawdbot/active-tasks.json"
RUN_TASK_SCRIPT=".clawdbot/scripts/run-task.sh"

if [[ ! -f "$TASK_FILE" ]]; then
  echo "[ERROR] task file not found: $TASK_FILE"
  exit 1
fi

if ! command -v jq > /dev/null 2>&1; then
  echo "[ERROR] jq is required. Install with: brew install jq"
  exit 1
fi

# bash 3.2 compatible: avoid mapfile/wait -n
TODO_LINES="$(jq -r '.[] | select(.status=="todo") | [.id, (.title // "task")] | @tsv' "$TASK_FILE")"

if [[ -z "$TODO_LINES" ]]; then
  echo "[INFO] no todo tasks"
  exit 0
fi

TOTAL="$(printf '%s\n' "$TODO_LINES" | wc -l | tr -d ' ')"
echo "[INFO] found ${TOTAL} todo tasks, max parallel=${MAX_PARALLEL}"

while IFS=$'\t' read -r task_id task_title; do
  # throttle: wait until running jobs < MAX_PARALLEL
  while true; do
    running_jobs="$(jobs -pr | wc -l | tr -d ' ')"
    if [[ "$running_jobs" -lt "$MAX_PARALLEL" ]]; then
      break
    fi
    sleep 0.2
  done

  bash "$RUN_TASK_SCRIPT" "$task_id" "$task_title" &
done <<< "$TODO_LINES"

wait
echo "[INFO] queue run complete"
