#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-02-Git-Commands 02_ci_git_commands.log "Experiment 2 - Git commands (local bare repo as remote; the real GitHub pull request is in evidence/02_github_pull_request.log)"
cd "$ROOT/Experiment-02-Git-Commands"
WORK=/tmp/git-demo GIT_NAME="SMEC Student" GIT_EMAIL="student@example.com" bash git-commands-demo.sh 2>&1 | sed 's#/tmp/git-demo#<workspace>#g'
