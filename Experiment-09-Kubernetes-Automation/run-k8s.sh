#!/usr/bin/env bash
# Experiment 9 - Kubernetes automation of the Experiment 7 app (bash version: Linux, Git Bash, CI).
#   minikube (default): LOAD_CMD="minikube image load"     kind: LOAD_CMD="kind load docker-image --name lab"
set -euo pipefail
cd "$(dirname "$0")"
LOAD_CMD=${LOAD_CMD:-minikube image load}
run() { echo; echo "\$ $*"; "$@"; }

run docker build -q -t hello-app:1.0 ../Experiment-07-Docker-Application
run $LOAD_CMD hello-app:1.0
run kubectl apply -f deployment.yaml -f service.yaml
run kubectl rollout status deployment/hello-app --timeout=180s
run kubectl get deployment hello-app
run kubectl get pods -l app=hello-app -o wide
run kubectl get service hello-app-svc

for p in $(kubectl get pods -l app=hello-app -o jsonpath='{.items[*].metadata.name}'); do
  run kubectl logs "$p" --tail=6
done

echo; echo '$ kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl -- (6 requests to the Service)'
kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl --command -- \
  sh -c 'for i in 1 2 3 4 5 6; do curl -s http://hello-app-svc; done' 2>/dev/null || true

run kubectl describe deployment hello-app
run kubectl scale deployment hello-app --replicas=5
run kubectl rollout status deployment/hello-app --timeout=180s
run kubectl get pods -l app=hello-app
run kubectl scale deployment hello-app --replicas=3
run kubectl rollout status deployment/hello-app --timeout=180s
FIRST=$(kubectl get pods -l app=hello-app -o jsonpath='{.items[0].metadata.name}')
run kubectl delete pod "$FIRST" --wait=true
sleep 5
echo "# Self-healing: the Deployment replaced the deleted pod"
run kubectl get pods -l app=hello-app
run kubectl rollout restart deployment/hello-app
run kubectl rollout status deployment/hello-app --timeout=180s
run kubectl get deployment,pods,service -l app=hello-app
