# Experiment 12 – Selenium Test Cases for the Containerised Application

**Status:** ✅ Executed and verified. **7 of 7 Selenium tests passed** against the Experiment 1 Flask app running in a Docker container (`evidence/12_test_results.log` and screenshots).

## AIM
To develop Selenium test cases that check page loading and form submission for a containerised web application.

## Adaptation from the Manual
The Experiment 7 "Hello World" program is a console application with no web page or form, so it cannot be tested with Selenium.
These tests therefore target the **Flask event registration application from Experiment 1**, running in Docker on `http://localhost:5000`. The test code uses that app's real route (`/register`), its field ids (`name`, `email`, `phone`, `event`, `submitBtn`) and its success message (`Registration Successful!`).

## Software Requirements
Docker Desktop, JDK 17+, Maven 3.9+, Google Chrome, Selenium Java 4.48.0.

## Test Cases
| ID | Test | Expected Result |
|---|---|---|
| TC1 | Open `/register` | Title = `Event Registration` |
| TC2 | Heading | `Event Registration Form` |
| TC3 | Form fields present | name, email, phone, event |
| TC4 | Submit valid data | `Registration Successful!` |
| TC5 | Success page data | Shows the submitted name and event |
| TC6 | Invalid email | Error `Enter a valid email address.` |
| TC7 | Empty form | 4 validation errors |

## Procedure
1. Build and start the container:
   ```powershell
   docker build -t event-registration:1.0 ..\Experiment-01-Flask-Registration
   docker run -d --name event-app -p 5000:5000 event-registration:1.0
   docker ps
   ```
2. Run the tests (in this folder): `.\mvnw.cmd -q compile exec:java`
   (use `$env:APP_URL="http://localhost:<port>"` if you mapped a different port)
3. Check that the container received the requests: `docker logs event-app`
4. Clean up: `docker stop event-app; docker rm event-app`

## Verified Output (`evidence/12_test_results.log`)
```
Application under test: http://localhost:5000
[PASS] TC1 Registration page loads                title=Event Registration
[PASS] TC2 Form heading is displayed              h2=Event Registration Form
[PASS] TC3 All form fields are present            name, email, phone, event
[PASS] TC4 Valid submission shows success         message=Registration Successful!
[PASS] TC5 Success page shows submitted data      name=Ravi Kumar, event=DevOps Workshop
[PASS] TC6 Invalid email shows validation error   error=Enter a valid email address.
[PASS] TC7 Empty form shows 4 validation errors   errors shown=4

Tests run: 7, Passed: 7, Failed: 0
BUILD SUCCESS - all Selenium tests passed

$ docker logs event-app
"GET /register HTTP/1.1" 200 -
"POST /register HTTP/1.1" 200 -
"POST /register HTTP/1.1" 400 -
```
Screenshots taken by Selenium: `evidence/12_valid_submission_success.png` and `evidence/12_empty_form_validation.png`.

## Result
Selenium test cases for page loading and form submission were written for the containerised Flask application and executed against the running container. All 7 tests passed.

## Viva Questions
1. **Why test the application inside the container?** It checks the exact build that will be deployed, not just the source code.
2. **What is `WebDriverWait`?** An explicit wait that pauses until a condition (e.g. an element is visible) is true or a timeout expires.
3. **How do you select a dropdown option?** `new Select(element).selectByVisibleText("DevOps Workshop")`.
4. **What is a negative test case?** A test that gives invalid input (e.g. a bad email) to check that the application rejects it.
5. **How could these tests run in CI?** In a Jenkins stage after `docker run`, with Chrome in headless mode (`HEADLESS=true`).

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-12-Container-Selenium-Tests`
