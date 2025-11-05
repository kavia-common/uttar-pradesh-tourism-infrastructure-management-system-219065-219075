package com.upstc.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

/**
 * PUBLIC_INTERFACE
 * CorsConfig registers a global CORS filter for all endpoints.
 * It allows configured frontend origins to make cross-origin requests to this backend.
 *
 * Configuration:
 * - FRONTEND_URLS environment variable (comma-separated) can override allowed origins.
 * - Defaults to common local dev ports for Angular/React if env var is not provided.
 */
@Configuration
public class CorsConfig {

    @Value("${frontend.urls:}")
    private String frontendUrlsProp;

    // PUBLIC_INTERFACE
    /**
     * Registers the global CORS filter for the application.
     * The allowed origins are taken from the 'frontend.urls' property which can be set using the
     * FRONTEND_URLS environment variable. If not set, defaults are used.
     *
     * @return CorsFilter configured for all paths.
     */
    @Bean
    public CorsFilter corsFilter() {
        List<String> defaults = Arrays.asList(
                "http://localhost:3000",
                "http://127.0.0.1:3000",
                "http://localhost:4200",
                "http://127.0.0.1:4200"
        );

        List<String> allowedOrigins;
        if (frontendUrlsProp != null && !frontendUrlsProp.isBlank()) {
            allowedOrigins = Arrays.stream(frontendUrlsProp.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isBlank())
                    .toList();
        } else {
            allowedOrigins = defaults;
        }

        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.setAllowedOrigins(allowedOrigins);
        config.setAllowedHeaders(Arrays.asList("Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        // Apply to all paths
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
