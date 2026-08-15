#!/usr/bin/env bash
set -euo pipefail

: "${PORT:=10000}"
export SERVER_PORT="${PORT}"
export ENABLE_AUTOPAUSE="false"
export ENABLE_AUTOSTOP="false"

cp -f /opt/server-icon.png /data/server-icon.png

if [ "${PREPATCH_PAPER:-false}" = "true" ]; then
  mkdir -p /data/cache
  cp -f /opt/paper-prepatch/paper-1.12.2-1620.jar /data/paper-1.12.2-1620.jar
  cp -f /opt/paper-prepatch/cache/patched_1.12.2.jar /data/cache/patched_1.12.2.jar
  export PAPER_CUSTOM_JAR=/data/paper-1.12.2-1620.jar
fi

exec /image/scripts/start "$@"
