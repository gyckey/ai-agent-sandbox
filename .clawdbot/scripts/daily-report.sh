#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# Load optional .env for TG_BOT_TOKEN / TG_CHAT_ID, etc.
ENV_FILE="${REPO_ROOT}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

TASK_FILE="${REPO_ROOT}/.clawdbot/active-tasks.json"

if [[ ! -f "$TASK_FILE" ]]; then
  echo "[ERROR] missing $TASK_FILE"
  exit 1
fi

if ! command -v jq > /dev/null 2>&1; then
  echo "[ERROR] jq is required (brew install jq)"
  exit 1
fi

DONE_COUNT="$(jq '[.[] | select(.status=="done")] | length' "$TASK_FILE")"
BLOCKED_COUNT="$(jq '[.[] | select(.status=="blocked")] | length' "$TASK_FILE")"
TODO_COUNT="$(jq '[.[] | select(.status=="todo")] | length' "$TASK_FILE")"
RUNNING_COUNT="$(jq '[.[] | select(.status=="running")] | length' "$TASK_FILE")"

# GitHub open PR count (optional fallback)
if command -v gh > /dev/null 2>&1; then
  OPEN_PR_COUNT="$(gh pr list --state open --json number 2> /dev/null | jq 'length' 2> /dev/null || echo 0)"
else
  OPEN_PR_COUNT="N/A"
fi

REPORT="📊 Daily Agent Report
✅ done: ${DONE_COUNT}
🟡 running: ${RUNNING_COUNT}
📝 todo: ${TODO_COUNT}
⛔ blocked: ${BLOCKED_COUNT}
🔀 open PRs: ${OPEN_PR_COUNT}"

if [[ -n "${TG_BOT_TOKEN:-}" && -n "${TG_CHAT_ID:-}" ]]; then
  if curl -sS -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TG_CHAT_ID}" \
    --data-urlencode "text=${REPORT}" > /dev/null; then
    echo "[INFO] report sent to Telegram"
  else
    echo "[WARN] telegram report failed; print report:"
    echo "$REPORT"
  fi
else
  echo "[WARN] TG_BOT_TOKEN or TG_CHAT_ID missing; print report:"
  echo "$REPORT"
fi
