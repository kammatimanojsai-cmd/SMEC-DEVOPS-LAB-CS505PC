# Experiment 6 – Exploring Docker Commands

**Status:** 🟡 **Mostly verified.** `images`, `run`, `ps`, `logs`, `exec`, `inspect`, `stop`, `start`, `rm`, `tag` and `rmi` all ran successfully (`evidence/06_execution.log`).
⏳ `docker pull` and `docker push` need Docker Hub, which was blocked on the machine that prepared this; the log shows the real `pull` error. Run `docker-commands.ps1` on your laptop to complete them.

## AIM
To explore the basic Docker commands for managing images and containers: pull, images, run, ps, stop, start, rm and push.

## Software Requirements
Docker Desktop for Windows (WSL 2 backend), plus a Docker Hub account for `push`.

## Command Reference
| Command | Purpose |
|---|---|
| `docker pull nginx:stable-alpine` | Download an image from Docker Hub |
| `docker images` | List local images |
| `docker run -d --name demo-web -p 8081:80 nginx:stable-alpine` | Create and start a container (detached, port-mapped) |
| `docker ps` / `docker ps -a` | List running / all containers |
| `docker logs demo-web` | Show container output |
| `docker exec demo-web cat /etc/hostname` | Run a command inside a running container |
| `docker inspect demo-web` | Show detailed container metadata |
| `docker stop demo-web` | Stop a running container |
| `docker start demo-web` | Start a stopped container |
| `docker rm demo-web` | Remove a stopped container |
| `docker tag <img> <user>/<repo>:1.0` | Give an image a registry name |
| `docker login` + `docker push <user>/<repo>:1.0` | Upload an image to Docker Hub |
| `docker rmi <image>` | Remove an image |

### Differences from older manual examples
- `nginx:stable-alpine` and `hello-world` are maintained official images. Older tags and deprecated images in older manuals may fail to pull or be very large.
- `docker container ls` / `docker image ls` are the modern equivalents of `docker ps` / `docker images`; both forms work.
- Docker Hub needs `docker login` (with an access token recommended) before `push`, and the image must be tagged `<username>/<repo>:<tag>`.
- In Docker 29, `{{.NetworkSettings.IPAddress}}` is no longer filled in by `docker inspect`. Use `{{.State.Status}}`, `{{.Config.Image}}` or `docker inspect <name>` without a format instead.

## Execution
**Windows (PowerShell, Docker Desktop running):**
```powershell
docker login                                  # only for the push step
$env:DOCKERHUB_USER = "<your Docker Hub username>"
powershell -ExecutionPolicy Bypass -File .\docker-commands.ps1
```
Log saved to `evidence/06_execution_laptop.log`.

**Git Bash / Linux:** `./docker-commands.sh` (accepts `IMAGE`, `CONTAINER_PORT` and `DOCKERHUB_USER` variables).

## Verified Output (excerpt from `evidence/06_execution.log`)
```
$ docker run -d --name demo-web -p 8081:5000 event-registration:1.0
$ docker ps
CONTAINER ID   IMAGE                    STATUS         PORTS                    NAMES
9d92a55e3b57   event-registration:1.0   Up 3 seconds   0.0.0.0:8081->5000/tcp   demo-web
$ docker stop demo-web       -> demo-web
$ docker ps -a               -> Exited (137)
$ docker start demo-web      -> Up Less than a second
$ docker rm demo-web         -> demo-web
$ docker pull nginx:stable-alpine
Error response from daemon: ... lookup registry-1.docker.io ... no such host   (Docker Hub blocked on that machine)
```

## Result
The Docker image and container lifecycle commands were executed and verified. Pull and push are to be shown on the laptop with Docker Hub access.

## Viva Questions
1. **What is Docker?** A platform that packages applications and their dependencies into portable containers.
2. **What does `docker run -d` do?** Runs the container in the background (detached mode).
3. **`docker stop` vs `docker rm`?** `stop` halts a container but keeps it; `rm` deletes the stopped container.
4. **What is Docker Hub?** A public registry for storing and sharing Docker images.
5. **What is the difference between `docker exec` and `docker run`?** `run` creates a new container; `exec` runs a command inside an existing running container.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-06-Docker-Commands`
