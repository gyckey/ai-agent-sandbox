#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
NEW_STATUS="${2:?new status required}" # todo|running|done|blocked
REASON="${3:-}"

python3 .clawdbot/scripts/update_task_status.py "$TASK_ID" "$NEW_STATUS" "$REASON"
