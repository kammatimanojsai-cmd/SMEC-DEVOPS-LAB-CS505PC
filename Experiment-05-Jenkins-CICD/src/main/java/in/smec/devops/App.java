package in.smec.devops;

/** Entry point packaged into jenkins-cicd-demo.jar and executed in the Deploy stage. */
public class App {

    public static final String VERSION = "1.1";

    public static void main(String[] args) {
        Calculator calc = new Calculator();
        System.out.println("Jenkins CI/CD Demo application v" + VERSION);
        System.out.println("10 + 5 = " + calc.add(10, 5));
        System.out.println("10 - 5 = " + calc.subtract(10, 5));
        System.out.println("10 * 5 = " + calc.multiply(10, 5));
        System.out.println("10 / 5 = " + calc.divide(10, 5));
        System.out.println("Deployment successful");
    }
}
