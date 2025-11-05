package com.upstc.health;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * PUBLIC_INTERFACE
 * RootController provides simple endpoints to verify server readiness without requiring a database.
 * - GET / returns a simple message.
 * - GET /ready returns HTTP 200 as a lightweight readiness probe.
 */
@RestController
public class RootController {

    // PUBLIC_INTERFACE
    /**
     * Returns a simple greeting to confirm the service is up.
     * @return ResponseEntity with a message.
     */
    @GetMapping(path = "/")
    public ResponseEntity<String> root() {
        return ResponseEntity.ok("UPSTC backend is running");
    }

    // PUBLIC_INTERFACE
    /**
     * Readiness endpoint that does not depend on any external services.
     * @return ResponseEntity with status OK.
     */
    @GetMapping(path = "/ready")
    public ResponseEntity<String> ready() {
        return ResponseEntity.ok("ready");
    }
}
