package com.upstc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * PUBLIC_INTERFACE
 * Entry point for the UPSTC Spring Boot application.
 * Ensures the application boots on server.port configured in application.properties (default 3001).
 */
@SpringBootApplication
public class Application {

  /**
   * PUBLIC_INTERFACE
   * Bootstraps the Spring application.
   * @param args command line arguments
   */
  public static void main(String[] args) {
    SpringApplication.run(Application.class, args);
  }
}
