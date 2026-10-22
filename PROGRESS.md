# PROGRESS – SMEC DevOps Lab (CS505PC)

_Last updated: 22 Oct 2026, 10:50 IST_

**Where the work was done:** a cloud Linux workspace (Docker 29.9.1, Java 21, Python 3.13, Selenium 4.48.0 + Chromium 141).
The Windows laptop could not be controlled from that session: folder access was declined and desktop control was unavailable.
GitHub credentials were not available there either, and Docker Hub, Maven Central, Jenkins and Kubernetes downloads were blocked by its network policy.
Everything marked ⏳ below is ready to run and only needs your laptop.

Legend: ✅ done and verified · 🟡 partly verified · ⏳ pending (laptop) · ❌ blocked

## Dashboard

| Exp | Title | Implementation | Execution | Verification | GitHub | Evidence | Status |
|---|---|---|---|---|---|---|---|
| 01 | Flask registration + Docker | ✅ | ✅ docker build/run | ✅ HTTP 200, success + 400 validation, 5 unit tests | ✅ pushed | logs + 3 screenshots | **Completed** (cloud) |
| 02 | Git & GitHub commands | ✅ | ✅ local remote | ✅ log/branch/merge/push/clone | ✅ pushed (PR pending) | log | **Partial** – PR pending |
| 03 | SCM with Exp 1 code | ✅ | ✅ local central repo | ✅ branch/merge/tag | ✅ pushed | log | **Completed** (cloud; code on GitHub) |
| 04 | Jenkins setup | ✅ check script | ⏳ | ⏳ | ✅ pushed | – | **Pending (laptop)** |
| 05 | Jenkins CI/CD | ✅ Maven + Jenkinsfile | 🟡 javac/jar/run only | ⏳ mvn test + Jenkins builds #1/#2 | ✅ pushed | partial log | **Partial** |
| 06 | Docker commands | ✅ .sh + .ps1 | 🟡 all except pull/push | 🟡 | ✅ pushed | log | **Partial** – pull/push pending |
| 07 | Docker hello app | ✅ | ✅ | ✅ `Hello, World!` in docker logs | ✅ pushed | log | **Completed** (cloud) |
| 08 | Kubernetes + Docker | ✅ YAML + script | ⏳ | YAML structure checked only | ✅ pushed | – | **Pending (laptop)** |
| 09 | Kubernetes automation | ✅ YAML (3 replicas) + script | ⏳ (Docker pre-check ✅) | ⏳ | ✅ pushed | pre-check log | **Pending (laptop)** |
| 10 | Selenium setup | ✅ | ✅ | ✅ title read, exit 0 | ✅ pushed | log | **Completed** (cloud) |
| 11 | JavaScript + Selenium | ✅ | ✅ | ✅ 5/5 tests, 0 → 1 | ✅ pushed | log + 2 screenshots | **Completed** (cloud) |
| 12 | Selenium on container | ✅ | ✅ | ✅ 7/7 tests vs Docker container | ✅ pushed | log + 2 screenshots | **Completed** (cloud) |

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
