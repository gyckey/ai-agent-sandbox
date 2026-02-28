#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if ! command -v git > /dev/null 2>&1; then
  echo "[ERROR] git is required"
  exit 1
fi

if ! git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "[ERROR] not a git repository: ${REPO_ROOT}"
  exit 1
fi

git -C "${REPO_ROOT}" config core.hooksPath .githooks

if [[ -f "${REPO_ROOT}/.githooks/pre-commit" ]]; then
  chmod +x "${REPO_ROOT}/.githooks/pre-commit"
fi

echo "[INFO] git hooks installed: core.hooksPath=.githooks"
