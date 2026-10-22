# Experiment 5 – Continuous Integration and Delivery using Jenkins

**Status:** 🟡 **Partially verified.** The Java source compiles, packages into `jenkins-cicd-demo.jar` and runs (`evidence/05_local_compile_check.log`).
⏳ `mvn test`, the real Jenkins builds and the commit-triggered second build must be run on your laptop, because Maven Central and Jenkins were blocked on the machine that prepared this project.

## AIM
To demonstrate continuous integration and delivery with Jenkins: pull code from GitHub, compile it, run unit tests, package a JAR, deploy it, and trigger a new build automatically when a new commit is pushed.

## Software Requirements
Jenkins (Experiment 4) with the Git, Pipeline, JUnit and Timestamper plugins; JDK 17+; Maven 3.9+; Git; a GitHub repository.

## Project Structure
```
Experiment-05-Jenkins-CICD/
├── pom.xml                                   # Maven build, JUnit 5, executable jar
├── Jenkinsfile                               # Checkout → Compile → Test → Package → Deploy
├── src/main/java/in/smec/devops/App.java
├── src/main/java/in/smec/devops/Calculator.java
└── src/test/java/in/smec/devops/CalculatorTest.java   # 5 JUnit tests
```
> If you would rather reuse your previous `Jenkins-CICD-Demo` project, you can point the same Jenkins job at that repository instead. This folder is a clean, self-contained equivalent.

## Pipeline Stages (`Jenkinsfile`)
| Stage | Command | Output |
|---|---|---|
| Checkout | `checkout scm` | Code pulled from GitHub |
| Compile | `mvnw -B clean compile` | `target/classes` |
| Test | `mvnw -B test` + `junit` report | Test result trend in Jenkins |
| Package | `mvnw -B -DskipTests package` + `archiveArtifacts` | `jenkins-cicd-demo.jar` |
| Deploy | copy the JAR to `deploy/` and run `java -jar` | "Deployment successful" |

`triggers { pollSCM('H/2 * * * *') }` checks GitHub every 2 minutes. Jenkins on `localhost` cannot receive GitHub webhooks, so polling is how a new commit triggers a build. The file uses `bat` on Windows agents and `sh` on Linux.

## Procedure on Your Laptop
1. Check locally first (in this folder):
   ```powershell
   .\mvnw.cmd -B clean test
   .\mvnw.cmd -B package
   java -jar target\jenkins-cicd-demo.jar
   ```
2. Push the repository to GitHub (see the root `README.md`).
3. In Jenkins: **New Item → `SMEC-Exp5-CICD` → Pipeline → OK**.
   - **Pipeline → Definition:** *Pipeline script from SCM*
   - **SCM:** Git. **Repository URL:** `https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC.git` (a public repo needs no credentials; for a private repo, add a GitHub **personal access token** as a Jenkins *Username with password* credential).
   - **Branch:** `*/main`. **Script Path:** `Experiment-05-Jenkins-CICD/Jenkinsfile`
   - Save.
4. Maven does not need to be installed for Jenkins: the pipeline uses the Maven Wrapper (`mvnw.cmd`). Java must be on the PATH of the Jenkins service (restart the Jenkins service after installing a JDK).
5. Click **Build Now** → build **#1**. Open it and check **Stage View**, **Console Output**, **Test Result** (5 tests) and the archived **Artifacts**.
6. **Commit-triggered build:** edit `App.java` (`VERSION = "1.1"`), then
   ```powershell
   git commit -am "Bump version to 1.1"
   git push
   ```
   Within about 2 minutes Jenkins starts build **#2** by itself ("Started by an SCM change"), and its Deploy stage prints `v1.1`.

## Evidence to Save (`evidence/`)
- `05_build1_console.txt`: Console Output of build #1 (**⋮ → View as plain text** → save)
- `05_build2_console.txt`: build #2, showing *Started by an SCM change*
- Screenshots: stage view (`05_stage_view.png`), test results (`05_test_results.png`), artifacts (`05_artifacts.png`), build history with #1 and #2 (`05_build_history.png`)

## Expected Console Output (Deploy stage)
```
Jenkins CI/CD Demo application v1.0
10 + 5 = 15
10 - 5 = 5
10 * 5 = 50
10 / 5 = 2.0
Deployment successful
Finished: SUCCESS
```
The `java -jar` part of this output was verified on this machine; see `evidence/05_local_compile_check.log`.

## Result
*(Complete after the Jenkins run.)* A Jenkins pipeline fetched the project from GitHub, compiled it, ran the JUnit tests, packaged and archived the JAR, and deployed it. A new commit triggered a second build automatically.

## Viva Questions
1. **What is Continuous Integration?** Automatically building and testing the code every time changes are committed.
2. **CI vs Continuous Delivery/Deployment?** CI builds and tests the code; CD automatically releases or deploys the tested build.
3. **What is a Jenkinsfile?** A text file that defines a Jenkins pipeline as code and is stored with the source code.
4. **What does `pollSCM` do?** It makes Jenkins check the repository on a schedule and start a build when new commits are found.
5. **What does `archiveArtifacts` do?** It stores build outputs (the JAR) with the build so they can be downloaded later.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-05-Jenkins-CICD`
