#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TASK_TITLE="${2:-task}"
MAX_RETRIES="${3:-2}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ROUTING_FILE="${REPO_ROOT}/.clawdbot/agent-routing.json"
TASK_FILE="${REPO_ROOT}/.clawdbot/active-tasks.json"

# Load optional .env for TG_BOT_TOKEN / TG_CHAT_ID, etc.
# 加载 .env（如果存在）
ENV_FILE="${REPO_ROOT}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

select_agent() {
  if [[ ! -f "$ROUTING_FILE" ]] || [[ ! -f "$TASK_FILE" ]]; then
    echo "codex"
    return
  fi

  task_type="$(jq -r --arg id "$TASK_ID" '.[] | select(.id==$id) | (.type // "")' "$TASK_FILE" | head -n1 | tr '[:upper:]' '[:lower:]')"
  [[ -z "$task_type" ]] && task_type=""

  default_agent="$(jq -r '.default // "codex"' "$ROUTING_FILE")"
  agent="$default_agent"

  while IFS= read -r row; do
    route_agent="${row%%|*}"
    kw="${row#*|}"
    if [[ "$task_type" == *"$kw"* ]]; then
      agent="$route_agent"
      break
    fi
  done < <(jq -r '.routes[] as $r | ($r.agent // "codex") as $a | ($r.match[] | ascii_downcase) | "\($a)|\(.)"' "$ROUTING_FILE")

  echo "$agent"
}

run_once() {
  local model="${AGENT_DEFAULT_MODEL:-openai-codex/gpt-5.3-codex}"
  local dry_run="${AGENT_DRY_RUN:-1}"
  local mode="${AGENT_MODE:-mock}"

  # 测试失败开关（保留）
  if [[ "${FORCE_FAIL:-0}" == "1" ]]; then
    return 1
  fi

  # mock 模式：保持旧行为
  if [[ "$mode" != "real" ]]; then
    sleep 1
    return 0
  fi

  # 真实执行提示词（最小版）
  local prompt="You are implementing task ${TASK_ID}: ${TASK_TITLE}.
  Make minimal safe changes in current repo.
  Output concise summary of changed files and why.
  Do not run destructive commands."

  local cmd="openclaw agent --message \"$prompt\" --model \"$model\""

  echo "[INFO] run command: $cmd"

  if [[ "$dry_run" == "1" ]]; then
    echo "[INFO] dry-run enabled, skip execution"
    return 2
  fi

  # 真执行
  eval "$cmd"
}

SELECTED_AGENT="$(select_agent)"
echo "[INFO] start task: ${TASK_ID} - ${TASK_TITLE}"
echo "[INFO] selected agent: ${SELECTED_AGENT}"

"${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "running"

attempt=1
while true; do
  echo "[INFO] attempt ${attempt}/${MAX_RETRIES}"

  if run_once; then
    rc=0
  else
    rc=$?
  fi

  if [[ "$rc" -eq 0 ]]; then
    "${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "done"
    "${SCRIPT_DIR}/notify-done.sh" "${TASK_ID}" "${TASK_TITLE}"
    echo "[INFO] task done: ${TASK_ID}"
    exit 0
  fi

  if [[ "$rc" -eq 2 ]]; then
    "${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "blocked" "dry-run only (no real execution)"
    echo "[WARN] task blocked (dry-run): ${TASK_ID}"
    exit 0
  fi

  if [[ "$attempt" -ge "$MAX_RETRIES" ]]; then
    reason="failed after ${MAX_RETRIES} attempts"
    "${SCRIPT_DIR}/update-task-status.sh" "${TASK_ID}" "blocked" "${reason}"
    echo "[ERROR] task blocked: ${TASK_ID} (${reason})"
    exit 1
  fi

  attempt=$((attempt + 1))
  echo "[WARN] retrying..."
done
