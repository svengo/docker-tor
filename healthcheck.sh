#!/bin/sh
set -e

# default configuration
source /config.sh

# check health
su-exec tor echo quit | curl -sS telnet://localhost:${ORPORT} || exit 1
