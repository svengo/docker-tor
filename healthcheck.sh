#!/usr/bin/env sh

set -e

# Load default configuration
. /config.sh

# Check health by testing ORPort
su-exec tor echo quit | curl -sS "telnet://localhost:${ORPORT}" || exit 1
