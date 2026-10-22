#!/usr/bin/env bash
# Shared helpers for the GitHub Actions lab runs.
set -euo pipefail
ROOT=${GITHUB_WORKSPACE:-$(pwd)}
export TZ=Asia/Kolkata

# init_log <experiment-folder> <log-file-name> <title>
init_log() {
  OUT="$ROOT/ci-out/$1/evidence/github-actions"
  mkdir -p "$OUT"
  LOG="$OUT/$2"
  exec > >(tee -a "$LOG") 2>&1
  echo "### $3"
  echo "### Executed by GitHub Actions run #${GITHUB_RUN_NUMBER:-local}: ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"
  echo "### Runner: $(lsb_release -ds 2>/dev/null || uname -sr) | Date/time: $(date '+%Y-%m-%d %H:%M:%S IST')"
}
run()   { echo; echo "\$ $*"; "$@"; }
check() { if eval "$2"; then echo "VERIFIED: $1"; else echo "FAILED: $1"; exit 1; fi; }
# shot <url> <file.png> [W,H]
shot()  {
  google-chrome --headless=new --no-sandbox --disable-gpu --hide-scrollbars --window-size="${3:-1200,850}" \
    --virtual-time-budget=8000 --screenshot="$OUT/$2" "$1" >/dev/null 2>&1 || true
  echo "Screenshot saved: evidence/github-actions/$2"
}
wait_http() { for _ in $(seq 1 "${2:-60}"); do curl -s -o /dev/null "$1" && return 0; sleep 2; done; return 1; }
