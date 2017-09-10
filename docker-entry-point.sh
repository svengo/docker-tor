#!/bin/sh
set -e

if [ "$1" == 'tor' ]; then
  # generate /etc/tor/torrc-defaults
  confd -onetime -backend env
  
  # fix permissions
  chown -R tor:tor /data
  chmod 0700 /data
  
  # if /data/torrc doesn't exist, use sample
  if [ ! -s /data/torrc ]; then
    cp /etc/tor/torrc.sample /data/torrc
  fi
  
  # run tor
  exec su-exec tor "$@"
fi

exec "$@"
