# Experiment 11 – JavaScript Program Tested with Selenium

**Status:** ✅ Executed and verified. **5 of 5 Selenium tests passed**; the counter went from 0 to 1 after one click (`evidence/11_test_results.log` and screenshots).

## AIM
To create a simple JavaScript program (an increment counter) and test its behaviour automatically with Selenium WebDriver in Java.

## Software Requirements
JDK 17+, Maven 3.9+, Google Chrome, Selenium Java 4.48.0 (from `pom.xml`).

## Files
```
Experiment-11-JavaScript-Selenium/
├── app/index.html       # page with counter (id="counter") and buttons
├── app/counter.js       # JavaScript: increments / resets the counter
├── pom.xml
└── src/main/java/in/smec/devops/CounterAppTest.java   # Selenium tests
```

### JavaScript (`app/counter.js`)
```javascript
let count = 0;
document.getElementById("incrementButton").addEventListener("click", function () {
  count = count + 1;
  document.getElementById("counter").textContent = count;
});
```

## Test Cases
| # | Test | Expected |
|---|---|---|
| 1 | Page title | `Increment Counter App` |
| 2 | Initial value | `0` |
| 3 | Click **Increment** once | `1` |
| 4 | Click twice more | `3` |
| 5 | Click **Reset** | `0` |

## Procedure
1. Open `app/index.html` in Chrome and click the button manually to check it works.
2. Write `CounterAppTest.java`: open the page with `driver.get(file:///…/app/index.html)`, locate elements by id, click, and compare the text with the expected value.
3. Run the tests and save the results.

## Execution (PowerShell, in this folder)
```powershell
.\mvnw.cmd -q compile exec:java
```
Screenshots are written to `target\screenshots\` (set `$env:SCREENSHOT_DIR="evidence"` to save them into `evidence\`).

## Verified Output (`evidence/11_test_results.log`)
```
[PASS] Page title is 'Increment Counter App'   expected=Increment Counter App actual=Increment Counter App
[PASS] Initial counter value is 0              expected=0 actual=0
[PASS] Counter is 1 after one click            expected=1 actual=1
[PASS] Counter is 3 after three clicks         expected=3 actual=3
[PASS] Counter resets to 0                     expected=0 actual=0

Tests run: 5, Passed: 5, Failed: 0
BUILD SUCCESS - all Selenium tests passed
```
Screenshots taken by Selenium during the run: `evidence/11_counter_initial_0.png` and `evidence/11_counter_after_click_1.png`.

## Result
The JavaScript increment-counter program was created and tested with Selenium. Clicking the button increased the value from 0 to 1, and all 5 automated tests passed.

## Viva Questions
1. **How does Selenium click a button?** It finds the element (e.g. `By.id("incrementButton")`) and calls `.click()`.
2. **How do you read text from an element?** `driver.findElement(By.id("counter")).getText()`.
3. **Why is automated UI testing useful?** It repeats the same checks quickly and reliably after every change (regression testing).
4. **What is an assertion?** A check that compares the actual result with the expected result and fails the test if they differ.
5. **What is a DOM?** The Document Object Model: the tree of HTML elements that JavaScript and Selenium interact with.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-11-JavaScript-Selenium`
