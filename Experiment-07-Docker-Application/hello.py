"""Experiment 7 - Simple containerised application.

Default behaviour: print a Hello World message and exit (docker run / docker logs).
If HELLO_HTTP_PORT is set (used by Kubernetes in Experiment 9), it also serves the
same message over HTTP so the pod keeps running and can sit behind a Service.
"""
import datetime
import os
import platform
from http.server import BaseHTTPRequestHandler, HTTPServer

MESSAGE = "Hello, World!"

print(MESSAGE)
print("Hello from a Docker container - SMEC DevOps Lab (CS505PC)")
print(f"Python version : {platform.python_version()}")
print(f"Container host : {platform.node()}")
print(f"Started at     : {datetime.datetime.now():%Y-%m-%d %H:%M:%S}", flush=True)


class HelloHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"{MESSAGE} Served by pod/container: {platform.node()}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


port = os.environ.get("HELLO_HTTP_PORT")
if port:
    print(f"HTTP mode enabled - listening on port {port}", flush=True)
    HTTPServer(("0.0.0.0", int(port)), HelloHandler).serve_forever()
