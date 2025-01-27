#!/usr/bin/env sh

export ORPORT="${ORPORT:-9001}"
export DIRPORT="${DIRPORT:-9030}"
export EXITPOLICY="${EXITPOLICY:-reject *:*}"
export CONTROLPORT="${CONTROLPORT:-9051}"
export HASHEDCONTROLPASSWORD="${HASHEDCONTROLPASSWORD:-16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C}"
export NICKNAME="${NICKNAME:-ididnteditheconfig}"
export CONTACTINFO="${CONTACTINFO:-Random Person <nobody AT example dot com>}"
export RELAY_BANDWIDTH_RATE="${RELAY_BANDWIDTH_RATE:-80 MB}"
export RELAY_BANDWIDTH_BURST="${RELAY_BANDWIDTH_BURST:-100 MB}"
export TOR_SOCKS_PORT="${TOR_SOCKS_PORT:-0.0.0.0:9050}"
