package in.smec.devops;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

/**
 * Experiment 10 - Install and explore Selenium WebDriver.
 * Launches Chrome, opens a web page and prints its title.
 *
 * Usage: mvn -q compile exec:java                      (opens https://www.selenium.dev)
 *        mvn -q compile exec:java -Dexec.args="https://example.com"
 * Optional environment variables: HEADLESS=true, CHROME_BINARY=<path to chrome>
 */
public class SeleniumSetup {

    static WebDriver createDriver() {
        ChromeOptions options = new ChromeOptions();
        String binary = System.getenv("CHROME_BINARY");
        if (binary != null && !binary.isBlank()) {
            options.setBinary(binary);
        }
        if ("true".equalsIgnoreCase(System.getenv("HEADLESS"))) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--window-size=1200,800", "--no-sandbox");
        // Selenium 4.6+ downloads/locates the matching ChromeDriver automatically (Selenium Manager)
        return new ChromeDriver(options);
    }

    static void screenshot(WebDriver driver, String name) throws Exception {
        Path dir = Paths.get(System.getenv().getOrDefault("SCREENSHOT_DIR", "target/screenshots"));
        Files.createDirectories(dir);
        Path src = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE).toPath();
        Files.copy(src, dir.resolve(name), StandardCopyOption.REPLACE_EXISTING);
        System.out.println("Screenshot   : " + dir.resolve(name));
    }

    public static void main(String[] args) throws Exception {
        String url = args.length > 0 ? args[0] : "https://www.selenium.dev/";
        WebDriver driver = createDriver();
        try {
            System.out.println("Chrome launched successfully using Selenium WebDriver");
            driver.get(url);
            String title = driver.getTitle();
            System.out.println("Opened URL   : " + driver.getCurrentUrl());
            System.out.println("Page title   : " + title);
            screenshot(driver, "10_page_opened_by_selenium.png");
            if (title == null || title.isBlank()) {
                System.out.println("RESULT: FAIL - page title is empty");
                System.exit(1);
            }
            System.out.println("RESULT: PASS - page opened and title read successfully");
        } finally {
            driver.quit();
            System.out.println("Browser closed");
        }
    }
}
