#!/usr/bin/env sh

set -e

# Load default configuration
. /config.sh

# Generate /etc/tor/torrc-defaults from template
/usr/bin/envsubst < /etc/tor/torrc-defaults-source > /etc/tor/torrc-defaults

# Fix permissions
chown -R tor:tor /data
chmod 0700 /data

# If /data/torrc doesn't exist, use sample
if [ ! -s /data/torrc ]; then
  cp /etc/tor/torrc.sample /data/torrc
fi
  
if [ "$1" = "tor" ]; then
  # Run tor as tor user
  exec /sbin/su-exec tor "$@"
fi

exec "$@"
