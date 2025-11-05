#!/usr/bin/env bash
set -euo pipefail
# Build script: runs mvn --batch-mode test package once, detects produced jar and validates Spring Boot layout
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-219065-219075/upstc_backend"
cd "$WORKSPACE"
# ensure profile loader
[ -f /etc/profile.d/upstc_java.sh ] && . /etc/profile.d/upstc_java.sh || true
# ensure java 17 and mvn exist; install non-interactively if missing
need_install=0
if command -v java >/dev/null 2>&1; then
  ver=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}') || true
else
  ver=""
fi
# function to install openjdk-17 and maven if needed
install_deps(){
  sudo apt-get update -q && sudo apt-get install -y -q openjdk-17-jdk maven >/dev/null
  # persist JAVA_HOME
  if command -v java >/dev/null 2>&1; then
    JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(command -v java))))
    sudo tee /etc/profile.d/upstc_java.sh >/dev/null <<EOF
export JAVA_HOME=$JAVA_HOME_PATH
case ":$PATH:" in
  *":$JAVA_HOME/bin:"*) ;; 
  *) export PATH="$JAVA_HOME/bin:$PATH" ;;
esac
EOF
    . /etc/profile.d/upstc_java.sh || true
  fi
}
# validate version major 17 if present, else install
if [ -z "${ver:-}" ] || ! printf "%s" "$ver" | grep -qE '^17(\.|$)'; then
  install_deps || { echo "Failed to install JDK/Maven" >&2; exit 25; }
fi
# verify required commands
for cmd in java javac mvn readlink; do
  command -v $cmd >/dev/null 2>&1 || { echo "$cmd not found" >&2; [ "$cmd" = mvn ] && exit 20 || exit 25; }
done
# run mvn once: tests + package
mvn --batch-mode test package || { echo "mvn test package failed" >&2; exit 21; }
# determine finalName and build dir via exec:exec echo
FINAL_NAME=$(mvn -q -Dexec.executable=echo -Dexec.args='${project.build.finalName}' --non-recursive exec:exec 2>/dev/null || true)
BUILD_DIR=$(mvn -q -Dexec.executable=echo -Dexec.args='${project.build.directory}' --non-recursive exec:exec 2>/dev/null || true)
CANDIDATE=""
if [ -n "$FINAL_NAME" ] && [ -n "$BUILD_DIR" ]; then
  CANDIDATE="$BUILD_DIR/$FINAL_NAME.jar"
  # if name lacks .jar, append
  case "$CANDIDATE" in
    *.jar) ;;
    *) CANDIDATE="$CANDIDATE.jar" ;;
  esac
  [ ! -f "$CANDIDATE" ] && CANDIDATE=""
fi
if [ -z "$CANDIDATE" ]; then
  # fallback: prefer spring-boot fat jar, then any jar in target
  CANDIDATE=$(ls -1 target/*spring-boot*.jar 2>/dev/null | head -n1 || true)
  [ -z "$CANDIDATE" ] && CANDIDATE=$(ls -1 target/*.jar 2>/dev/null | head -n1 || true)
fi
if [ -z "$CANDIDATE" ] || [ ! -f "$CANDIDATE" ]; then
  echo "No jar produced or detected ($CANDIDATE)" >&2
  ls -la target || true
  exit 22
fi
# verify Spring Boot layout using jar or unzip
if command -v jar >/dev/null 2>&1; then
  if jar tf "$CANDIDATE" | grep -q -E 'BOOT-INF|org/springframework/boot/loader'; then
    readlink -f "$CANDIDATE" > .last_build_jar
  else
    echo "Found jar but not Spring-Boot executable: $CANDIDATE" >&2; exit 23
  fi
else
  if command -v unzip >/dev/null 2>&1 && unzip -l "$CANDIDATE" 2>/dev/null | grep -q -E 'BOOT-INF|org/springframework/boot/loader'; then
    readlink -f "$CANDIDATE" > .last_build_jar
  else
    echo "Found jar but not Spring-Boot executable and no jar/unzip tool available: $CANDIDATE" >&2; exit 24
  fi
fi
# success output minimal
echo "JAR_DETECTED=$(cat .last_build_jar)"
