# Push this lab repository to YOUR GitHub account (run inside the extracted folder).
# Requires Git, plus either the GitHub CLI (gh, logged in with "gh auth login") or an empty repo
# that you created on github.com yourself.
#   powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1
$ErrorActionPreference = "Stop"
$repo = "SMEC-DEVOPS-LAB-CS505PC"
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

git --version
if (-not (git config user.name))  { throw 'Set your identity first: git config --global user.name "Your Name"' }
if (-not (git config user.email)) { throw 'Set your identity first: git config --global user.email "you@example.com"' }

if (-not (Test-Path .git)) { git init -b main }
git add .
git status --short | Select-Object -First 40
git commit -m "SMEC DevOps Lab CS505PC - all 12 experiments with code, docs and evidence"

if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status
    gh repo create $repo --public --source . --remote origin --push --description "St. Martin's Engineering College - DevOps Lab (CS505PC): 12 experiments"
    gh repo view --web
} else {
    $user = Read-Host "GitHub username (create an EMPTY repo named $repo on github.com first)"
    git remote add origin "https://github.com/$user/$repo.git"
    git push -u origin main      # Git Credential Manager opens a browser sign-in if needed
    Start-Process "https://github.com/$user/$repo"
}
