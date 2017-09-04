#!/bin/sh
set -e

if [ "$1" == 'tor' ]; then
  chown -R tor:tor /data
  if [ -s /data/torrc ]; then
    echo "WARNING: Using existent /data/torrc!"
  else
    confd -onetime
  fi
  exec su-exec tor "$@"
fi

exec "$@"
