#!/bin/sh
set -e

if [ "$1" = "tor" ]; then
  # generate /etc/tor/torrc-defaults
  /usr/bin/envsubst < /etc/tor/torrc-defaults-source > /etc/tor/torrc-defaults
  
  # fix permissions
  chown -R tor:tor /data
  chmod 0700 /data
  
  # if /data/torrc doesn't exist, use sample
  if [ ! -s /data/torrc ]; then
    cp /etc/tor/torrc.sample /data/torrc
  fi
  
  # run tor
  exec /usr/bin/su-exec tor "$@" -f "/data/torrc"
fi

exec "$@"
