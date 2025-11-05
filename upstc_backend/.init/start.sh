#!/usr/bin/env bash
set -euo pipefail

# Workspace must come from container info
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-219065-219075/upstc_backend"
cd "$WORKSPACE"

# Source global JAVA profile if present (non-fatal)
[ -f /etc/profile.d/upstc_java.sh ] && . /etc/profile.d/upstc_java.sh || true

STORAGE_DIR="$WORKSPACE/upstc_storage"
mkdir -p "$STORAGE_DIR" && chmod 0775 "$STORAGE_DIR"

# Ownership: prefer RUNTIME_UID:RUNTIME_GID when provided; else current effective uid:gid
RUNTIME_UID=${RUNTIME_UID:-}
RUNTIME_GID=${RUNTIME_GID:-}
if [ -n "${RUNTIME_UID}" ]; then
  sudo chown -R ${RUNTIME_UID}${RUNTIME_GID:+:${RUNTIME_GID}} "$STORAGE_DIR" || true
else
  sudo chown -R "$(id -u):$(id -g)" "$STORAGE_DIR" || true
fi

# Prefer packaged jar recorded in .last_build_jar (absolute path stored there)
JAR=""
if [ -f .last_build_jar ]; then
  # read and resolve to absolute path safely
  RAW=$(cat .last_build_jar || true)
  if [ -n "${RAW}" ]; then
    JAR=$(readlink -f "${RAW}" 2>/dev/null || true)
  fi
fi

if [ -n "$JAR" ] && [ -f "$JAR" ]; then
  # Replace shell with java process so PID 1 semantics are preserved in containers
  exec java -jar "$JAR"
else
  # Fall back to Maven run in foreground; forward SIGTERM/SIGINT to child
  MAVN_PID=""
  _term() {
    if [ -n "${MAVN_PID}" ]; then
      kill -TERM "${MAVN_PID}" 2>/dev/null || true
    fi
  }
  trap _term TERM INT
  mvn --batch-mode spring-boot:run &
  MAVN_PID=$!
  wait "$MAVN_PID"
  exit $?
fi
