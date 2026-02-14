#!/usr/bin/env sh

set -e

# default configuration
. /config.sh

# generate /etc/tor/torrc-defaults
# Filter out lines that have a directive name but no value (due to empty env vars)
envsubst < /etc/tor/torrc-defaults-source | sed -E '/^[a-zA-Z0-9_]+[[:space:]]*$/d' > /etc/tor/torrc-defaults

# if /data/torrc doesn't exist, use sample
if [ ! -s /data/torrc ]; then
  cp /etc/tor/torrc.sample /data/torrc
fi

# verify config
tor -f /data/torrc --defaults-torrc /etc/tor/torrc-defaults --verify-config

exec "$@"
