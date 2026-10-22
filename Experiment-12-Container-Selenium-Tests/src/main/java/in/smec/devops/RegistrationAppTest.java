package in.smec.devops;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

/**
 * Experiment 12 - Selenium test cases for the containerised Flask registration app (Experiment 1).
 *
 * Start the container first:
 *   docker run -d --name event-app -p 5000:5000 event-registration:1.0
 * Then run:  mvn -q compile exec:java          (APP_URL defaults to http://localhost:5000)
 */
public class RegistrationAppTest {

    private static final String BASE_URL = System.getenv().getOrDefault("APP_URL", "http://localhost:5000");
    private static int passed = 0;
    private static int failed = 0;

    static WebDriver createDriver() {
        ChromeOptions options = new ChromeOptions();
        String binary = System.getenv("CHROME_BINARY");
        if (binary != null && !binary.isBlank()) {
            options.setBinary(binary);
        }
        if ("true".equalsIgnoreCase(System.getenv("HEADLESS"))) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--window-size=1000,800", "--no-sandbox");
        return new ChromeDriver(options);
    }

    static void check(String testName, boolean condition, String detail) {
        if (condition) {
            passed++;
            System.out.printf("[PASS] %-48s %s%n", testName, detail);
        } else {
            failed++;
            System.out.printf("[FAIL] %-48s %s%n", testName, detail);
        }
    }

    static void screenshot(WebDriver driver, String name) throws Exception {
        Path dir = Paths.get(System.getenv().getOrDefault("SCREENSHOT_DIR", "target/screenshots"));
        Files.createDirectories(dir);
        Path src = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE).toPath();
        Files.copy(src, dir.resolve(name), StandardCopyOption.REPLACE_EXISTING);
    }

    static void fillForm(WebDriver driver, String name, String email, String phone, String event) {
        driver.findElement(By.id("name")).sendKeys(name);
        driver.findElement(By.id("email")).sendKeys(email);
        driver.findElement(By.id("phone")).sendKeys(phone);
        if (!event.isEmpty()) {
            new Select(driver.findElement(By.id("event"))).selectByVisibleText(event);
        }
        driver.findElement(By.id("submitBtn")).click();
    }

    public static void main(String[] args) throws Exception {
        WebDriver driver = createDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        try {
            System.out.println("Application under test: " + BASE_URL);

            // Test 1: page loading
            driver.get(BASE_URL + "/register");
            check("TC1 Registration page loads", "Event Registration".equals(driver.getTitle()),
                    "title=" + driver.getTitle());
            String heading = driver.findElement(By.tagName("h2")).getText();
            check("TC2 Form heading is displayed", heading.equals("Event Registration Form"), "h2=" + heading);
            boolean allFields = !driver.findElements(By.id("name")).isEmpty()
                    && !driver.findElements(By.id("email")).isEmpty()
                    && !driver.findElements(By.id("phone")).isEmpty()
                    && !driver.findElements(By.id("event")).isEmpty();
            check("TC3 All form fields are present", allFields, "name, email, phone, event");

            // Test 2: valid form submission
            fillForm(driver, "Ravi Kumar", "ravi@example.com", "9876543210", "DevOps Workshop");
            WebElement success = wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("successMessage")));
            check("TC4 Valid submission shows success", success.getText().equals("Registration Successful!"),
                    "message=" + success.getText());
            String regName = driver.findElement(By.id("regName")).getText();
            String regEvent = driver.findElement(By.id("regEvent")).getText();
            check("TC5 Success page shows submitted data",
                    regName.equals("Ravi Kumar") && regEvent.equals("DevOps Workshop"),
                    "name=" + regName + ", event=" + regEvent);
            screenshot(driver, "12_valid_submission_success.png");

            // Test 3: invalid email is rejected
            driver.get(BASE_URL + "/register");
            fillForm(driver, "Sita Devi", "sita-at-example", "9123456780", "Cloud Bootcamp");
            List<WebElement> emailError = driver.findElements(By.id("error-email"));
            check("TC6 Invalid email shows validation error",
                    !emailError.isEmpty() && emailError.get(0).getText().contains("valid email"),
                    emailError.isEmpty() ? "no error shown" : "error=" + emailError.get(0).getText());

            // Test 4: empty form is rejected with an error on every field
            driver.get(BASE_URL + "/register");
            driver.findElement(By.id("submitBtn")).click();
            int errors = driver.findElements(By.className("error")).size();
            check("TC7 Empty form shows 4 validation errors", errors == 4, "errors shown=" + errors);
            screenshot(driver, "12_empty_form_validation.png");
        } finally {
            driver.quit();
        }
        System.out.printf("%nTests run: %d, Passed: %d, Failed: %d%n", passed + failed, passed, failed);
        System.out.println(failed == 0 ? "BUILD SUCCESS - all Selenium tests passed" : "BUILD FAILURE");
        System.exit(failed == 0 ? 0 : 1);
    }
}
