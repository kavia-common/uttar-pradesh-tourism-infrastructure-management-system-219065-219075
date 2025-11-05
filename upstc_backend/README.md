# UPSTC Backend (Spring Boot)

This service provides APIs and health endpoints for the Uttar Pradesh Tourism Infrastructure Management System.

## Quick start

- Java: 17
- Build: Maven
- Default port: 3001
- Bind address: 0.0.0.0

Run (foreground):
- mvn spring-boot:run
- or: java -jar target/upstc-backend-0.0.1-SNAPSHOT.jar

Health and readiness:
- GET / -> simple text "UPSTC backend is running"
- GET /ready -> lightweight readiness probe
- GET /actuator/health -> overall health (JSON)
- GET /actuator/health/liveness -> liveness probe
- GET /actuator/health/readiness -> readiness probe

## CORS

Global CORS is enabled to allow the frontend during development.

- Environment variable FRONTEND_URLS (comma-separated) defines allowed origins.
- Default allowed origins (if FRONTEND_URLS not set):
  - http://localhost:3000, http://127.0.0.1:3000
  - http://localhost:4200, http://127.0.0.1:4200

Example:
- FRONTEND_URLS="https://upstc-frontend.example.com,https://admin.upstc.example.com"

## Configuration

application.properties sets:
- server.address=0.0.0.0
- server.port=3001
- management.endpoints.web.base-path=/actuator
- management.endpoints.web.exposure.include=health,info,readiness,liveness
- management.endpoint.health.probes.enabled=true
- management.server.port=3001 (same port as app)
- spring.main.web-application-type=servlet

Override via environment variables if needed:
- SERVER_PORT (or PORT)
- MANAGEMENT_SERVER_PORT
- SPRING_PROFILES_ACTIVE
- FRONTEND_URLS (maps to 'frontend.urls' property)

Note: By default database settings are blank to allow the app to boot without a DB.

## Build

- mvn -q -DskipTests package

## Troubleshooting

- If port 3001 appears busy, verify no other process is binding to it.
- Confirm environment variables do not override the port undesirably:
  - SERVER_PORT, PORT, MANAGEMENT_SERVER_PORT, SERVER_ADDRESS
- Check logs for:
  - "Tomcat initialized with port 3001 (http)"
  - "Tomcat started on port 3001 (http)"
- Health endpoints:
  - curl -sSf http://localhost:3001/actuator/health
  - curl -sSf http://localhost:3001/
- If running in a container/orchestrator, ensure service/ingress exposes port 3001.
