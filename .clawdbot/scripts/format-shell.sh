#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if ! command -v shfmt > /dev/null 2>&1; then
  echo "[ERROR] shfmt is required but not installed."
  echo "[INFO] install with: brew install shfmt"
  exit 1
fi

shopt -s nullglob
files=("${REPO_ROOT}"/.clawdbot/scripts/*.sh)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "[INFO] no shell scripts found in .clawdbot/scripts"
  exit 0
fi

shfmt -w -i 2 -ci -sr "${files[@]}"
echo "[INFO] formatted ${#files[@]} shell script(s)"
