# Experiment 4 - Verify the existing Jenkins installation on Windows (no reinstall).
# Run in PowerShell *as Administrator* (needed only if the service must be started):
#   powershell -ExecutionPolicy Bypass -File .\check-jenkins.ps1
# Optional, to list plugins and jobs through the REST API (an API token, never your password):
#   $env:JENKINS_USER="admin"; $env:JENKINS_TOKEN="<API token from Jenkins > your name > Security>"
$ErrorActionPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
New-Item -ItemType Directory -Force (Join-Path $here "evidence") | Out-Null
$log = Join-Path $here "evidence\04_jenkins_check.log"
Start-Transcript -Path $log -Force | Out-Null
$base = if ($env:JENKINS_URL) { $env:JENKINS_URL.TrimEnd('/') } else { "http://localhost:8080" }

Write-Host "=== 1. Java ==="
java -version 2>&1 | ForEach-Object { "$_" }

Write-Host "`n=== 2. Jenkins Windows service ==="
$svc = Get-Service -Name "Jenkins" -ErrorAction SilentlyContinue
if (-not $svc) {
    Write-Host "Jenkins service not found. If Jenkins runs from jenkins.war, start it with: java -jar jenkins.war --httpPort=8080"
} else {
    $svc | Format-Table Name, DisplayName, Status, StartType -AutoSize | Out-String | Write-Host
    if ($svc.Status -ne "Running") {
        Write-Host "Service is $($svc.Status) - starting it..."
        Start-Service -Name "Jenkins"
        (Get-Service -Name "Jenkins").WaitForStatus("Running", "00:01:00")
        Get-Service -Name "Jenkins" | Format-Table Name, Status -AutoSize | Out-String | Write-Host
    }
}

Write-Host "`n=== 3. Port 8080 listener ==="
Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue |
    Format-Table LocalAddress, LocalPort, State, OwningProcess -AutoSize | Out-String | Write-Host

Write-Host "`n=== 4. HTTP check $base/login ==="
$ok = $false
for ($i = 1; $i -le 12 -and -not $ok; $i++) {
    try {
        $r = Invoke-WebRequest -UseBasicParsing "$base/login" -TimeoutSec 10
        Write-Host "HTTP status     : $($r.StatusCode)"
        Write-Host "Jenkins version : $($r.Headers['X-Jenkins'])"
        $ok = $true
    } catch { Write-Host "Attempt $i - Jenkins not ready yet ($($_.Exception.Message))"; Start-Sleep 10 }
}

Write-Host "`n=== 5. Plugins and jobs (REST API) ==="
if ($env:JENKINS_USER -and $env:JENKINS_TOKEN) {
    $pair = "$($env:JENKINS_USER):$($env:JENKINS_TOKEN)"
    $hdr = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair)) }
    $who = Invoke-RestMethod -Headers $hdr "$base/me/api/json"
    Write-Host "Authenticated as : $($who.fullName)"
    $plugins = (Invoke-RestMethod -Headers $hdr "$base/pluginManager/api/json?depth=1").plugins
    Write-Host "Installed plugins: $($plugins.Count)"
    $key = 'git','workflow-aggregator','pipeline-stage-view','junit','timestamper','credentials','github','maven-plugin'
    $plugins | Where-Object { $key -contains $_.shortName } |
        Sort-Object shortName | Format-Table shortName, version, active -AutoSize | Out-String | Write-Host
    $jobs = (Invoke-RestMethod -Headers $hdr "$base/api/json?tree=jobs[name,color,url]").jobs
    Write-Host "Jobs: $($jobs.Count)"
    $jobs | Format-Table name, color, url -AutoSize | Out-String | Write-Host
} else {
    Write-Host "Skipped - set JENKINS_USER and JENKINS_TOKEN to list plugins and jobs."
}

Write-Host "`n=== 6. Global tool locations ==="
where.exe git 2>&1 | ForEach-Object { "git  : $_" }
where.exe mvn 2>&1 | ForEach-Object { "mvn  : $_" }
Stop-Transcript | Out-Null
Write-Host "`nSaved: $log  - now take the dashboard screenshots listed in README.md"
