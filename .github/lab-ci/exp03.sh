#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-03-Source-Code-Management 03_ci_scm_workflow.log "Experiment 3 - SCM workflow on the Experiment 1 code"
cd "$ROOT/Experiment-03-Source-Code-Management"
WORK=/tmp/scm GIT_NAME="Developer A" GIT_EMAIL="dev-a@example.com" bash scm-workflow.sh 2>&1 | sed 's#/tmp/scm#<workspace>#g'
echo; echo "### The same code on GitHub: ${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/tree/main/Experiment-01-Flask-Registration"
cd "$ROOT"; run git log --oneline -5 -- Experiment-01-Flask-Registration
