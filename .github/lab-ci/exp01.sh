#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-01-Flask-Registration 01_ci_execution.log "Experiment 1 - Flask event registration form + Docker"
cd "$ROOT/Experiment-01-Flask-Registration"
run python --version
run python -m pip install -q -r requirements.txt pytest
run python -m pytest -v test_app.py
run docker build -t event-registration:1.0 .
run docker images event-registration
run docker run -d --name event-app -p 5000:5000 event-registration:1.0
wait_http http://localhost:5000/health 30
run docker ps --filter name=event-app
echo; echo '$ curl http://localhost:5000/register'
code=$(curl -s -o /tmp/r.html -w '%{http_code}' http://localhost:5000/register); echo "HTTP $code"; grep -E "<title>|<h2>" /tmp/r.html | sed 's/^ *//'
check "registration page served with HTTP 200" '[ "$code" = 200 ]'
echo; echo '$ curl -X POST (valid data) http://localhost:5000/register'
curl -s -X POST --data-urlencode "name=Ravi Kumar" -d email=ravi@example.com -d phone=9876543210 --data-urlencode "event=DevOps Workshop" http://localhost:5000/register > /tmp/s.html
grep -E "successMessage|regName|regEvent" /tmp/s.html | sed 's/^ *//'
check "valid registration shows the success page" 'grep -q "Registration Successful!" /tmp/s.html'
echo; echo '$ curl -X POST (invalid data) http://localhost:5000/register'
code=$(curl -s -o /tmp/i.html -w '%{http_code}' -X POST -d "name=Ra&email=bad&phone=123&event=" http://localhost:5000/register); echo "HTTP $code"
grep 'class="error"' /tmp/i.html | sed 's/^ *//'
check "invalid input rejected with HTTP 400 and 4 errors" '[ "$code" = 400 ] && [ "$(grep -c "class=\"error\"" /tmp/i.html)" = 4 ]'
run curl -s http://localhost:5000/health; echo
shot http://localhost:5000/register ci_01_register_form.png 900,720
run docker logs event-app
