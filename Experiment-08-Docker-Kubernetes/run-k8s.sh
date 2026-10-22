#!/usr/bin/env bash
# Experiment 8 - Docker + Kubernetes (bash version: Linux, Git Bash, CI).
# LOAD_CMD copies a locally built image into the cluster:
#   minikube (default): LOAD_CMD="minikube image load"
#   kind              : LOAD_CMD="kind load docker-image --name lab"
set -euo pipefail
cd "$(dirname "$0")"
LOAD_CMD=${LOAD_CMD:-minikube image load}
run() { echo; echo "\$ $*"; "$@"; }

run kubectl version --client
run kubectl get nodes -o wide
run docker build -q -t event-registration:1.0 ../Experiment-01-Flask-Registration
run $LOAD_CMD event-registration:1.0
run kubectl apply -f k8s/deployment.yaml
run kubectl apply -f k8s/service.yaml
run kubectl rollout status deployment/event-registration --timeout=180s
run kubectl get deployments,pods,services -o wide

kubectl port-forward service/event-registration-svc 8085:80 >/dev/null 2>&1 & PF=$!
sleep 5
echo; echo '$ curl http://localhost:8085/register   (through the Service)'
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8085/register
run curl -s http://localhost:8085/health; echo
kill $PF 2>/dev/null || true

run kubectl scale deployment event-registration --replicas=4
run kubectl rollout status deployment/event-registration --timeout=180s
run kubectl get pods -l app=event-registration -o wide

run docker tag event-registration:1.0 event-registration:1.1
run $LOAD_CMD event-registration:1.1
run kubectl set image deployment/event-registration event-registration=event-registration:1.1
run kubectl rollout status deployment/event-registration --timeout=180s
run kubectl rollout history deployment/event-registration
echo; echo '$ kubectl describe deployment event-registration | grep -E "Image:|Replicas:"'
kubectl describe deployment event-registration | grep -E "Image:|Replicas:"
run kubectl rollout undo deployment/event-registration
run kubectl rollout status deployment/event-registration --timeout=180s
run kubectl get deployments,pods,services
