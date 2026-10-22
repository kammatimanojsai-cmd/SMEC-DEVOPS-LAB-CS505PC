#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-08-Docker-Kubernetes 08_ci_k8s_execution.log "Experiment 8 - Docker + Kubernetes (kind cluster on the CI runner)"
run kind version
run kubectl cluster-info --context kind-lab
LOAD_CMD="kind load docker-image --name lab" bash "$ROOT/Experiment-08-Docker-Kubernetes/run-k8s.sh"
check "event-registration deployment available (2 ready replicas after rollback)" '[ "$(kubectl get deploy event-registration -o jsonpath={.status.readyReplicas})" -ge 2 ]'
