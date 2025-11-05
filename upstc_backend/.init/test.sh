#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-219065-219075/upstc_backend"
cd "$WORKSPACE"
[ -f /etc/profile.d/upstc_java.sh ] && . /etc/profile.d/upstc_java.sh || true
command -v mvn >/dev/null 2>&1 || { echo "mvn not found" >&2; exit 30; }
# Run tests only (useful for explicit verification). deps-001 already runs tests by default.
mvn --batch-mode test || { echo "mvn test failed" >&2; exit 31; }
