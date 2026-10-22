#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-07-Docker-Application 07_ci_execution.log "Experiment 7 - containerised Hello World"
cd "$ROOT/Experiment-07-Docker-Application"
run python hello.py
run docker build -t hello-app:1.0 .
run docker images hello-app
run docker run --name hello-container hello-app:1.0
run docker ps -a --filter name=hello-container
run docker logs hello-container
check "'Hello, World!' found in docker logs" '[[ "$(docker logs hello-container 2>&1)" == *"Hello, World!"* ]]'
