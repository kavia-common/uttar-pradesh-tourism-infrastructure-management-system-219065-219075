#!/usr/bin/env bash
set -euo pipefail
# Install OpenJDK 17 and Maven non-interactively if missing
if ! command -v java >/dev/null 2>&1 || ! java -version 2>&1 | grep -q '"17' ; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk maven >/dev/null
fi
# Persist JAVA_HOME and PATH via /etc/profile.d/upstc_java.sh
sudo bash -c 'cat >/etc/profile.d/upstc_java.sh <<"EOF"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
if [[ ":$PATH:" != *":$JAVA_HOME/bin:"* ]]; then
  export PATH="$JAVA_HOME/bin:$PATH"
fi
EOF'
sudo chmod 644 /etc/profile.d/upstc_java.sh
# Load and validate
. /etc/profile.d/upstc_java.sh
command -v java >/dev/null 2>&1 || { echo "java missing" >&2; exit 21; }
command -v javac >/dev/null 2>&1 || { echo "javac missing" >&2; exit 22; }
command -v mvn >/dev/null 2>&1 || { echo "mvn missing" >&2; exit 23; }
java -version 2>&1 | head -n1
