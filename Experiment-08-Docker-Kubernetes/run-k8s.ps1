# Experiment 8 - Docker + Kubernetes integration (Windows PowerShell)
# Cluster: kind ("Kubernetes IN Docker"). Its node image comes from Docker Hub. The node runs containerd,
# NOT your Docker Engine, so the locally built image is copied in with "kind load docker-image".
# (minikube works the same way with "minikube image load"; it was too slow to download on this laptop.)
# Usage:  powershell -ExecutionPolicy Bypass -File .\run-k8s.ps1
$ErrorActionPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here "evidence\08_laptop_k8s_execution.log"
New-Item -ItemType Directory -Force (Join-Path $here "evidence") | Out-Null
Start-Transcript -Path $log -Force | Out-Null

function Run($cmd) { Write-Host "`nPS> $cmd" -ForegroundColor Cyan; Invoke-Expression "$cmd 2>&1" | ForEach-Object { Write-Host "$_" } }

if (-not (Get-Command kind -ErrorAction SilentlyContinue)) {
    winget install -e --id Kubernetes.kind --accept-package-agreements --accept-source-agreements --silent
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}
Run "kind version"
Run "kubectl version --client"
if (-not ((kind get clusters 2>$null) -contains "lab")) { Run "kind create cluster --name lab --wait 180s" }
Run "kubectl config use-context kind-lab"
Run "kubectl get nodes -o wide"

# 1. Build the Docker image (Experiment 1 source) and make it available to Kubernetes
Run "docker build -q -t event-registration:1.0 `"$here\..\Experiment-01-Flask-Registration`""
Run "kind load docker-image event-registration:1.0 --name lab"

# 2. Deploy + Service
Run "kubectl apply -f `"$here\k8s\deployment.yaml`""
Run "kubectl apply -f `"$here\k8s\service.yaml`""
Run "kubectl rollout status deployment/event-registration --timeout=180s"
Run "kubectl get deployments,pods,services -o wide"

# 3. Access the app through the Service (port-forward in the background)
$pf = Start-Job { kubectl port-forward service/event-registration-svc 8085:80 }
Start-Sleep -Seconds 6
Run "(Invoke-WebRequest -UseBasicParsing http://localhost:8085/register).StatusCode"
Run "(Invoke-WebRequest -UseBasicParsing http://localhost:8085/health).Content"
Stop-Job $pf; Remove-Job $pf

# 4. Scaling
Run "kubectl scale deployment event-registration --replicas=4"
Run "kubectl rollout status deployment/event-registration --timeout=180s"
Run "kubectl get pods -l app=event-registration -o wide"

# 5. Rolling update to a new image version, then history and rollback
Run "docker tag event-registration:1.0 event-registration:1.1"
Run "kind load docker-image event-registration:1.1 --name lab"
Run "kubectl set image deployment/event-registration event-registration=event-registration:1.1"
Run "kubectl rollout status deployment/event-registration --timeout=180s"
Run "kubectl rollout history deployment/event-registration"
Run "kubectl describe deployment event-registration | Select-String 'Image:|Replicas:'"
Run "kubectl rollout undo deployment/event-registration"
Run "kubectl rollout status deployment/event-registration --timeout=180s"
Run "kubectl get deployments,pods,services"

Stop-Transcript | Out-Null
Write-Host "`nLog saved to $log. Clean up with: kubectl delete -f k8s\   (or: kind delete cluster --name lab)" -ForegroundColor Green
