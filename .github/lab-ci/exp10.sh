#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-10-Selenium-Setup 10_ci_execution.log "Experiment 10 - Selenium WebDriver setup (Java + Chrome, headless)"
cd "$ROOT/Experiment-10-Selenium-Setup"
run java -version
run google-chrome --version
export HEADLESS=true SCREENSHOT_DIR="$OUT"
run ./mvnw -B -q compile exec:java
