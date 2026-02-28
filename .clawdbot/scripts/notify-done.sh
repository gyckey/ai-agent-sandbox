#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TITLE="${2:-Task completed}"

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

MSG="✅ Task done: ${TASK_ID}
📝 ${TITLE}"

if [[ -n "${TG_BOT_TOKEN:-}" && -n "${TG_CHAT_ID:-}" ]]; then
  if curl -sS -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    -H "Content-Type: application/json" \
    -d "{\"chat_id\":\"${TG_CHAT_ID}\",\"text\":\"${MSG}\"}" > /dev/null; then
    echo "[INFO] telegram notified"
  else
    echo "[WARN] telegram notify failed; fallback to stdout"
    echo "${MSG}"
  fi
else
  echo "[WARN] TG_BOT_TOKEN or TG_CHAT_ID missing; fallback to stdout"
  echo "${MSG}"
fi
