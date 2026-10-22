# Experiment 4 – Jenkins Installation and Setup

**Status:** ⏳ **Pending – run on your laptop.** Jenkins is already installed on your Windows laptop, and this machine could not reach it or download Jenkins. `check-jenkins.ps1` verifies your existing setup and saves the evidence log; no reinstall is needed.

## AIM
To install and set up Jenkins, start the Jenkins server, access the dashboard on `localhost:8080`, and explore its plugins, configuration and jobs.

## Software Requirements
| Software | Notes |
|---|---|
| Java JDK 17 or 21 | Required by current Jenkins LTS |
| Jenkins LTS (Windows service) | Already installed on your laptop |
| Git, Maven | Used by the jobs in Experiment 5 |
| Plugins | Git, Pipeline, Pipeline Stage View, JUnit, Timestamper, Credentials |

## Installation Procedure (for the record – already done on your laptop)
1. Install a JDK (17/21) and set `JAVA_HOME`.
2. Download the Jenkins LTS Windows installer (`jenkins.msi`) from jenkins.io and install it as a Windows service on port 8080.
3. Open `http://localhost:8080` and unlock Jenkins with the password from `C:\ProgramData\Jenkins\.jenkins\secrets\initialAdminPassword`.
4. Choose **Install suggested plugins**.
5. Create the first admin user and confirm the Jenkins URL.
6. In **Manage Jenkins → Tools**, configure the JDK, Git and Maven.

## Verifying Your Existing Setup (run on the laptop)
Open **PowerShell as Administrator** in this folder:
```powershell
# optional - lets the script list plugins and jobs (use an API TOKEN, not your password)
#   Jenkins -> your name (top right) -> Security -> API Token -> Add new token
$env:JENKINS_USER  = "<your Jenkins username>"
$env:JENKINS_TOKEN = "<API token>"

powershell -ExecutionPolicy Bypass -File .\check-jenkins.ps1
```
The script:
- checks the Java version
- checks the `Jenkins` Windows service and starts it if it is stopped
- checks that port 8080 is listening and `/login` returns HTTP 200, and reads the Jenkins version from the `X-Jenkins` header
- lists installed plugins and existing jobs (if a token is given)

It writes `evidence/04_jenkins_check.log`. The token is never written to the log or the repository.

Manual alternative:
```powershell
Get-Service Jenkins
Start-Service Jenkins          # if Stopped (Administrator)
start http://localhost:8080
```

## Screenshots to Capture (save in `evidence/`)
| File name | What to capture |
|---|---|
| `04_service_running.png` | `Get-Service Jenkins` showing **Running** |
| `04_dashboard.png` | Jenkins dashboard after login (shows your jobs, e.g. `Jenkins-CICD-Demo`) |
| `04_plugins.png` | Manage Jenkins → Plugins → Installed plugins |
| `04_tools.png` | Manage Jenkins → Tools (JDK / Git / Maven) |
| `04_system_info.png` | Manage Jenkins → System Information (Jenkins and Java versions) |

## Expected Output
```
Name    DisplayName Status  StartType
Jenkins Jenkins     Running Automatic
HTTP status     : 200
Jenkins version : 2.5xx.x
Authenticated as : <your name>
Installed plugins: <n>
```

## Result
*(Fill in after running on your laptop.)* Jenkins was started on `localhost:8080`, the authenticated dashboard was accessed, and the installed plugins, tools and jobs were inspected.

## Viva Questions
1. **What is Jenkins?** An open-source automation server used to build, test and deploy software (CI/CD).
2. **Default Jenkins port?** 8080.
3. **Where is the initial admin password stored?** In `secrets/initialAdminPassword` inside the Jenkins home directory.
4. **What are plugins?** Extensions that add features, e.g. the Git, Pipeline and JUnit plugins.
5. **Freestyle job vs Pipeline job?** A freestyle job is configured through the UI; a pipeline is defined as code in a `Jenkinsfile`.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-04-Jenkins-Setup`
