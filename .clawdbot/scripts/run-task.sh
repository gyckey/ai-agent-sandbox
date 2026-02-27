#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TASK_TITLE="${2:-task}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

on_error() {
  echo "[ERROR] task failed: ${TASK_ID}"
  "${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "blocked" || true
}
trap on_error ERR

# Read task type + route agent (python for portability)
SELECTED_AGENT="$(python3 - <<'PY' "$REPO_ROOT" "$TASK_ID"
import json
import os
import sys

root = sys.argv[1]
task_id = sys.argv[2]

tasks_path = os.path.join(root, '.clawdbot', 'active-tasks.json')
routing_path = os.path.join(root, '.clawdbot', 'agent-routing.json')

with open(tasks_path, 'r', encoding='utf-8') as f:
    tasks = json.load(f)
with open(routing_path, 'r', encoding='utf-8') as f:
    routing = json.load(f)

task_type = ''
for t in tasks:
    if t.get('id') == task_id:
        task_type = (t.get('type') or '').lower()
        break

agent = routing.get('default', 'codex')
for r in routing.get('routes', []):
    for kw in r.get('match', []):
        if kw.lower() in task_type:
            agent = r.get('agent', agent)
            break

print(agent)
PY
)"

echo "[INFO] start task: ${TASK_ID} - ${TASK_TITLE}"
echo "[INFO] selected agent: ${SELECTED_AGENT}"

"${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "running"

# TODO: Replace with real model command later
sleep 1

"${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "done"
"${SCRIPT_DIR}/notify-done.sh" "${TASK_ID}" "${TASK_TITLE}"

echo "[INFO] task done: ${TASK_ID}"
