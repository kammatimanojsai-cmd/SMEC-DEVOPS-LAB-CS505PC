#!/usr/bin/env bash
# Experiment 5 - CI/CD: local Maven build, then a real Jenkins pipeline job from the repo's Jenkinsfile,
# build #1 (manual) and build #2 (triggered automatically by a new commit through pollSCM).
source "$(dirname "$0")/common.sh"
init_log Experiment-05-Jenkins-CICD 05_ci_jenkins_pipeline.log "Experiment 5 - Continuous integration and delivery with Jenkins"
PW=$(cat /tmp/jenkins_pw); J=http://localhost:8080; JOB=SMEC-Exp5-CICD
cd "$ROOT/Experiment-05-Jenkins-CICD"
run ./mvnw -B -q clean package
run java -jar target/jenkins-cicd-demo.jar
cd "$ROOT"

# Branch that Jenkins builds (keeps main untouched)
git config user.name "github-actions[bot]"; git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
run git push -f origin HEAD:refs/heads/jenkins-demo

crumb() { curl -s -c /tmp/cj -b /tmp/cj -u "admin:$PW" "$J/crumbIssuer/api/json" | jq -r '.crumbRequestField + ":" + .crumb'; }
jpost() { curl -s -o /dev/null -w '%{http_code}' -c /tmp/cj -b /tmp/cj -u "admin:$PW" -H "$(crumb)" -X POST "$@"; }
build_json() { curl -s -u "admin:$PW" "$J/job/$JOB/$1/api/json" || true; }
wait_build() { # <num> <timeout-seconds>
  local end=$(( $(date +%s) + $2 ))
  while [ "$(date +%s)" -lt "$end" ]; do
    b=$(build_json "$1"); if [ -n "$b" ] && echo "$b" | jq -e '.building == false' >/dev/null 2>&1; then echo "$b" | jq -r '.result'; return 0; fi
    sleep 10
  done; echo TIMEOUT; }

sed "s#__REPO_URL__#${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}.git#" .github/lab-ci/jenkins/job-config.xml > /tmp/job.xml
echo; echo "\$ POST /createItem?name=$JOB  (Pipeline from SCM: ${GITHUB_REPOSITORY}, branch jenkins-demo, Script Path Experiment-05-Jenkins-CICD/Jenkinsfile)"
echo "HTTP $(jpost -H 'Content-Type: application/xml' --data-binary @/tmp/job.xml "$J/createItem?name=$JOB")"
echo; echo "\$ POST /job/$JOB/build   (build #1, started manually)"
echo "HTTP $(jpost "$J/job/$JOB/build")"
sleep 15
R1=$(wait_build 1 1200); echo "Build #1 result: $R1"
curl -s -u "admin:$PW" "$J/job/$JOB/1/consoleText" > "$OUT/05_ci_build1_console.txt"
echo; echo "----- build #1 console (key lines) -----"
grep -E "Started by|Checking out Revision|\[Pipeline\] stage|Tests run:|BUILD SUCCESS|jenkins-cicd-demo.jar|Jenkins CI/CD Demo application|Deployment successful|Finished:" "$OUT/05_ci_build1_console.txt" | grep -v "^\[Pipeline\] { (" | head -60
check "Jenkins build #1 SUCCESS" '[ "$R1" = SUCCESS ]'
check "JUnit tests ran in Jenkins (5 tests, 0 failures)" 'grep -q "Tests run: 5, Failures: 0, Errors: 0" "$OUT/05_ci_build1_console.txt"'
curl -s -u "admin:$PW" "$J/job/$JOB/1/testReport/api/json" | jq -r '"Jenkins test report: passed=\(.passCount) failed=\(.failCount) skipped=\(.skipCount)"'
curl -s -u "admin:$PW" "$J/job/$JOB/1/api/json" | jq -r '.artifacts[] | "Archived artifact: " + .relativePath'

# New commit -> pollSCM (H/2 * * * *) should start build #2 on its own
echo; echo "########## Pushing a new commit to trigger the next build automatically ##########"
sed -i 's/VERSION = "1.0"/VERSION = "1.1"/' Experiment-05-Jenkins-CICD/src/main/java/in/smec/devops/App.java
run git commit -q -am "Exp 5: bump version to 1.1 (should trigger Jenkins automatically)"
run git log --oneline -1
run git push -f origin HEAD:refs/heads/jenkins-demo
echo "Waiting for Jenkins to poll GitHub and start build #2 by itself (up to 8 minutes)..."
for i in $(seq 1 48); do [ -n "$(build_json 2)" ] && break; sleep 10; done
R2=$(wait_build 2 1200); echo "Build #2 result: $R2"
curl -s -u "admin:$PW" "$J/job/$JOB/2/consoleText" > "$OUT/05_ci_build2_console.txt"
echo; echo "----- build #2 console (key lines) -----"
grep -E "Started by|Checking out Revision|Commit message|Tests run:|Jenkins CI/CD Demo application|Deployment successful|Finished:" "$OUT/05_ci_build2_console.txt" | head -30
check "Build #2 was started automatically by an SCM change" 'grep -q "Started by an SCM change" "$OUT/05_ci_build2_console.txt"'
check "Jenkins build #2 SUCCESS and deployed v1.1" '[ "$R2" = SUCCESS ] && grep -q "application v1.1" "$OUT/05_ci_build2_console.txt"'
echo; echo '$ GET /job/'$JOB'/api/json - build history'
curl -s -u "admin:$PW" "$J/job/$JOB/api/json?tree=builds[number,result,timestamp]" | jq -r '.builds[] | "#\(.number)  \(.result)"'
shot "$J/job/$JOB/" ci_05_jenkins_stage_view.png 1400,900
shot "$J/job/$JOB/1/testReport/" ci_05_jenkins_test_report.png 1200,850
shot "$J/job/$JOB/2/console" ci_05_build2_started_by_scm_change.png 1300,900
# Exp 4 also gets a dashboard screenshot that now shows the job
cp "$OUT/ci_05_jenkins_stage_view.png" "$ROOT/ci-out/Experiment-04-Jenkins-Setup/evidence/github-actions/ci_04_jenkins_job_list.png" 2>/dev/null || true
