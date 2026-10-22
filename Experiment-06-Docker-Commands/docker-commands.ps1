# Experiment 6 - Docker command walkthrough (Windows PowerShell, Docker Desktop running)
# Usage:  powershell -ExecutionPolicy Bypass -File .\docker-commands.ps1
# For docker push: run "docker login" first and set $env:DOCKERHUB_USER = "<your Docker Hub username>"
$ErrorActionPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
New-Item -ItemType Directory -Force (Join-Path $here "evidence") | Out-Null
$log = Join-Path $here "evidence\06_execution_laptop.log"
Start-Transcript -Path $log -Force | Out-Null
$image = "nginx:stable-alpine"   # maintained official image (the manual's older examples may use outdated tags)
function Run($cmd) { Write-Host "`nPS> $cmd" -ForegroundColor Cyan; Invoke-Expression $cmd }

Run "docker --version"
Run "docker pull $image"
Run "docker pull hello-world"
Run "docker run --rm hello-world"
Run "docker images"
Run "docker run -d --name demo-web -p 8081:80 $image"
Start-Sleep -Seconds 3
Run "docker ps"
Run "(Invoke-WebRequest -UseBasicParsing http://localhost:8081).StatusCode"
Run "docker logs demo-web"
Run "docker exec demo-web cat /etc/hostname"
Run "docker inspect --format '{{.Name}} {{.Config.Image}} {{.State.Status}}' demo-web"
Run "docker stop demo-web"
Run "docker ps -a --filter name=demo-web"
Run "docker start demo-web"
Run "docker ps --filter name=demo-web"
Run "docker stop demo-web"
Run "docker rm demo-web"
Run "docker ps -a --filter name=demo-web"
if ($env:DOCKERHUB_USER) {
    Run "docker tag $image $($env:DOCKERHUB_USER)/smec-nginx-demo:1.0"
    Run "docker push $($env:DOCKERHUB_USER)/smec-nginx-demo:1.0"
} else {
    Write-Host "`ndocker push skipped - run 'docker login' and set `$env:DOCKERHUB_USER to demonstrate it."
}
Stop-Transcript | Out-Null
