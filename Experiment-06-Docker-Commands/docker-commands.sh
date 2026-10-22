#!/usr/bin/env bash
# Experiment 6 - Docker command walkthrough (bash version; see docker-commands.ps1 for Windows)
# IMAGE  : image used for the run/stop/start demo
# PULL_IMAGE : maintained public image used for docker pull
IMAGE=${IMAGE:-nginx:stable-alpine}
PULL_IMAGE=${PULL_IMAGE:-nginx:stable-alpine}
CONTAINER_PORT=${CONTAINER_PORT:-80}   # 80 for nginx, 5000 for the Flask image
DOCKERHUB_USER=${DOCKERHUB_USER:-}
run() { echo; echo "\$ $*"; "$@"; }

run docker --version
run docker pull "$PULL_IMAGE"
run docker images
run docker run -d --name demo-web -p 8081:$CONTAINER_PORT "$IMAGE"
sleep 3
run docker ps
run docker logs demo-web
run docker exec demo-web cat /etc/hostname
run docker inspect --format 'Name={{.Name}} Image={{.Config.Image}} Status={{.State.Status}} Started={{.State.StartedAt}}' demo-web
run curl -s -o /dev/null -w "HTTP %{http_code} from http://localhost:8081\n" http://localhost:8081/
run docker stop demo-web
run docker ps -a --filter name=demo-web
run docker start demo-web
run docker ps --filter name=demo-web
run docker stop demo-web
run docker rm demo-web
run docker tag "$IMAGE" smec-demo:copy
run docker images smec-demo
run docker rmi smec-demo:copy
run docker ps -a --filter name=demo-web
if [ -n "$DOCKERHUB_USER" ]; then
  run docker tag "$IMAGE" "$DOCKERHUB_USER/smec-demo:1.0"
  run docker push "$DOCKERHUB_USER/smec-demo:1.0"
else
  echo; echo "# docker push skipped: set DOCKERHUB_USER after 'docker login' to demonstrate push"
fi
