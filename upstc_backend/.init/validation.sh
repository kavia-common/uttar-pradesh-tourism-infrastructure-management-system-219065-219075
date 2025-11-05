#!/usr/bin/env bash
set -euo pipefail

# Validation: build if needed, start app, probe actuator/health, stop cleanly
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-219065-219075/upstc_backend"
cd "$WORKSPACE"
[ -f /etc/profile.d/upstc_java.sh ] && . /etc/profile.d/upstc_java.sh || true

LOG=/tmp/upstc_app.log
rm -f "$LOG"

# Determine jar path from last build or find in target
JAR_PATH=""
if [ -f .last_build_jar ]; then
  JAR_PATH=$(readlink -f "$(cat .last_build_jar)" || true)
fi

# If jar missing, attempt a non-interactive build
if [ -z "$JAR_PATH" ] || [ ! -f "$JAR_PATH" ]; then
  if command -v mvn >/dev/null 2>&1; then
    mvn --batch-mode -DskipTests package || { echo "build failed" >&2; exit 40; }
    # pick likely jar
    JAR_PATH=$(readlink -f target/*.jar 2>/dev/null | grep -m1 -E 'spring-boot|upstc-backend|\.jar' || true)
  else
    echo "maven not found on PATH" >&2
    exit 39
  fi
fi

if [ -z "$JAR_PATH" ] || [ ! -f "$JAR_PATH" ]; then
  echo "No runnable jar available" >&2
  ls -la target || true
  exit 41
fi

# record last build jar
echo "$JAR_PATH" > .last_build_jar || true

# Start the app using java -jar (preferred). Use exec semantics when run interactively via script:
# We'll start in background to capture PID but set trap to forward signals and stop cleanly.
if ! command -v java >/dev/null 2>&1; then
  echo "java not found on PATH" >&2
  exit 38
fi

# Start app and capture logs
# Use stdout/stderr redirected to LOG. Do not use nohup so signals propagate.
java -jar "$JAR_PATH" >"$LOG" 2>&1 &
APP_PID=$!

# Ensure we will stop child on exit/interrupt
trap 'kill -TERM "$APP_PID" 2>/dev/null || true; wait "$APP_PID" || true' EXIT INT TERM

# readiness probe
URL="http://127.0.0.1:8080/actuator/health"
MAX=60; i=0; delay=1
while [ $i -lt $MAX ]; do
  if command -v curl >/dev/null 2>&1; then
    out=$(curl -sS --max-time 5 "$URL" 2>/dev/null || true)
    if [ -n "$out" ] && echo "$out" | grep -q '"status".*"UP"'; then
      echo "APP_READY"
      echo "$out"
      break
    fi
  else
    echo "curl not available to probe health" >&2
    break
  fi
  sleep $delay
  i=$((i+1))
  delay=$((delay<8?delay*2:8))
done

if [ $i -ge $MAX ]; then
  echo "App failed to become ready; tailing log:" >&2
  tail -n 200 "$LOG" >&2 || true
  kill -TERM "$APP_PID" 2>/dev/null || true
  exit 42
fi

# Output evidence: health JSON and tail of log
curl -sS "$URL" || true
echo "--- APP LOG (tail 80) ---"
tail -n 80 "$LOG" || true

# Clean stop
kill -TERM "$APP_PID" 2>/dev/null || true
sleep 2
if ps -p "$APP_PID" >/dev/null 2>&1; then
  kill -9 "$APP_PID" 2>/dev/null || true
fi
trap - EXIT INT TERM

exit 0
