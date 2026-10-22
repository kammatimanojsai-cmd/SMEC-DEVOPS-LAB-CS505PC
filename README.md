# SMEC DevOps Lab – CS505PC

St. Martin's Engineering College · DevOps Lab (CS505PC) · all 12 experiments with source code, configuration, documentation and execution evidence.

> **Live status:** see [`PROGRESS.md`](PROGRESS.md). Experiments 1, 7, 10, 11 and 12 were executed and verified. Experiments 2, 3, 5 and 6 are partially verified. Experiments 4, 8 and 9 are ready to run on the Windows laptop.

## Experiments

| # | Folder | Topic | Tools | Status |
|---|---|---|---|---|
| 1 | [Experiment-01-Flask-Registration](Experiment-01-Flask-Registration) | Event registration form with Flask + Docker | Python, Flask, Docker | ✅ |
| 2 | [Experiment-02-Git-Commands](Experiment-02-Git-Commands) | Git & GitHub commands | Git, GitHub | 🟡 PR on laptop |
| 3 | [Experiment-03-Source-Code-Management](Experiment-03-Source-Code-Management) | SCM using the Experiment 1 code | Git, GitHub | 🟡 GitHub on laptop |
| 4 | [Experiment-04-Jenkins-Setup](Experiment-04-Jenkins-Setup) | Jenkins installation & setup | Jenkins, Java | ⏳ laptop |
| 5 | [Experiment-05-Jenkins-CICD](Experiment-05-Jenkins-CICD) | CI/CD pipeline: compile, test, JAR, deploy | Jenkins, Maven, JUnit 5 | 🟡 Jenkins on laptop |
| 6 | [Experiment-06-Docker-Commands](Experiment-06-Docker-Commands) | Docker commands | Docker | 🟡 pull/push on laptop |
| 7 | [Experiment-07-Docker-Application](Experiment-07-Docker-Application) | Containerised Hello World app | Docker, Python | ✅ |
| 8 | [Experiment-08-Docker-Kubernetes](Experiment-08-Docker-Kubernetes) | Docker + Kubernetes: deploy, service, scale, rolling update | minikube, kubectl | ⏳ laptop |
| 9 | [Experiment-09-Kubernetes-Automation](Experiment-09-Kubernetes-Automation) | Kubernetes manifests for Exp 7, 3 replicas | minikube, kubectl | ⏳ laptop |
| 10 | [Experiment-10-Selenium-Setup](Experiment-10-Selenium-Setup) | Selenium WebDriver setup | Java, Selenium, Chrome | ✅ |
| 11 | [Experiment-11-JavaScript-Selenium](Experiment-11-JavaScript-Selenium) | JavaScript counter tested by Selenium | JS, Java, Selenium | ✅ 5/5 |
| 12 | [Experiment-12-Container-Selenium-Tests](Experiment-12-Container-Selenium-Tests) | Selenium tests for the containerised app | Docker, Selenium | ✅ 7/7 |

Each experiment folder contains its source code and configuration, plus a `README.md` with the **Aim, Software Requirements, Procedure, Execution Commands, Verified Output, Result, 5 Viva Questions, GitHub link and demo steps**. The `evidence/` folder holds the real logs and screenshots from the runs.

## ☁ Automated Run on GitHub Actions
[![DevOps Lab](https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/actions/workflows/devops-lab.yml/badge.svg)](https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/actions/workflows/devops-lab.yml)

The workflow `.github/workflows/devops-lab.yml` runs all 12 experiments on GitHub's Ubuntu machines: Docker, a kind Kubernetes cluster, Jenkins LTS, Java 21 and Chrome. It commits the logs and screenshots into each `Experiment-XX/evidence/github-actions` folder, and the overall results go into [`CI-RESULTS.md`](CI-RESULTS.md).
To run it again: **Actions** tab → *DevOps Lab - run all 12 experiments* → **Run workflow**.

## ▶ Run Everything on the Laptop (one click)
1. Double-click **`START-HERE.bat`** and click **Yes** on the Administrator prompt.
2. It checks and installs what is missing (winget), publishes this folder to your GitHub, then runs all 12 experiments in order.
3. It asks you only for: GitHub sign-in (browser), your Jenkins username and **API token**, and optionally a Docker Hub username.
4. When it finishes, open **`RUN-ALL-summary.md`**. Every log and screenshot is in the experiment's `evidence` folder, and everything is pushed to GitHub.

Run only some experiments: `powershell -ExecutionPolicy Bypass -File .\RUN-ALL.ps1 -Only 5,8,9`

## Software Needed on the Laptop

| Tool | Check | Install if missing |
|---|---|---|
| Git | `git --version` | already installed |
| GitHub CLI (optional) | `gh --version` | `winget install -e --id GitHub.cli` then `gh auth login` |
| Python 3.12+ | `python --version` | `winget install -e --id Python.Python.3.12` |
| JDK 17+ | `java -version` | `winget install -e --id EclipseAdoptium.Temurin.21.JDK` |
| Maven | not needed | the projects include the Maven Wrapper (`mvnw.cmd`), which downloads Maven automatically |
| Docker Desktop | `docker version` | docker.com, with the WSL 2 backend |
| Jenkins | browse to `localhost:8080` | already installed |
| kubectl / minikube | `kubectl version --client`, `minikube version` | `winget install -e --id Kubernetes.kubectl` / `Kubernetes.minikube` |
| Google Chrome | – | already installed |

## Put This on Your GitHub
From PowerShell inside this folder:
```powershell
powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1
```
or manually:
```powershell
git init -b main
git add .
git commit -m "SMEC DevOps Lab CS505PC - all 12 experiments"
gh repo create SMEC-DEVOPS-LAB-CS505PC --public --source . --push
# without gh: create an empty repo on github.com, then
# git remote add origin https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC.git
# git push -u origin main
```
Then replace `kammatimanojsai-cmd` in the README GitHub links with your username (VS Code: **Ctrl+Shift+H**, Replace All).

## Quick Demo Commands (for the lab exam)
```powershell
# Exp 1 / 12 - app in Docker + Selenium tests
cd Experiment-01-Flask-Registration; docker build -t event-registration:1.0 .; docker run -d --name event-app -p 5000:5000 event-registration:1.0; cd ..
cd Experiment-12-Container-Selenium-Tests; .\mvnw.cmd -q compile exec:java; cd ..
# Exp 7
cd Experiment-07-Docker-Application; docker build -t hello-app:1.0 .; docker run --name hello-container hello-app:1.0; docker logs hello-container; cd ..
# Exp 11
cd Experiment-11-JavaScript-Selenium; .\mvnw.cmd -q compile exec:java; cd ..
```

## Security
No passwords, tokens or keys are stored in this repository. Jenkins API tokens and Docker Hub logins are passed only through environment variables or interactive login at run time, and `.gitignore` excludes common secret files.
