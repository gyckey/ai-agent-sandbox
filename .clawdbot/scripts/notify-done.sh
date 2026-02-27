#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TITLE="${2:-Task completed}"

MSG="✅ Task done: ${TASK_ID}
📝 ${TITLE}"

if [[ -n "${TG_BOT_TOKEN:-}" && -n "${TG_CHAT_ID:-}" ]]; then
curl -sS -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
-H "Content-Type: application/json" \
-d "{\"chat_id\":\"${TG_CHAT_ID}\",\"text\":\"${MSG}\"}" > /dev/null
echo "[INFO] telegram notified"
else
echo "[WARN] TG_BOT_TOKEN or TG_CHAT_ID missing; fallback to stdout"
echo "${MSG}"
fi