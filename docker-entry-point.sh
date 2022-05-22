#!/bin/sh
set -e

# default configuration
export ORPORT="${ORPORT:-9001}"
export DIRPORT="${DIRPORT:-9030}"
export EXITPOLICY="${EXITPOLICY:-reject *:*}"
export CONTROLPORT="${CONTROLPORT:-9051}"
export HASHEDCONTROLPASSWORD="${HASHEDCONTROLPASSWORD:-16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C}"
export NICKNAME="${NICKNAME:-ididnteditheconfig}"
export CONTACTINFO="${CONTACTINFO:-Random Person <nobody AT example dot com>}"

# generate /etc/tor/torrc-defaults
/usr/bin/envsubst < /etc/tor/torrc-defaults-source > /etc/tor/torrc-defaults

# fix permissions
chown -R tor:tor /data
chmod 0700 /data

# if /data/torrc doesn't exist, use sample
if [ ! -s /data/torrc ]; then
  cp /etc/tor/torrc.sample /data/torrc
fi
  
if [ "$1" = "tor" ]; then
  # run tor
  exec /usr/bin/su-exec tor "$@"
fi

exec "$@"
