#!/usr/bin/env bash
# Experiment 4 - start Jenkins LTS (Docker), verify dashboard, plugins and configuration.
source "$(dirname "$0")/common.sh"
init_log Experiment-04-Jenkins-Setup 04_ci_jenkins_setup.log "Experiment 4 - Jenkins LTS installation and setup (Docker container on the CI runner)"
cd "$ROOT/.github/lab-ci/jenkins"
run docker build -t smec-jenkins:lts .
PW=$(openssl rand -hex 16); echo "$PW" > /tmp/jenkins_pw; chmod 600 /tmp/jenkins_pw
echo; echo '$ docker run -d --name jenkins -p 8080:8080 -e JENKINS_ADMIN_PASSWORD=*** smec-jenkins:lts'
docker run -d --name jenkins -p 8080:8080 -e JENKINS_ADMIN_PASSWORD="$PW" smec-jenkins:lts
echo "Waiting for Jenkins to start..."
for i in $(seq 1 90); do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/login || true)
  [ "$code" = 200 ] && break; sleep 3
done
run docker ps --filter name=jenkins
echo; echo '$ curl -sI http://localhost:8080/login'
curl -sI http://localhost:8080/login | grep -iE "^HTTP|^X-Jenkins:" 
check "Jenkins dashboard reachable on http://localhost:8080 (HTTP 200)" '[ "$(curl -s -o /dev/null -w %{http_code} http://localhost:8080/login)" = 200 ]'
run docker exec jenkins java -version
echo; echo '$ GET /me/api/json (authenticated as admin)'
curl -s -u "admin:$PW" http://localhost:8080/me/api/json | jq -r '"Authenticated as: " + .fullName'
echo; echo '$ GET /pluginManager/api/json - key plugins'
curl -s -u "admin:$PW" "http://localhost:8080/pluginManager/api/json?depth=1" \
  | jq -r '.plugins | length as $n | "Installed plugins: \($n)", (map(select(.shortName|IN("git","workflow-aggregator","workflow-job","pipeline-stage-view","junit","timestamper","credentials"))) | sort_by(.shortName)[] | "  \(.shortName)  \(.version)  active=\(.active)")'
echo; echo '$ GET /computer/api/json - executors'
curl -s -u "admin:$PW" http://localhost:8080/computer/api/json | jq -r '.computer[] | "Node: \(.displayName)  executors=\(.numExecutors)  offline=\(.offline)"'
shot http://localhost:8080/ ci_04_jenkins_dashboard.png
