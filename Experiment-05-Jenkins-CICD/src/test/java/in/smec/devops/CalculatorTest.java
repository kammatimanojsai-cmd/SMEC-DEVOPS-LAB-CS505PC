package in.smec.devops;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class CalculatorTest {

    private final Calculator calc = new Calculator();

    @Test
    void addsTwoNumbers() {
        assertEquals(15, calc.add(10, 5));
    }

    @Test
    void subtractsTwoNumbers() {
        assertEquals(5, calc.subtract(10, 5));
    }

    @Test
    void multipliesTwoNumbers() {
        assertEquals(50, calc.multiply(10, 5));
    }

    @Test
    void dividesTwoNumbers() {
        assertEquals(2.0, calc.divide(10, 5));
    }

    @Test
    void divisionByZeroThrows() {
        assertThrows(IllegalArgumentException.class, () -> calc.divide(1, 0));
    }
}
