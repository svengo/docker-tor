#!/usr/bin/env sh

set -e

# default configuration
. /config.sh

# check health
echo quit | curl -sS "telnet://localhost:${ORPORT}" || exit 1
