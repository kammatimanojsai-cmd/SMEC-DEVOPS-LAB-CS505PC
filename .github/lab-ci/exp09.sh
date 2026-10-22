#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-09-Kubernetes-Automation 09_ci_k8s_execution.log "Experiment 9 - Kubernetes automation of the Experiment 7 app (3 replicas, kind cluster)"
LOAD_CMD="kind load docker-image --name lab" bash "$ROOT/Experiment-09-Kubernetes-Automation/run-k8s.sh"
check "hello-app has 3/3 ready replicas" '[ "$(kubectl get deploy hello-app -o jsonpath={.status.readyReplicas})" = 3 ]'
check "pods print Hello, World!" '[[ "$(kubectl logs deploy/hello-app)" == *"Hello, World!"* ]]'
