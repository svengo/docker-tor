#!/bin/sh
set -e

if [ "$1" == 'tor' ]; then
  chown -R tor:tor /data
  if [ -s /data/torrc ]; then
    echo "Using existent /data/torrc!" 1>&2
  else
    confd -onetime -backend env
  fi
  exec su-exec tor "$@"
fi

exec "$@"
