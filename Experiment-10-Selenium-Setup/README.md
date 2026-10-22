# Experiment 10 – Installing and Exploring Selenium for Automated Testing

**Status:** ✅ Executed and verified. Java + Selenium 4.48.0 launched Chrome (headless Chromium 141), opened a page and read its title (`evidence/10_execution.log`). Re-run on your laptop to show a visible Chrome window and https://www.selenium.dev/.

## AIM
To install and configure Selenium WebDriver with Java, launch the Chrome browser, open a web page, and read its title.

## Software Requirements
| Software | Version | Notes |
|---|---|---|
| JDK | 17 or newer | `java -version` |
| Maven | 3.9+ | downloads Selenium from Maven Central |
| Selenium Java | 4.48.0 | `selenium-java` dependency in `pom.xml` |
| Google Chrome | latest | installed normally on Windows |
| ChromeDriver | automatic | **Selenium Manager** (built into Selenium 4.6+) downloads the matching driver; no manual `System.setProperty("webdriver.chrome.driver", …)` is needed |

## Installation / Setup Procedure
1. Install a JDK and check it: `java -version`.
2. Maven itself is optional: the project includes the Maven Wrapper (`mvnw.cmd`), which downloads Maven 3.9.9 on first use.
3. Install Google Chrome.
4. Create a Maven project and add the `selenium-java` dependency (see `pom.xml`).
5. Write `SeleniumSetup.java`: create a `ChromeDriver`, call `driver.get(url)`, `driver.getTitle()` and `driver.quit()`.
6. Run it with Maven.

## Source
`src/main/java/in/smec/devops/SeleniumSetup.java` (core lines):
```java
WebDriver driver = new ChromeDriver(options);
driver.get("https://www.selenium.dev/");
System.out.println("Page title   : " + driver.getTitle());
driver.quit();
```

## Execution (PowerShell, in this folder)
```powershell
.\mvnw.cmd -q compile exec:java                                   # opens https://www.selenium.dev/
.\mvnw.cmd -q compile exec:java "-Dexec.args=https://www.google.com"
$env:HEADLESS="true"; .\mvnw.cmd -q compile exec:java             # without a visible window
```
In Eclipse: **File → Import → Existing Maven Projects**, then right-click `SeleniumSetup.java` → **Run As → Java Application**.

## Verified Output (`evidence/10_execution.log`)
```
Chrome launched successfully using Selenium WebDriver
Opened URL   : http://localhost:5000/register
Page title   : Event Registration
RESULT: PASS - page opened and title read successfully
Browser closed
Exit code: 0
```
The browser on the preparation machine had no public internet access, so the run opened the locally running Experiment 1 page. On your laptop the default URL is `https://www.selenium.dev/`, and the expected title is *"Selenium"*.

## Result
Selenium WebDriver was configured with Java and Chrome. A browser was launched, a web page was opened, and its title was read and verified.

## Viva Questions
1. **What is Selenium?** An open-source tool suite for automating web browsers, mainly used for testing web applications.
2. **What is WebDriver?** The Selenium API that controls a real browser through browser-specific drivers (e.g. ChromeDriver).
3. **What is Selenium Manager?** A tool built into Selenium 4.6+ that finds or downloads the correct browser driver automatically.
4. **`driver.close()` vs `driver.quit()`?** `close()` closes the current window; `quit()` closes all windows and ends the session.
5. **Name some Selenium locators.** `By.id`, `By.name`, `By.className`, `By.tagName`, `By.cssSelector`, `By.xpath`, `By.linkText`.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-10-Selenium-Setup`
