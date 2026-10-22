#!/usr/bin/env bash
# Experiment 2 - Git & GitHub command walkthrough.
# REMOTE_URL: your GitHub repo URL (e.g. https://github.com/<user>/git-lab-demo.git).
# If not set, a local bare repository is used as the "remote" so every command still runs.
set -e
WORK=${WORK:-$PWD/git-demo-workspace}
REMOTE_URL=${REMOTE_URL:-}
rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"
run() { echo; echo "\$ $*"; "$@"; }
if [ -z "$REMOTE_URL" ]; then git init -q --bare -b main remote-repo.git; REMOTE_URL="$WORK/remote-repo.git"; echo "# Using local bare repo as remote: remote-repo.git"; fi

run git --version
mkdir git-lab-demo && cd git-lab-demo
run git init -b main
run git config user.name  "${GIT_NAME:-SMEC Student}"
run git config user.email "${GIT_EMAIL:-student@example.com}"
echo "# Git Lab Demo" > README.md
run git status
run git add README.md
run git status --short
run git commit -m "Initial commit: add README"
printf 'def greet(name):\n    return f"Hello, {name}!"\n' > greet.py
run git add greet.py
run git commit -m "Add greet function"
run git log --oneline
run git branch feature-login
run git branch
run git switch feature-login
printf 'def login(user):\n    return user == "admin"\n' > login.py
run git add login.py
run git commit -m "Add login feature"
run git checkout main
run git merge --no-ff feature-login -m "Merge branch 'feature-login'"
run git log --oneline --graph --all
run git remote add origin "$REMOTE_URL"
run git remote -v
run git push -u origin main
run git push origin feature-login
cd ..
run git clone "$REMOTE_URL" cloned-copy
run git -C cloned-copy log --oneline -3
run ls cloned-copy
run git branch -d feature-login 2>/dev/null || true
