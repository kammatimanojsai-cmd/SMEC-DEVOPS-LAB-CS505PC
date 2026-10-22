"""Experiment 1 - Event Registration Form using Flask (containerised with Docker)."""
import re
from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

EVENTS = ["DevOps Workshop", "Cloud Bootcamp", "Hackathon 2026"]
EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
PHONE_RE = re.compile(r"^[6-9]\d{9}$")          # 10-digit Indian mobile number
registrations = []                                # in-memory store (lab demo)


def validate(form):
    """Return a dict of field -> error message. Empty dict means valid."""
    errors = {}
    name = form.get("name", "").strip()
    email = form.get("email", "").strip()
    phone = form.get("phone", "").strip()
    event = form.get("event", "").strip()
    if len(name) < 3:
        errors["name"] = "Name must contain at least 3 characters."
    if not EMAIL_RE.match(email):
        errors["email"] = "Enter a valid email address."
    if not PHONE_RE.match(phone):
        errors["phone"] = "Enter a valid 10-digit mobile number."
    if event not in EVENTS:
        errors["event"] = "Please select an event."
    return errors


@app.route("/")
def home():
    return redirect(url_for("register"))


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        errors = validate(request.form)
        if errors:
            return render_template("register.html", events=EVENTS,
                                   errors=errors, form=request.form), 400
        entry = {k: request.form[k].strip() for k in ("name", "email", "phone", "event")}
        registrations.append(entry)
        return render_template("success.html", entry=entry, count=len(registrations))
    return render_template("register.html", events=EVENTS, errors={}, form={})


@app.route("/health")
def health():
    return {"status": "UP", "registrations": len(registrations)}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
