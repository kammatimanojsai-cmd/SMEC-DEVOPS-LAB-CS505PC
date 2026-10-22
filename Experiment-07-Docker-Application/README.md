# Experiment 7 – Simple Containerised Application using Docker

**Status:** ✅ Executed and verified. The container printed `Hello, World!`, and this was confirmed with `docker logs` (`evidence/07_execution.log`).

## AIM
To develop a simple Python application, containerise it with a Dockerfile, run it, and verify its "Hello World" output using `docker logs`.

## Software Requirements
Python 3.12+, Docker Desktop / Docker Engine.

## Files
- `hello.py`: prints the Hello World message and some container details. If the `HELLO_HTTP_PORT` environment variable is set (used only in Experiment 9), it also serves the message over HTTP so a Kubernetes pod stays running.
- `Dockerfile`:
  ```dockerfile
  ARG BASE_IMAGE=python:3.12-slim
  FROM ${BASE_IMAGE}
  WORKDIR /app
  COPY hello.py .
  CMD ["python", "hello.py"]
  ```

## Procedure
1. Write `hello.py` and test it with `python hello.py`.
2. Write the Dockerfile.
3. Build the image: `docker build -t hello-app:1.0 .`
4. Run a container: `docker run --name hello-container hello-app:1.0`
5. Verify the output with `docker logs hello-container`.
6. Commit the files to GitHub.

## Execution Commands (PowerShell)
```powershell
python hello.py
docker build -t hello-app:1.0 .
docker images hello-app
docker run --name hello-container hello-app:1.0
docker ps -a --filter name=hello-container
docker logs hello-container
docker rm hello-container
```

## Verified Output (`evidence/07_execution.log`)
```
$ docker run --name hello-container hello-app:1.0
Hello, World!
Hello from a Docker container - SMEC DevOps Lab (CS505PC)
Python version : 3.13.16
Container host : 499229f6cea2
$ docker ps -a --filter name=hello-container
... "python hello.py" ... Exited (0) ... hello-container
$ docker logs hello-container | grep "Hello, World!"
VERIFIED: 'Hello, World!' found in container logs
```
(The verification machine built the image on a local Python base image because Docker Hub was blocked. On your laptop the default `python:3.12-slim` is used and shows Python 3.12.x.)

## Result
A Python Hello World application was containerised, run, and its output was verified with `docker logs`.

## Viva Questions
1. **What is containerisation?** Packaging an application with everything it needs so it runs the same everywhere.
2. **Why does the container show `Exited (0)`?** The program finished successfully; a container stops when its main process ends.
3. **`CMD` vs `RUN`?** `RUN` executes while the image is being built; `CMD` is the default command when a container starts.
4. **What does `docker logs` show?** The standard output and error stream of a container.
5. **What is a base image?** The starting image in `FROM` (here `python:3.12-slim`) that your image is built on.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-07-Docker-Application`
