package in.smec.devops;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

/**
 * Experiment 11 - Selenium tests for the JavaScript increment-counter application (app/index.html).
 * Run from this folder: mvn -q compile exec:java
 */
public class CounterAppTest {

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
        options.addArguments("--window-size=1000,700", "--no-sandbox");
        return new ChromeDriver(options);
    }

    static void check(String testName, String expected, String actual) {
        if (expected.equals(actual)) {
            passed++;
            System.out.printf("[PASS] %-45s expected=%s actual=%s%n", testName, expected, actual);
        } else {
            failed++;
            System.out.printf("[FAIL] %-45s expected=%s actual=%s%n", testName, expected, actual);
        }
    }

    static void screenshot(WebDriver driver, String name) throws Exception {
        Path dir = Paths.get(System.getenv().getOrDefault("SCREENSHOT_DIR", "target/screenshots"));
        Files.createDirectories(dir);
        Path src = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE).toPath();
        Files.copy(src, dir.resolve(name), StandardCopyOption.REPLACE_EXISTING);
    }

    public static void main(String[] args) throws Exception {
        String url = Paths.get("app", "index.html").toAbsolutePath().toUri().toString();
        WebDriver driver = createDriver();
        try {
            driver.get(url);
            System.out.println("Opened: " + url);
            check("Page title is 'Increment Counter App'", "Increment Counter App", driver.getTitle());

            By counter = By.id("counter");
            By increment = By.id("incrementButton");

            check("Initial counter value is 0", "0", driver.findElement(counter).getText());
            screenshot(driver, "11_counter_initial_0.png");

            driver.findElement(increment).click();
            check("Counter is 1 after one click", "1", driver.findElement(counter).getText());
            screenshot(driver, "11_counter_after_click_1.png");

            driver.findElement(increment).click();
            driver.findElement(increment).click();
            check("Counter is 3 after three clicks", "3", driver.findElement(counter).getText());

            driver.findElement(By.id("resetButton")).click();
            check("Counter resets to 0", "0", driver.findElement(counter).getText());
        } finally {
            driver.quit();
        }
        System.out.printf("%nTests run: %d, Passed: %d, Failed: %d%n", passed + failed, passed, failed);
        System.out.println(failed == 0 ? "BUILD SUCCESS - all Selenium tests passed" : "BUILD FAILURE");
        System.exit(failed == 0 ? 0 : 1);
    }
}
