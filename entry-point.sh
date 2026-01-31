#!/usr/bin/env sh

set -e

# default configuration
. /config.sh

# generate /etc/tor/torrc-defaults
envsubst < /etc/tor/torrc-defaults-source > /etc/tor/torrc-defaults

# if /data/torrc doesn't exist, use sample
if [ ! -s /data/torrc ]; then
  cp /etc/tor/torrc.sample /data/torrc
fi
  
exec "$@"
