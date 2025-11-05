package com.upstc;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * PUBLIC_INTERFACE
 * Verifies that the Spring Boot application context loads successfully.
 * This helps catch misconfigurations at build/test time.
 */
@SpringBootTest
public class ApplicationContextTest {

    /**
     * PUBLIC_INTERFACE
     * A no-op test that triggers Spring Boot context initialization.
     */
    @Test
    public void contextLoads() {
        // If the application context fails to start, this test will fail.
    }
}
