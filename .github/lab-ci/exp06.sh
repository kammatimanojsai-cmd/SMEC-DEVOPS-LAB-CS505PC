#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
init_log Experiment-06-Docker-Commands 06_ci_execution.log "Experiment 6 - Docker commands (pull from Docker Hub, push to GitHub Container Registry)"
cd "$ROOT/Experiment-06-Docker-Commands"
OWNER=$(echo "$GITHUB_REPOSITORY_OWNER" | tr 'A-Z' 'a-z')
echo; echo '$ echo $GITHUB_TOKEN | docker login ghcr.io -u <github-user> --password-stdin'
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin
IMAGE=nginx:stable-alpine PULL_IMAGE=nginx:stable-alpine CONTAINER_PORT=80 DOCKERHUB_USER="ghcr.io/$OWNER" bash docker-commands.sh
check "nginx:stable-alpine pulled from Docker Hub" "docker image inspect nginx:stable-alpine >/dev/null"
run docker pull hello-world
run docker run --rm hello-world
run docker images
check "image pushed to ghcr.io/$OWNER/smec-demo:1.0" "docker manifest inspect ghcr.io/$OWNER/smec-demo:1.0 >/dev/null"
