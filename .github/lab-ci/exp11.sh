#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-11-JavaScript-Selenium 11_ci_test_results.log "Experiment 11 - JavaScript counter tested with Selenium"
cd "$ROOT/Experiment-11-JavaScript-Selenium"
export HEADLESS=true SCREENSHOT_DIR="$OUT"
run ./mvnw -B -q compile exec:java
