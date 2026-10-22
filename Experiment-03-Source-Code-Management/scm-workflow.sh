#!/usr/bin/env bash
# Experiment 3 - Source code management of the Experiment 1 Flask application.
# Usage on your laptop (Git Bash):
#   REMOTE_URL=https://github.com/<you>/event-registration-flask.git ./scm-workflow.sh
# Without REMOTE_URL a local bare repository is used as the central server.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
APP_SRC="$HERE/../Experiment-01-Flask-Registration"
WORK=${WORK:-$HERE/scm-workspace}
REMOTE_URL=${REMOTE_URL:-}
rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"
run() { echo; echo "\$ $*"; "$@"; }
if [ -z "$REMOTE_URL" ]; then git init -q --bare -b main central.git; REMOTE_URL="$WORK/central.git"; echo "# Central repository (local bare repo): central.git"; fi

echo; echo "########## Developer A: import the Experiment 1 project ##########"
mkdir dev-a && cd dev-a
run git init -b main
git config user.name "${GIT_NAME:-Developer A}"; git config user.email "${GIT_EMAIL:-dev-a@example.com}"
cp -r "$APP_SRC"/{app.py,requirements.txt,Dockerfile,.dockerignore,test_app.py,templates} .
printf '__pycache__/\n*.pyc\n.venv/\n' > .gitignore
run git add .
run git status --short
run git commit -m "Import Flask event registration app (Experiment 1)"
run git remote add origin "$REMOTE_URL"
run git push -u origin main
run git tag -a v1.0 -m "Release 1.0 - registration form"
run git push origin v1.0
cd ..

echo; echo "########## Developer B: clone, branch, change, push ##########"
run git clone "$REMOTE_URL" dev-b
cd dev-b
git config user.name "Developer B"; git config user.email "dev-b@example.com"
run git switch -c feature/add-workshop-event
sed -i 's/EVENTS = \["DevOps Workshop", "Cloud Bootcamp", "Hackathon 2026"\]/EVENTS = ["DevOps Workshop", "Cloud Bootcamp", "Hackathon 2026", "Kubernetes Workshop"]/' app.py
run git diff
run git commit -am "Add Kubernetes Workshop to the event list"
run git push -u origin feature/add-workshop-event
run git branch -a
cd ..

echo; echo "########## Developer A: review and merge the feature branch ##########"
cd dev-a
run git fetch origin
run git branch -r
run git log --oneline main..origin/feature/add-workshop-event
run git merge --no-ff origin/feature/add-workshop-event -m "Merge feature/add-workshop-event"
run git push origin main
run git push origin --delete feature/add-workshop-event
run git log --oneline --graph --decorate -6
run git ls-remote --heads --tags origin
