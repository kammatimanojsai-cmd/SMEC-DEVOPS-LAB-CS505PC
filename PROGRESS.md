# PROGRESS – SMEC DevOps Lab (CS505PC)

_Last updated: 22 Oct 2026, 13:50 IST_

**Where the work was done:** a cloud Linux workspace (Docker 29.9.1, Java 21, Python 3.13, Selenium 4.48.0 + Chromium 141).
The Windows laptop could not be controlled from that session: folder access was declined and desktop control was unavailable.
GitHub credentials were not available there either, and Docker Hub, Maven Central, Jenkins and Kubernetes downloads were blocked by its network policy.
Everything marked ⏳ below is ready to run and only needs your laptop.

Legend: ✅ done and verified · 🟡 partly verified · ⏳ pending (laptop) · ❌ blocked

## Dashboard

All 12 experiments were **executed and verified on GitHub Actions** (run [#3](https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/actions/runs/39745612921), 22 Oct 2026). Evidence is in each `evidence/github-actions` folder; the summary is in [`CI-RESULTS.md`](CI-RESULTS.md).

| Exp | Title | Implementation | Execution | Verification | GitHub | Evidence | Status |
|---|---|---|---|---|---|---|---|
| 01 | Flask registration + Docker | ✅ | ✅ docker build/run (python:3.12-slim) | ✅ HTTP 200, success page, HTTP 400 + 4 errors, 5 unit tests | ✅ pushed | logs + screenshots | **Completed** (GitHub Actions) |
| 02 | Git & GitHub commands | ✅ | ✅ all commands + real PR #1 | ✅ branch/merge/push/clone, PR merged | ✅ pushed | logs | **Completed** (GitHub Actions) |
| 03 | SCM with Exp 1 code | ✅ | ✅ | ✅ branch/merge/tag, code on GitHub | ✅ pushed | logs | **Completed** (GitHub Actions) |
| 04 | Jenkins setup | ✅ | ✅ Jenkins LTS (Docker) on CI | ✅ dashboard HTTP 200, plugins, executors | ✅ pushed | log + 2 screenshots | **Completed** (GitHub Actions) |
| 05 | Jenkins CI/CD | ✅ | ✅ pipeline job from Jenkinsfile | ✅ build #1 SUCCESS (5 JUnit tests, JAR, deploy); build #2 auto-started by SCM change, deployed v1.1 | ✅ pushed | log + consoles + 3 screenshots | **Completed** (GitHub Actions) |
| 06 | Docker commands | ✅ | ✅ pull/images/run/ps/stop/start/rm/push | ✅ pulled from Docker Hub, pushed to ghcr.io | ✅ pushed | logs | **Completed** (GitHub Actions) |
| 07 | Docker hello app | ✅ | ✅ | ✅ `Hello, World!` in docker logs | ✅ pushed | logs | **Completed** (GitHub Actions) |
| 08 | Kubernetes + Docker | ✅ | ✅ kind cluster | ✅ deploy, service, scale 4, rolling update + undo | ✅ pushed | log | **Completed** (GitHub Actions) |
| 09 | Kubernetes automation | ✅ | ✅ kind cluster | ✅ 3/3 replicas ready, load-balanced Service, self-healing | ✅ pushed | log | **Completed** (GitHub Actions) |
| 10 | Selenium setup | ✅ | ✅ | ✅ Chrome opened selenium.dev, title read | ✅ pushed | log + screenshot | **Completed** (GitHub Actions) |
| 11 | JavaScript + Selenium | ✅ | ✅ | ✅ 5/5 tests, 0 → 1 | ✅ pushed | log + 2 screenshots | **Completed** (GitHub Actions) |
| 12 | Selenium on container | ✅ | ✅ | ✅ 7/7 tests vs Docker container | ✅ pushed | log + 2 screenshots | **Completed** (GitHub Actions) |

Optional: re-run on your own laptop (your Jenkins at localhost:8080, Docker Desktop, minikube) with `START-HERE.bat` to add laptop screenshots.

## Remaining Work – in Order (on the Windows laptop)

**Easiest:** double-click `START-HERE.bat`. It does steps 1–9 below automatically and writes `RUN-ALL-summary.md`.

1. [x] Push to GitHub - **done**: https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC
2. [ ] Exp 4 – `Experiment-04-Jenkins-Setup\check-jenkins.ps1` (as Administrator) + 5 screenshots
3. [ ] Exp 5 – create the Jenkins pipeline job → build #1 → commit `VERSION = "1.1"` → push → build #2 (auto) → save consoles + screenshots
4. [ ] Exp 6 – `Experiment-06-Docker-Commands\docker-commands.ps1` (after `docker login` for push)
5. [ ] Exp 8 – install kubectl + minikube → `Experiment-08-Docker-Kubernetes\run-k8s.ps1`
6. [ ] Exp 9 – `Experiment-09-Kubernetes-Automation\run-k8s.ps1`
7. [ ] Exp 2 – run the pull-request steps in its README
8. [ ] Re-run Exp 1, 7, 10, 11, 12 on the laptop and add laptop screenshots (recommended for the viva)
9. [ ] Commit the new evidence: `git add . ; git commit -m "Add laptop evidence" ; git push`
10. [ ] Update this table: change ⏳ to ✅ only after each step really succeeds

## Known Deviations (documented in each README)
- Evidence for Exp 1/6/7/12 was built on a **local Python base image** because Docker Hub was blocked; the Dockerfiles still default to `python:3.12-slim`.
- Exp 9: `hello.py` gained an optional HTTP mode (`HELLO_HTTP_PORT`) so three Kubernetes replicas stay Running instead of crash-looping.
- Exp 12 tests the Flask app (Exp 1), because the Exp 7 console program has no web form.
- Exp 10 opened the local Exp 1 page instead of selenium.dev (no public internet for the browser there).
- The original 27-page PDF manual was not received in the session, so the experiments follow the 12 aims listed in the task brief.
