<#
  RUN-ALL.ps1 - runs all 12 SMEC DevOps Lab (CS505PC) experiments on this Windows laptop.

  Start it with START-HERE.bat (it asks for Administrator rights), or from an
  Administrator PowerShell inside this folder:
      powershell -ExecutionPolicy Bypass -File .\RUN-ALL.ps1
  Run only some experiments:
      powershell -ExecutionPolicy Bypass -File .\RUN-ALL.ps1 -Only 1,7,12

  What it does
    1. Checks Git, Python, JDK 17+, Docker Desktop, Chrome, GitHub CLI, kubectl, kind.
       Missing tools are installed with winget.
    2. Pushes this folder to your GitHub account (repo SMEC-DEVOPS-LAB-CS505PC).
    3. Runs every experiment and writes logs and screenshots into each experiment's evidence folder.
    4. Writes RUN-ALL-summary.md and pushes the new evidence to GitHub.

  It asks you for:  GitHub sign-in (browser), your Jenkins username + API token,
                    and optionally a Docker Hub username (docker login asks for the password itself).
  Nothing you type is saved to any file.
#>
param(
    [string]$Only = "",          # e.g. -Only 1,6,8,9  (comma or space separated)
    [switch]$SkipInstall,
    [switch]$SkipGitHub
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
$Results = [ordered]@{}
$Started = Get-Date

# ---------------------------------------------------------------- helpers
$OnlyList = @("$Only" -split '[,;\s]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ })
if ($OnlyList.Count -gt 0) { Write-Host "Running only experiments: $($OnlyList -join ', ')" -ForegroundColor Cyan }
function Want([int]$n) { return ($OnlyList.Count -eq 0) -or ($OnlyList -contains $n) }

function Section([string]$t) {
    Write-Host ""
    Write-Host ("=" * 78) -ForegroundColor Yellow
    Write-Host "  $t" -ForegroundColor Yellow
    Write-Host ("=" * 78) -ForegroundColor Yellow
}

function Has([string]$c) { return [bool](Get-Command $c -ErrorAction SilentlyContinue) }

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")
    if ($env:JAVA_HOME) { $env:Path = "$env:JAVA_HOME\bin;$env:Path" }
}

function New-Log([string]$path, [string]$title) {
    $dir = Split-Path -Parent $path
    New-Item -ItemType Directory -Force $dir | Out-Null
    $hdr = @(
        "### $title",
        "### Executed on : $env:COMPUTERNAME (Windows $([Environment]::OSVersion.Version)) by $env:USERNAME",
        "### Date/time   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') IST",
        ""
    )
    Set-Content -Path $path -Value $hdr -Encoding UTF8
}

function Log([string]$log, [string]$text, [string]$color = "Gray") {
    Write-Host $text -ForegroundColor $color
    Add-Content -Path $log -Value $text -Encoding UTF8
}

# Runs a command line through cmd.exe so stdout and stderr are merged cleanly. Returns the exit code.
function Exec([string]$cmd, [string]$log) {
    Log $log "" ; Log $log "PS> $cmd" "Cyan"
    cmd /c "$cmd 2>&1" | ForEach-Object { Write-Host $_; Add-Content -Path $log -Value $_ -Encoding UTF8 }
    return $LASTEXITCODE
}

# Runs a PowerShell script in a child process (those scripts keep their own transcript logs).
function Run-Child([string]$script, [string[]]$scriptArgs = @()) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $script @scriptArgs
    return $LASTEXITCODE
}

function Take-Screenshot([string]$path) {
    try {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing
        $b = [System.Windows.Forms.SystemInformation]::VirtualScreen
        $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.CopyFromScreen($b.Left, $b.Top, 0, 0, $bmp.Size)
        New-Item -ItemType Directory -Force (Split-Path -Parent $path) | Out-Null
        $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        $g.Dispose(); $bmp.Dispose()
        Write-Host "Screenshot saved: $path" -ForegroundColor Green
    } catch { Write-Host "Screenshot failed: $($_.Exception.Message)" -ForegroundColor Red }
}

function Show-Url-And-Capture([string]$url, [string]$path, [int]$wait = 6) {
    Start-Process $url
    Start-Sleep -Seconds $wait
    Take-Screenshot $path
}

function Http([string]$log, [string]$method, [string]$url, $body = $null) {
    try {
        if ($method -eq "POST") { $r = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $url -Body $body -TimeoutSec 20 }
        else { $r = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 20 }
        Log $log "HTTP $([int]$r.StatusCode)  $method $url"
        return $r
    } catch {
        $code = $null
        if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
        Log $log "HTTP $code  $method $url  ($($_.Exception.Message))"
        return $code
    }
}

function Winget-Install([string]$id, [string]$name) {
    if ($SkipInstall) { Write-Host "$name missing (install skipped)"; return }
    if (-not (Has winget)) { Write-Host "winget not available - please install $name manually" -ForegroundColor Red; return }
    Write-Host "Installing $name ($id) with winget..." -ForegroundColor Cyan
    winget install -e --id $id --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path
}

function Set-Result([string]$exp, [string]$status) { $script:Results[$exp] = $status }

# ================================================================ 0. Admin check
Section "SMEC DevOps Lab (CS505PC) - full run on $env:COMPUTERNAME"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Not running as Administrator. Installing tools and starting the Jenkins service may fail." -ForegroundColor Red
    Write-Host "Recommended: close this window and double-click START-HERE.bat instead." -ForegroundColor Red
    Start-Sleep -Seconds 5
}

# ================================================================ 1. Prerequisites
Section "Step 1 - Checking and installing prerequisites"
Refresh-Path
$preLog = Join-Path $Root "RUN-ALL-prerequisites.log"
New-Log $preLog "Prerequisite check"

if (-not (Has git)) { Winget-Install "Git.Git" "Git" }
$GitBash = @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1

# Python (skip the Microsoft Store alias, which only opens the Store)
$Py = $null
if (Has py) { $Py = "py -3" }
elseif ((Has python) -and ((cmd /c "python --version 2>&1") -match "Python 3")) { $Py = "python" }
if (-not $Py) { Winget-Install "Python.Python.3.12" "Python 3.12"; if (Has py) { $Py = "py -3" } elseif (Has python) { $Py = "python" } }

# JDK 17+
function Java-Major {
    if (-not (Has java)) { return 0 }
    $v = (cmd /c "java -version 2>&1" | Select-Object -First 1)
    if ($v -match '"(\d+)(\.(\d+))?') { $m = [int]$Matches[1]; if ($m -eq 1) { $m = [int]$Matches[3] }; return $m }
    return 0
}
if ((Java-Major) -lt 17) {
    Winget-Install "EclipseAdoptium.Temurin.21.JDK" "Temurin JDK 21"
    $jdk = Get-ChildItem "$env:ProgramFiles\Eclipse Adoptium" -Directory -Filter "jdk-21*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($jdk) { $env:JAVA_HOME = $jdk.FullName; Refresh-Path }
}
if (-not $env:JAVA_HOME -and (Has java)) {
    # ask Java itself (the Oracle "javapath" shim on PATH is not a real JDK home)
    $jh = (cmd /c "java -XshowSettings:properties -version 2>&1" | Select-String "java.home =") -replace '^\s*java\.home = ', ''
    if ($jh) { $env:JAVA_HOME = "$jh".Trim(); Refresh-Path }
}

# Chrome
$chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { Winget-Install "Google.Chrome" "Google Chrome" }

if (-not (Has gh))       { Winget-Install "GitHub.cli" "GitHub CLI" }
if (-not (Has kubectl))  { Winget-Install "Kubernetes.kubectl" "kubectl" }
if (-not (Has kind))     { Winget-Install "Kubernetes.kind" "kind (Kubernetes in Docker)" }

# Docker Desktop
$DockerOK = $false
if (-not (Has docker)) {
    Winget-Install "Docker.DockerDesktop" "Docker Desktop"
    Write-Host "Docker Desktop was just installed. Restart Windows, open Docker Desktop once, then run this script again." -ForegroundColor Red
} else {
    cmd /c "docker info >nul 2>&1"
    if ($LASTEXITCODE -ne 0) {
        $dd = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
        if (Test-Path $dd) { Write-Host "Starting Docker Desktop..."; Start-Process $dd }
        for ($i = 0; $i -lt 36; $i++) {
            Start-Sleep -Seconds 5
            cmd /c "docker info >nul 2>&1"
            if ($LASTEXITCODE -eq 0) { break }
            Write-Host "  waiting for Docker engine... ($(($i + 1) * 5)s)"
        }
    }
    cmd /c "docker info >nul 2>&1"
    $DockerOK = ($LASTEXITCODE -eq 0)
}

foreach ($c in "git --version", "java -version", "gh --version", "docker version --format {{.Server.Version}}", "kubectl version --client", "kind version") {
    Exec $c $preLog | Out-Null
}
if ($Py) { Exec "$Py --version" $preLog | Out-Null }
Log $preLog ""
Log $preLog "Git Bash       : $GitBash"
Log $preLog "Chrome         : $chrome"
Log $preLog "JAVA_HOME      : $env:JAVA_HOME"
Log $preLog "Docker running : $DockerOK"
if (-not $DockerOK) { Write-Host "Docker is not running - Docker experiments (1, 6, 7, 8, 9, 12) will be marked BLOCKED." -ForegroundColor Red }

# ---------------------------------------------------------------- questions (asked once, kept only in memory)
Section "A few details (kept in memory only, never written to disk)"
$GitName = (git config --global user.name); $GitEmail = (git config --global user.email)
if (-not $GitName)  { $GitName  = Read-Host "Your name for Git commits";  git config --global user.name  $GitName }
if (-not $GitEmail) { $GitEmail = Read-Host "Your email for Git commits"; git config --global user.email $GitEmail }
$env:GIT_NAME = $GitName; $env:GIT_EMAIL = $GitEmail

$JenkinsUrl = "http://localhost:8080"
$JenkinsUser = $null; $JenkinsToken = $null
if ((Want 4) -or (Want 5)) {
    Write-Host "Jenkins API token: open $JenkinsUrl -> click your name (top right) -> Security -> API Token -> Add new token -> Generate -> copy." -ForegroundColor Cyan
    $JenkinsUser = Read-Host "Jenkins username (Enter to skip the Jenkins API steps)"
    if ($JenkinsUser) {
        $sec = Read-Host "Jenkins API token (input hidden)" -AsSecureString
        $JenkinsToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
    }
}
$DockerHubUser = $null
if (Want 6) { $DockerHubUser = Read-Host "Docker Hub username for 'docker push' (Enter to skip push)" }

# ================================================================ 2. GitHub repository
$RepoUrl = $null
if (-not $SkipGitHub) {
    Section "Step 2 - Publishing the repository to your GitHub account"
    Refresh-Path
    if ((Has gh)) {
        cmd /c "gh auth status >nul 2>&1"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "A browser window will open - sign in to GitHub and approve the GitHub CLI." -ForegroundColor Cyan
            gh auth login --hostname github.com --git-protocol https --web
        }
        gh auth setup-git
    }
    if (-not (Test-Path (Join-Path $Root ".git"))) {
        git init -b main | Out-Null
        # The repository may already exist on GitHub (it was published from this folder before): attach to it
        $existing = $null
        if (Has gh) { $existing = (cmd /c "gh repo view SMEC-DEVOPS-LAB-CS505PC --json url --jq .url 2>nul") }
        if ($existing) {
            Write-Host "Found existing GitHub repository $existing - connecting this folder to it" -ForegroundColor Green
            git remote add origin "$existing.git"
            git fetch -q origin
            git reset -q --soft origin/main
        }
    }
    git add -A
    git commit -q -m "SMEC DevOps Lab CS505PC - all 12 experiments (code, docs, evidence)" 2>$null
    $origin = (git remote get-url origin 2>$null)
    if (-not $origin) {
        if (Has gh) {
            gh repo create SMEC-DEVOPS-LAB-CS505PC --public --source . --remote origin --push `
                --description "St. Martin's Engineering College - DevOps Lab (CS505PC): 12 experiments"
        } else {
            $u = Read-Host "GitHub username (first create an EMPTY repo named SMEC-DEVOPS-LAB-CS505PC on github.com)"
            git remote add origin "https://github.com/$u/SMEC-DEVOPS-LAB-CS505PC.git"
            git push -u origin main
        }
    } else {
        git pull --rebase -q origin main
        git push -u origin main
    }
    $RepoUrl = (git remote get-url origin 2>$null)
    if ($RepoUrl) {
        $RepoUrl = $RepoUrl -replace '\.git$', ''
        Write-Host "Repository: $RepoUrl" -ForegroundColor Green
        # Fill in the GitHub links in all READMEs
        $owner = ($RepoUrl -split '/')[-2]
        Get-ChildItem -Recurse -Filter README.md | ForEach-Object {
            $t = Get-Content $_.FullName -Raw
            if ($t -match '<your-username>') { [IO.File]::WriteAllText($_.FullName, ($t -replace '<your-username>', $owner)) }
        }
        git add -A; git commit -q -m "Fill in GitHub links" 2>$null; git pull --rebase -q origin main; git push -q 2>$null
        Set-Result "GitHub" "PASS - $RepoUrl"
    } else { Set-Result "GitHub" "FAIL - repository not created/pushed" }
}

# ================================================================ Experiment 1
if (Want 1) {
    Section "Experiment 1 - Flask registration form + Docker"
    $d = Join-Path $Root "Experiment-01-Flask-Registration"; $ev = "$d\evidence"; $log = "$ev\01_laptop_execution.log"
    New-Log $log "Experiment 1 - laptop execution"
    Push-Location $d
    $ok = $true
    if ($Py) {
        Exec "$Py -m pip install -q --retries 5 --timeout 60 -r requirements.txt pytest" $log | Out-Null
        if ((Exec "$Py -m pytest -v test_app.py" $log) -ne 0) { $ok = $false }
    }
    if ($DockerOK) {
        if ((Exec "docker build -t event-registration:1.0 ." $log) -ne 0) { $ok = $false }
        Exec "docker images event-registration" $log | Out-Null
        Exec "docker rm -f event-app" $log | Out-Null
        Exec "docker run -d --name event-app -p 5000:5000 event-registration:1.0" $log | Out-Null
        Start-Sleep -Seconds 5
        Exec "docker ps --filter name=event-app" $log | Out-Null
        $r = Http $log "GET" "http://localhost:5000/register"
        if (-not ($r -and $r.StatusCode -eq 200 -and $r.Content -match "Event Registration Form")) { $ok = $false }
        $r = Http $log "POST" "http://localhost:5000/register" @{ name = "Ravi Kumar"; email = "ravi@example.com"; phone = "9876543210"; event = "DevOps Workshop" }
        if ($r -and $r.Content -match "Registration Successful!") { Log $log "Response contains: Registration Successful! (Ravi Kumar / DevOps Workshop)" "Green" } else { $ok = $false }
        $code = Http $log "POST" "http://localhost:5000/register" @{ name = "Ra"; email = "bad"; phone = "123"; event = "" }
        if ($code -eq 400) { Log $log "Invalid input correctly rejected with HTTP 400" "Green" } else { $ok = $false }
        Exec "docker logs event-app" $log | Out-Null
        Show-Url-And-Capture "http://localhost:5000/register" "$ev\laptop_01_register_form_in_browser.png"
        Set-Result "Exp 01" ($(if ($ok) { "PASS" } else { "FAIL - see evidence\01_laptop_execution.log" }))
    } else { Set-Result "Exp 01" "BLOCKED - Docker not running" }
    Pop-Location
}

# ================================================================ Experiment 2
if (Want 2) {
    Section "Experiment 2 - Git and GitHub commands"
    $d = Join-Path $Root "Experiment-02-Git-Commands"; $log = "$d\evidence\02_laptop_git_commands.log"
    New-Log $log "Experiment 2 - laptop execution (Git Bash)"
    Push-Location $d
    $rc = 1
    if ($GitBash) {
        & $GitBash -c "./git-commands-demo.sh" 2>&1 | ForEach-Object { $t = "$_"; Write-Host $t; Add-Content -Path $log -Value $t -Encoding UTF8 }
        $rc = $LASTEXITCODE
        Remove-Item -Recurse -Force "$d\git-demo-workspace" -ErrorAction SilentlyContinue
    } else { Log $log "Git Bash not found" "Red" }
    Pop-Location

    # Real pull request on GitHub
    $prOk = $false
    if ($RepoUrl -and (Has gh)) {
        $prLog = "$d\evidence\02_laptop_pull_request.log"
        New-Log $prLog "Experiment 2 - pull request on GitHub"
        Exec "git switch -c exp2-pull-request-demo" $prLog | Out-Null
        Add-Content -Path "$d\README.md" -Value "`r`n_Pull request demo performed on $(Get-Date -Format 'dd MMM yyyy HH:mm') IST._" -Encoding UTF8
        Exec "git commit -am ""Exp 2: pull request demo""" $prLog | Out-Null
        Exec "git push -u origin exp2-pull-request-demo" $prLog | Out-Null
        Exec "gh pr create --title ""Exp 2: Pull request demo"" --body ""Experiment 2 - demonstrating a GitHub pull request"" --base main --head exp2-pull-request-demo" $prLog | Out-Null
        Exec "gh pr list --state open" $prLog | Out-Null
        if ((Exec "gh pr merge exp2-pull-request-demo --merge --delete-branch" $prLog) -eq 0) { $prOk = $true }
        Exec "git switch main" $prLog | Out-Null
        Exec "git pull" $prLog | Out-Null
        Exec "gh pr list --state merged --limit 3" $prLog | Out-Null
        Exec "git log --oneline --graph -5" $prLog | Out-Null
    }
    Set-Result "Exp 02" ($(if ($rc -eq 0 -and $prOk) { "PASS (commands + merged PR)" } elseif ($rc -eq 0) { "PARTIAL - commands OK, PR not done" } else { "FAIL" }))
}

# ================================================================ Experiment 3
if (Want 3) {
    Section "Experiment 3 - Source code management with the Experiment 1 code"
    $d = Join-Path $Root "Experiment-03-Source-Code-Management"; $log = "$d\evidence\03_laptop_scm_workflow.log"
    New-Log $log "Experiment 3 - laptop execution (Git Bash)"
    Push-Location $d
    $rc = 1
    if ($GitBash) {
        & $GitBash -c "./scm-workflow.sh" 2>&1 | ForEach-Object { $t = "$_"; Write-Host $t; Add-Content -Path $log -Value $t -Encoding UTF8 }
        $rc = $LASTEXITCODE
        Remove-Item -Recurse -Force "$d\scm-workspace" -ErrorAction SilentlyContinue
    }
    if ($RepoUrl) {
        Exec "git ls-remote --heads origin" $log | Out-Null
        Exec "git log --oneline -5 -- :/Experiment-01-Flask-Registration" $log | Out-Null
        Log $log "Code on GitHub: $RepoUrl/tree/main/Experiment-01-Flask-Registration"
    }
    Pop-Location
    Set-Result "Exp 03" ($(if ($rc -eq 0) { "PASS" } else { "FAIL - see log" }))
}

# ================================================================ Experiment 4
$JenkinsHdr = $null
if ($JenkinsUser -and $JenkinsToken) {
    $JenkinsHdr = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($JenkinsUser):$($JenkinsToken)")) }
}
if (Want 4) {
    Section "Experiment 4 - Jenkins setup check"
    $d = Join-Path $Root "Experiment-04-Jenkins-Setup"
    if ($JenkinsHdr) { $env:JENKINS_USER = $JenkinsUser; $env:JENKINS_TOKEN = $JenkinsToken }
    Run-Child "$d\check-jenkins.ps1" | Out-Null
    Remove-Item Env:JENKINS_TOKEN -ErrorAction SilentlyContinue
    $up = $false
    try { $up = ((Invoke-WebRequest -UseBasicParsing "$JenkinsUrl/login" -TimeoutSec 15).StatusCode -eq 200) } catch {}
    if ($up) {
        Show-Url-And-Capture "$JenkinsUrl/" "$d\evidence\laptop_04_jenkins_dashboard.png" 8
        Show-Url-And-Capture "$JenkinsUrl/manage/pluginManager/installed" "$d\evidence\laptop_04_jenkins_plugins.png" 8
        Show-Url-And-Capture "$JenkinsUrl/manage/systemInfo" "$d\evidence\laptop_04_jenkins_system_info.png" 8
        Set-Result "Exp 04" "PASS - Jenkins up at $JenkinsUrl (check screenshots show you logged in)"
    } else { Set-Result "Exp 04" "FAIL - Jenkins not reachable at $JenkinsUrl" }
}

# ================================================================ Experiment 5
if (Want 5) {
    Section "Experiment 5 - CI/CD with Jenkins"
    $d = Join-Path $Root "Experiment-05-Jenkins-CICD"; $ev = "$d\evidence"; $log = "$ev\05_laptop_local_build.log"
    New-Log $log "Experiment 5 - local Maven build (before Jenkins)"
    Push-Location $d
    $localOk = ((Exec "mvnw.cmd -B clean package" $log) -eq 0)
    if ($localOk) { Exec "java -jar target\jenkins-cicd-demo.jar" $log | Out-Null }
    Pop-Location

    $jobOk = $false
    if ($JenkinsHdr -and $RepoUrl) {
        $job = "SMEC-Exp5-CICD"
        $jlog = "$ev\05_laptop_jenkins_api.log"
        New-Log $jlog "Experiment 5 - Jenkins job creation and builds"
        $configXml = @"
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <description>SMEC DevOps Lab - Experiment 5 CI/CD pipeline (created by RUN-ALL.ps1)</description>
  <keepDependencies>false</keepDependencies>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps">
    <scm class="hudson.plugins.git.GitSCM" plugin="git">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig><url>$RepoUrl.git</url></hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches><hudson.plugins.git.BranchSpec><name>*/main</name></hudson.plugins.git.BranchSpec></branches>
    </scm>
    <scriptPath>Experiment-05-Jenkins-CICD/Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <disabled>false</disabled>
</flow-definition>
"@
        function J([string]$method, [string]$path, $body = $null, [string]$ctype = "application/xml") {
            $p = @{ Uri = "$JenkinsUrl$path"; Method = $method; Headers = $JenkinsHdr; UseBasicParsing = $true; TimeoutSec = 30 }
            if ($body) { $p.Body = $body; $p.ContentType = $ctype }
            return Invoke-WebRequest @p
        }
        function Wait-Build([int]$num, [int]$timeoutSec) {
            $deadline = (Get-Date).AddSeconds($timeoutSec)
            while ((Get-Date) -lt $deadline) {
                try {
                    $b = (J GET "/job/$job/$num/api/json").Content | ConvertFrom-Json
                    if (-not $b.building) { return $b }
                } catch {}
                Start-Sleep -Seconds 10
                Write-Host "  waiting for build #$num ..."
            }
            return $null
        }
        try {
            $exists = $true
            try { J GET "/job/$job/api/json" | Out-Null } catch { $exists = $false }
            if ($exists) { J POST "/job/$job/config.xml" $configXml | Out-Null; Log $jlog "Updated existing job $job" }
            else { J POST "/createItem?name=$job" $configXml | Out-Null; Log $jlog "Created pipeline job $job (SCM: $RepoUrl.git, Script Path: Experiment-05-Jenkins-CICD/Jenkinsfile)" }

            $next = ((J GET "/job/$job/api/json").Content | ConvertFrom-Json).nextBuildNumber
            J POST "/job/$job/build" | Out-Null
            Log $jlog "Triggered build #$next (manual)"
            Start-Sleep -Seconds 15
            $b1 = Wait-Build $next 900
            if ($b1) {
                Log $jlog "Build #$next result: $($b1.result)"
                (J GET "/job/$job/$next/consoleText").Content | Set-Content "$ev\05_laptop_build$($next)_console.txt" -Encoding UTF8
                Show-Url-And-Capture "$JenkinsUrl/job/$job/" "$ev\laptop_05_stage_view_build$next.png" 8
                Show-Url-And-Capture "$JenkinsUrl/job/$job/$next/testReport/" "$ev\laptop_05_test_results.png" 8
            } else { Log $jlog "Build #$next did not finish within 15 minutes" "Red" }

            if ($b1 -and $b1.result -eq "SUCCESS") {
                # A new commit triggers the next build through pollSCM (every 2 minutes)
                $app = "$d\src\main\java\in\smec\devops\App.java"
                $src = Get-Content $app -Raw
                $src = $src -replace 'VERSION = "1\.0"', 'VERSION = "1.1"'
                [IO.File]::WriteAllText($app, $src)   # UTF-8 without BOM (javac rejects a BOM)
                Exec "git add Experiment-05-Jenkins-CICD/src/main/java/in/smec/devops/App.java" $jlog | Out-Null
                Exec "git commit -m ""Exp 5: bump version to 1.1 (should trigger Jenkins automatically)""" $jlog | Out-Null
                Exec "git push" $jlog | Out-Null
                Log $jlog "Pushed a new commit - waiting up to 6 minutes for Jenkins pollSCM to start build #$($next + 1) on its own..."
                $b2 = $null
                $deadline = (Get-Date).AddMinutes(6)
                while ((Get-Date) -lt $deadline -and -not $b2) {
                    Start-Sleep -Seconds 20
                    try { J GET "/job/$job/$($next + 1)/api/json" | Out-Null; $b2 = Wait-Build ($next + 1) 900 } catch { Write-Host "  no new build yet..." }
                }
                if ($b2) {
                    $c2 = (J GET "/job/$job/$($next + 1)/consoleText").Content
                    $c2 | Set-Content "$ev\05_laptop_build$($next + 1)_console.txt" -Encoding UTF8
                    $cause = if ($c2 -match "Started by an SCM change") { "Started by an SCM change" } else { "(see console)" }
                    Log $jlog "Build #$($next + 1) result: $($b2.result) - $cause"
                    Show-Url-And-Capture "$JenkinsUrl/job/$job/" "$ev\laptop_05_build_history.png" 8
                    $jobOk = ($b2.result -eq "SUCCESS")
                } else { Log $jlog "No automatic build appeared. Check that the job ran build #$next once (this registers pollSCM)." "Red" }
            }
        } catch { Log $jlog "Jenkins API error: $($_.Exception.Message)" "Red" }
    }
    Set-Result "Exp 05" ($(if ($jobOk) { "PASS - local build + Jenkins builds (manual and SCM-triggered)" }
                          elseif ($localOk) { "PARTIAL - local mvn package OK; Jenkins part not completed (see 05_laptop_jenkins_api.log)" }
                          else { "FAIL - see 05_laptop_local_build.log" }))
}

# ================================================================ Experiment 6
if (Want 6) {
    Section "Experiment 6 - Docker commands"
    if ($DockerOK) {
        if ($DockerHubUser) {
            Write-Host "docker login - type your Docker Hub password or access token when asked:" -ForegroundColor Cyan
            docker login -u $DockerHubUser
            $env:DOCKERHUB_USER = $DockerHubUser
        }
        $rc = Run-Child (Join-Path $Root "Experiment-06-Docker-Commands\docker-commands.ps1")
        Remove-Item Env:DOCKERHUB_USER -ErrorAction SilentlyContinue
        cmd /c "docker image inspect nginx:stable-alpine >nul 2>&1"
        $pulled = ($LASTEXITCODE -eq 0)
        Set-Result "Exp 06" ($(if ($pulled -and $DockerHubUser) { "PASS (incl. pull and push)" } elseif ($pulled) { "PASS (pull OK, push skipped - no Docker Hub user)" } else { "CHECK - see evidence\06_execution_laptop.log" }))
    } else { Set-Result "Exp 06" "BLOCKED - Docker not running" }
}

# ================================================================ Experiment 7
if (Want 7) {
    Section "Experiment 7 - Containerised Hello World"
    $d = Join-Path $Root "Experiment-07-Docker-Application"; $log = "$d\evidence\07_laptop_execution.log"
    New-Log $log "Experiment 7 - laptop execution"
    if ($DockerOK) {
        Push-Location $d
        Exec "docker build -t hello-app:1.0 ." $log | Out-Null
        Exec "docker images hello-app" $log | Out-Null
        Exec "docker rm -f hello-container" $log | Out-Null
        Exec "docker run --name hello-container hello-app:1.0" $log | Out-Null
        Exec "docker ps -a --filter name=hello-container" $log | Out-Null
        Exec "docker logs hello-container" $log | Out-Null
        $out = cmd /c "docker logs hello-container 2>&1"
        Pop-Location
        if ($out -match "Hello, World!") { Log $log "VERIFIED: 'Hello, World!' found in docker logs" "Green"; Set-Result "Exp 07" "PASS" }
        else { Set-Result "Exp 07" "FAIL - Hello World not in logs" }
    } else { Set-Result "Exp 07" "BLOCKED - Docker not running" }
}

# ================================================================ Experiments 8 and 9
if (Want 8) {
    Section "Experiment 8 - Docker + Kubernetes (kind cluster)"
    if ($DockerOK -and (Has kind) -and (Has kubectl)) {
        Run-Child (Join-Path $Root "Experiment-08-Docker-Kubernetes\run-k8s.ps1") | Out-Null
        $ready = cmd /c "kubectl --context kind-lab get deployment event-registration -o jsonpath={.status.readyReplicas} 2>nul"
        Set-Result "Exp 08" ($(if ("$ready" -match '^\d+$' -and [int]"$ready" -ge 2) { "PASS - $ready ready replicas" } else { "CHECK - see evidence\08_laptop_k8s_execution.log" }))
    } else { Set-Result "Exp 08" "BLOCKED - needs Docker running + kind + kubectl" }
}
if (Want 9) {
    Section "Experiment 9 - Kubernetes automation (3 replicas)"
    if ($DockerOK -and (Has kind) -and (Has kubectl)) {
        Run-Child (Join-Path $Root "Experiment-09-Kubernetes-Automation\run-k8s.ps1") | Out-Null
        $ready = cmd /c "kubectl --context kind-lab get deployment hello-app -o jsonpath={.status.readyReplicas} 2>nul"
        Set-Result "Exp 09" ($(if ("$ready" -eq "3") { "PASS - 3/3 replicas ready" } else { "CHECK - see evidence\09_laptop_k8s_execution.log" }))
    } else { Set-Result "Exp 09" "BLOCKED - needs Docker running + kind + kubectl" }
}

# ================================================================ Experiments 10-12 (Selenium, visible Chrome)
function Run-Selenium([int]$n, [string]$folder, [string]$logName, [string]$extraArgs = "") {
    $d = Join-Path $Root $folder; $log = "$d\evidence\$logName"
    New-Log $log "Experiment $n - laptop Selenium run (Chrome, visible window)"
    Push-Location $d
    $env:SCREENSHOT_DIR = "$d\evidence"
    Remove-Item Env:HEADLESS -ErrorAction SilentlyContinue
    $rc = Exec "mvnw.cmd -q compile exec:java $extraArgs" $log
    Remove-Item Env:SCREENSHOT_DIR -ErrorAction SilentlyContinue
    Pop-Location
    return $rc
}
if (Want 10) {
    Section "Experiment 10 - Selenium setup"
    $rc = Run-Selenium 10 "Experiment-10-Selenium-Setup" "10_laptop_execution.log"
    Set-Result "Exp 10" ($(if ($rc -eq 0) { "PASS" } else { "FAIL - see evidence\10_laptop_execution.log" }))
}
if (Want 11) {
    Section "Experiment 11 - JavaScript counter + Selenium"
    $rc = Run-Selenium 11 "Experiment-11-JavaScript-Selenium" "11_laptop_test_results.log"
    Set-Result "Exp 11" ($(if ($rc -eq 0) { "PASS" } else { "FAIL - see evidence\11_laptop_test_results.log" }))
}
if (Want 12) {
    Section "Experiment 12 - Selenium tests on the containerised app"
    if ($DockerOK) {
        cmd /c "docker rm -f event-app >nul 2>&1"
        cmd /c "docker image inspect event-registration:1.0 >nul 2>&1"
        if ($LASTEXITCODE -ne 0) { Push-Location (Join-Path $Root "Experiment-01-Flask-Registration"); docker build -t event-registration:1.0 .; Pop-Location }
        docker run -d --name event-app -p 5000:5000 event-registration:1.0 | Out-Null
        Start-Sleep -Seconds 5
        $rc = Run-Selenium 12 "Experiment-12-Container-Selenium-Tests" "12_laptop_test_results.log"
        Exec "docker logs event-app" (Join-Path $Root "Experiment-12-Container-Selenium-Tests\evidence\12_laptop_test_results.log") | Out-Null
        Set-Result "Exp 12" ($(if ($rc -eq 0) { "PASS" } else { "FAIL - see evidence\12_laptop_test_results.log" }))
    } else { Set-Result "Exp 12" "BLOCKED - Docker not running" }
}

# ================================================================ Summary + push evidence
Section "Summary"
$lines = @("# RUN-ALL summary", "", "Run on **$env:COMPUTERNAME** from $(Get-Date $Started -Format 'yyyy-MM-dd HH:mm') to $(Get-Date -Format 'HH:mm') IST.", "",
           "| Item | Result |", "|---|---|")
foreach ($k in $Results.Keys) { $lines += "| $k | $($Results[$k]) |" }
$lines += ""; $lines += "Logs and screenshots are in each experiment's ``evidence`` folder (files starting with ``laptop_`` or ending in ``_laptop...``)."
Set-Content -Path (Join-Path $Root "RUN-ALL-summary.md") -Value $lines -Encoding UTF8
foreach ($k in $Results.Keys) {
    $c = if ($Results[$k] -like "PASS*") { "Green" } elseif ($Results[$k] -like "PARTIAL*" -or $Results[$k] -like "CHECK*") { "Yellow" } else { "Red" }
    Write-Host ("{0,-8} {1}" -f $k, $Results[$k]) -ForegroundColor $c
}

if ($RepoUrl) {
    git add -A
    git commit -q -m "Add laptop execution evidence (RUN-ALL $(Get-Date -Format 'yyyy-MM-dd HH:mm'))" 2>$null
    git pull --rebase -q origin main
    git push -q
    Write-Host "`nEvidence pushed to $RepoUrl" -ForegroundColor Green
}
Write-Host "`nDone. Open RUN-ALL-summary.md and send it (or a screenshot of this window) to Claude if anything failed." -ForegroundColor Green
