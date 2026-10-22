#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-12-Container-Selenium-Tests 12_ci_test_results.log "Experiment 12 - Selenium tests against the containerised Flask app"
run docker build -q -t event-registration:1.0 "$ROOT/Experiment-01-Flask-Registration"
run docker run -d --name event-app -p 5000:5000 event-registration:1.0
wait_http http://localhost:5000/health 30
run docker ps --filter name=event-app
cd "$ROOT/Experiment-12-Container-Selenium-Tests"
export HEADLESS=true SCREENSHOT_DIR="$OUT" APP_URL=http://localhost:5000
run bash mvnw -B -q compile exec:java
echo; echo '$ docker logs event-app   # requests made by Selenium'
docker logs event-app 2>&1 | grep -E "GET|POST"
