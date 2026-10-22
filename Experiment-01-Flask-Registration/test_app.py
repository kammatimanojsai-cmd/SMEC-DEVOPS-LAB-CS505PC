"""Unit tests for the registration form validation (run with: python -m pytest -v)."""
from app import app


def client():
    app.config["TESTING"] = True
    return app.test_client()


VALID = {"name": "Ravi Kumar", "email": "ravi@example.com", "phone": "9876543210", "event": "DevOps Workshop"}


def test_register_page_loads():
    r = client().get("/register")
    assert r.status_code == 200 and b"Event Registration Form" in r.data


def test_valid_registration():
    r = client().post("/register", data=VALID)
    assert r.status_code == 200 and b"Registration Successful!" in r.data


def test_invalid_email_rejected():
    r = client().post("/register", data={**VALID, "email": "wrong-email"})
    assert r.status_code == 400 and b"Enter a valid email address." in r.data


def test_invalid_phone_rejected():
    r = client().post("/register", data={**VALID, "phone": "12345"})
    assert r.status_code == 400 and b"valid 10-digit mobile number" in r.data


def test_missing_event_rejected():
    r = client().post("/register", data={**VALID, "event": ""})
    assert r.status_code == 400 and b"Please select an event." in r.data
