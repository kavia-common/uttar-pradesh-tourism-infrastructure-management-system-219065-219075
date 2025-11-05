#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-219065-219075/upstc_backend"
cd "$WORKSPACE"
[ -f /etc/profile.d/upstc_java.sh ] && . /etc/profile.d/upstc_java.sh || true
[ -f pom.xml ] && exit 0
mkdir -p src/main/java/com/upstc src/main/resources src/test/java/com/upstc
cat > pom.xml <<'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.upstc</groupId>
  <artifactId>upstc-backend</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <properties>
    <java.version>17</java.version>
    <spring.boot.version>3.3.0</spring.boot.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-dependencies</artifactId>
        <version>${spring.boot.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.11.0</version>
        <configuration>
          <source>${java.version}</source>
          <target>${java.version}</target>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
POM
cat > src/main/java/com/upstc/Application.java <<'JAVA'
package com.upstc;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
  public static void main(String[] args) { SpringApplication.run(Application.class, args); }
}
JAVA
mkdir -p src/main/resources
STORAGE_DIR="$WORKSPACE/upstc_storage"
cat > src/main/resources/application.properties <<PROP
# H2 in-memory
spring.datasource.url=jdbc:h2:mem:devdb;DB_CLOSE_DELAY=-1
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
# Expose actuator health
management.endpoints.web.exposure.include=health
management.endpoint.health.show-details=never
# File storage path - absolute workspace-relative
app.storage.path=${STORAGE_DIR}
# Bind to all interfaces for container development
server.address=0.0.0.0
server.port=8080
# Dev-level logging
logging.level.root=DEBUG
# quieter banner
spring.main.banner-mode=off
PROP
mkdir -p "$STORAGE_DIR"
RUNTIME_UID=${RUNTIME_UID:-}
RUNTIME_GID=${RUNTIME_GID:-}
if [ -n "$RUNTIME_UID" ]; then
  sudo chown -R ${RUNTIME_UID}${RUNTIME_GID:+:${RUNTIME_GID}} "$STORAGE_DIR" || true
else
  CUR_UID=$(id -u || echo 0)
  CUR_GID=$(id -g || echo 0)
  sudo chown -R ${CUR_UID}:${CUR_GID} "$STORAGE_DIR" || true
fi
chmod -R 0775 "$STORAGE_DIR" || true
cat > src/test/java/com/upstc/SanityTest.java <<'JAVA'
package com.upstc;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;
class SanityTest { @Test void basic() { assertTrue(true); } }
JAVA
