# Experiment 1 - Flask Event Registration
# BASE_IMAGE defaults to the official image. It can be overridden with
#   docker build --build-arg BASE_IMAGE=<image> .
ARG BASE_IMAGE=python:3.12-slim
FROM ${BASE_IMAGE}

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY templates/ templates/

EXPOSE 5000
CMD ["python", "app.py"]
