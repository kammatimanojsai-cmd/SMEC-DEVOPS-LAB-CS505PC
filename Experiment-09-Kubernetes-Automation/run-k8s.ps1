# Experiment 9 - Kubernetes automation of the Experiment 7 application (Windows PowerShell)
# Usage:  powershell -ExecutionPolicy Bypass -File .\run-k8s.ps1
$ErrorActionPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here "evidence\09_k8s_execution.log"
New-Item -ItemType Directory -Force (Join-Path $here "evidence") | Out-Null
Start-Transcript -Path $log -Force | Out-Null

function Run($cmd) { Write-Host "`nPS> $cmd" -ForegroundColor Cyan; Invoke-Expression $cmd }

Run "minikube status"
Run "docker build -t hello-app:1.0 `"$here\..\Experiment-07-Docker-Application`""
Run "minikube image load hello-app:1.0"

Run "kubectl apply -f `"$here\deployment.yaml`""
Run "kubectl apply -f `"$here\service.yaml`""
Run "kubectl rollout status deployment/hello-app --timeout=120s"
Run "kubectl get deployment hello-app"
Run "kubectl get pods -l app=hello-app -o wide"
Run "kubectl get service hello-app-svc"

# Verify Hello World output from every pod
$pods = kubectl get pods -l app=hello-app -o jsonpath="{.items[*].metadata.name}"
foreach ($p in $pods.Split(" ")) { Run "kubectl logs $p --tail=6" }

# Call the Service several times - requests are load-balanced across pods
# (On Windows "minikube service --url" blocks the terminal, so use a background port-forward)
$pf = Start-Job { kubectl port-forward service/hello-app-svc 8086:80 }
Start-Sleep -Seconds 5
$url = "http://localhost:8086"
1..5 | ForEach-Object { Run "(Invoke-WebRequest -UseBasicParsing `"$url`").Content" }
Stop-Job $pf; Remove-Job $pf

# Application management with kubectl
Run "kubectl describe deployment hello-app | Select-String 'Replicas:|Image:|StrategyType'"
Run "kubectl scale deployment hello-app --replicas=5"
Run "kubectl rollout status deployment/hello-app --timeout=120s"
Run "kubectl get pods -l app=hello-app"
Run "kubectl scale deployment hello-app --replicas=3"
$first = $pods.Split(" ")[0]
Run "kubectl delete pod $first"       # self-healing: Kubernetes recreates the pod
Start-Sleep -Seconds 5
Run "kubectl get pods -l app=hello-app"
Run "kubectl rollout restart deployment/hello-app"
Run "kubectl rollout status deployment/hello-app --timeout=120s"
Run "kubectl get deployment,pods,service -l app=hello-app"

Stop-Transcript | Out-Null
Write-Host "`nLog saved to $log. Clean up with: kubectl delete -f deployment.yaml -f service.yaml" -ForegroundColor Green
