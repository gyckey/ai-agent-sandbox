#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TASK_TITLE="${2:-task}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

on_error() {
echo "[ERROR] task failed: ${TASK_ID}"
"${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "blocked" || true
}
trap on_error ERR

echo "[INFO] start task: ${TASK_ID} - ${TASK_TITLE}"
"${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "running"

# TODO: 在这里接真实 agent 执行逻辑
sleep 1

"${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "done"
"${SCRIPT_DIR}/notify-done.sh" "${TASK_ID}" "${TASK_TITLE}"

echo "[INFO] task done: ${TASK_ID}"
