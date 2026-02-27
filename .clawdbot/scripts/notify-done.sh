#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TITLE="${2:-Task completed}"

echo "[DONE] ${TASK_ID} - ${TITLE}"