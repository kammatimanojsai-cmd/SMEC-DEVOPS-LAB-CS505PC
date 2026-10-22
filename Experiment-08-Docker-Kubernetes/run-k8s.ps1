# Experiment 8 - Docker + Kubernetes integration (Windows PowerShell)
# Runtime: minikube with the Docker driver (Kubernetes uses containerd/cri-dockerd inside the
# minikube node, NOT your Docker Engine directly, so the image is loaded into the cluster).
# Usage:  powershell -ExecutionPolicy Bypass -File .\run-k8s.ps1
$ErrorActionPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here "evidence\08_k8s_execution.log"
New-Item -ItemType Directory -Force (Join-Path $here "evidence") | Out-Null
Start-Transcript -Path $log -Force | Out-Null

function Run($cmd) { Write-Host "`nPS> $cmd" -ForegroundColor Cyan; Invoke-Expression $cmd }

Run "minikube version"
Run "kubectl version --client"
Run "minikube start --driver=docker"
Run "kubectl get nodes -o wide"

# 1. Build the Docker image (Experiment 1 source) and make it available to Kubernetes
Run "docker build -t event-registration:1.0 `"$here\..\Experiment-01-Flask-Registration`""
Run "minikube image load event-registration:1.0"
Run "minikube image ls | Select-String event-registration"

# 2. Deploy + Service
Run "kubectl apply -f `"$here\k8s\deployment.yaml`""
Run "kubectl apply -f `"$here\k8s\service.yaml`""
Run "kubectl rollout status deployment/event-registration --timeout=120s"
Run "kubectl get deployments,pods,services -o wide"

# 3. Access the app through the Service
# (On Windows "minikube service --url" blocks the terminal, so use a background port-forward)
$pf = Start-Job { kubectl port-forward service/event-registration-svc 8085:80 }
Start-Sleep -Seconds 5
$url = "http://localhost:8085"
Write-Host "Service URL (port-forward): $url"
Run "(Invoke-WebRequest -UseBasicParsing `"$url/register`").StatusCode"
Run "(Invoke-WebRequest -UseBasicParsing `"$url/health`").Content"

Stop-Job $pf; Remove-Job $pf

# 4. Scaling
Run "kubectl scale deployment event-registration --replicas=4"
Run "kubectl rollout status deployment/event-registration --timeout=120s"
Run "kubectl get pods -l app=event-registration -o wide"

# 5. Rolling update to a new image version, then history and rollback
Run "docker tag event-registration:1.0 event-registration:1.1"
Run "minikube image load event-registration:1.1"
Run "kubectl set image deployment/event-registration event-registration=event-registration:1.1"
Run "kubectl rollout status deployment/event-registration --timeout=120s"
Run "kubectl rollout history deployment/event-registration"
Run "kubectl describe deployment event-registration | Select-String 'Image:|Replicas:'"
Run "kubectl rollout undo deployment/event-registration"
Run "kubectl rollout status deployment/event-registration --timeout=120s"
Run "kubectl get deployments,pods,services"

Stop-Transcript | Out-Null
Write-Host "`nLog saved to $log. Clean up with: kubectl delete -f k8s\" -ForegroundColor Green
