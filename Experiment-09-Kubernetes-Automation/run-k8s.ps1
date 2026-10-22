# Experiment 9 - Kubernetes automation of the Experiment 7 application (Windows PowerShell, kind cluster)
# Usage:  powershell -ExecutionPolicy Bypass -File .\run-k8s.ps1   (creates the kind cluster "lab" if needed)
$ErrorActionPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here "evidence\09_laptop_k8s_execution.log"
New-Item -ItemType Directory -Force (Join-Path $here "evidence") | Out-Null
Start-Transcript -Path $log -Force | Out-Null

function Run($cmd) { Write-Host "`nPS> $cmd" -ForegroundColor Cyan; Invoke-Expression "$cmd 2>&1" | ForEach-Object { Write-Host "$_" } }

if (-not ((kind get clusters 2>$null) -contains "lab")) { Run "kind create cluster --name lab --wait 180s" }
Run "kubectl config use-context kind-lab"
Run "docker build -q -t hello-app:1.0 `"$here\..\Experiment-07-Docker-Application`""
Run "kind load docker-image hello-app:1.0 --name lab"

Run "kubectl apply -f `"$here\deployment.yaml`""
Run "kubectl apply -f `"$here\service.yaml`""
Run "kubectl rollout status deployment/hello-app --timeout=180s"
Run "kubectl get deployment hello-app"
Run "kubectl get pods -l app=hello-app -o wide"
Run "kubectl get service hello-app-svc"

# Hello World output from every pod
$pods = kubectl get pods -l app=hello-app -o jsonpath="{.items[*].metadata.name}"
foreach ($p in $pods.Split(" ")) { Run "kubectl logs $p --tail=6" }

# 6 requests through the Service from inside the cluster - answered by different pods (load balancing)
Run "kubectl run curl-test --rm -i --restart=Never --image=curlimages/curl --command -- sh -c 'for i in 1 2 3 4 5 6; do curl -s http://hello-app-svc; done'"

# Application management with kubectl
Run "kubectl describe deployment hello-app | Select-String 'Replicas:|Image:|StrategyType'"
Run "kubectl scale deployment hello-app --replicas=5"
Run "kubectl rollout status deployment/hello-app --timeout=180s"
Run "kubectl get pods -l app=hello-app"
Run "kubectl scale deployment hello-app --replicas=3"
Run "kubectl rollout status deployment/hello-app --timeout=180s"
$first = (kubectl get pods -l app=hello-app -o jsonpath="{.items[0].metadata.name}")
Run "kubectl delete pod $first"       # self-healing: Kubernetes recreates the pod
Start-Sleep -Seconds 8
Run "kubectl get pods -l app=hello-app"
Run "kubectl rollout restart deployment/hello-app"
Run "kubectl rollout status deployment/hello-app --timeout=180s"
Run "kubectl get deployment,pods,service -l app=hello-app"

Stop-Transcript | Out-Null
Write-Host "`nLog saved to $log. Clean up with: kubectl delete -f deployment.yaml -f service.yaml" -ForegroundColor Green
