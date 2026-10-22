# Experiment 1 – Event Registration Form using Flask and Docker

**Status:** ✅ Executed and verified (cloud Linux workspace, Docker 29.9.1). Re-run on your laptop before the exam (steps below).

## AIM
To create a simple event registration web form with Flask, containerise it with Docker, and run it on `http://localhost:5000/register`.

## Software Requirements
| Software | Version used | Purpose |
|---|---|---|
| Python | 3.12 (image) / 3.13 (verification run) | Runtime |
| Flask | 3.1.x | Web framework |
| Docker Desktop / Engine | 29.x | Build and run the container |
| Web browser | Chrome | View the form |

## Project Structure
```
Experiment-01-Flask-Registration/
├── app.py                 # Flask routes + server-side validation
├── templates/
│   ├── register.html      # registration form
│   └── success.html       # success page
├── requirements.txt       # Flask>=3.0,<4.0
├── Dockerfile             # python:3.12-slim based image
├── .dockerignore
├── test_app.py            # 5 pytest unit tests
└── evidence/              # real logs + screenshots
```

## Algorithm / Procedure
1. Create the Flask app with a `/register` route that handles GET (show form) and POST (validate and save).
2. Validate the fields: name ≥ 3 characters, valid email, 10-digit mobile number starting with 6–9, and an event chosen from the list.
3. If validation fails, re-display the form with error messages (HTTP 400). If it passes, show `success.html`.
4. Write `requirements.txt` and a `Dockerfile` (base image → install requirements → copy code → `EXPOSE 5000` → `CMD python app.py`).
5. Build the image with `docker build`, run it with `docker run -p 5000:5000`, and open `http://localhost:5000/register`.

## Execution Commands (Windows PowerShell, inside this folder)
```powershell
# optional: run without Docker
pip install -r requirements.txt
python -m pytest -v test_app.py
python app.py                     # then open http://localhost:5000/register  (Ctrl+C to stop)

# with Docker
docker build -t event-registration:1.0 .
docker images event-registration
docker run -d --name event-app -p 5000:5000 event-registration:1.0
docker ps
start http://localhost:5000/register
docker logs event-app
docker stop event-app; docker rm event-app
```

## Verified Output (from `evidence/01_docker_execution.log`)
```
$ docker run -d --name event-app -p 5000:5000 event-registration:1.0
$ docker ps --filter name=event-app
CONTAINER ID   IMAGE                    COMMAND           STATUS         PORTS
49b11bea16ac   event-registration:1.0   "python app.py"   Up 3 seconds   0.0.0.0:5000->5000/tcp
$ curl http://localhost:5000/register   -> HTTP 200, <h2>Event Registration Form</h2>
$ POST valid data                       -> "Registration Successful!"  Ravi Kumar / DevOps Workshop
$ POST invalid data                     -> HTTP 400 with 4 validation errors
```
Unit tests (`evidence/01_unit_tests.log`): **5 passed**.

> **Note about the evidence:** Docker Hub was blocked on the cloud machine that produced these logs, so `docker build` there used
> `--build-arg BASE_IMAGE=smec/python-base:local`, a locally built Python image. The Dockerfile itself is unchanged and defaults to
> `python:3.12-slim`, so on your laptop you build it with the plain command above.

## Screenshots
| File | Shows |
|---|---|
| `evidence/screenshot_01_register_form.png` | Registration form served by the container |
| `evidence/screenshot_02_validation_errors.png` | Server-side validation messages |
| `evidence/screenshot_03_success_page.png` | Successful registration page |

Take your own laptop screenshots too: `docker ps` in PowerShell and the form at `localhost:5000/register` in Chrome.

## Result
The Flask event registration application was developed, containerised with Docker, and verified at `localhost:5000/register`. It accepts valid registrations and rejects invalid input.

## Viva Questions
1. **What is Flask?** A lightweight Python web framework (a "micro-framework") for building web apps and APIs.
2. **What does a Dockerfile do?** It is a text file of instructions (`FROM`, `COPY`, `RUN`, `CMD`, …) that Docker uses to build an image.
3. **Difference between an image and a container?** An image is a read-only template; a container is a running instance of an image.
4. **What does `-p 5000:5000` mean?** It maps host port 5000 to container port 5000 so the browser on the host can reach the app.
5. **Why use `host="0.0.0.0"` in `app.run()`?** So Flask listens on all network interfaces inside the container, not only on the container's own localhost.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-01-Flask-Registration`

## Demonstration to the Examiner
1. Show `app.py`, `register.html` and `Dockerfile`.
2. Run `docker build -t event-registration:1.0 .` and then `docker run -d --name event-app -p 5000:5000 event-registration:1.0`.
3. Open `localhost:5000/register`, submit an invalid form (errors appear), then a valid one (success page).
4. Show `docker ps` and `docker logs event-app`.
