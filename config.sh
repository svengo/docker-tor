#!/usr/bin/env sh

export ORPORT="${ORPORT:-9001}"
export DIRPORT="${DIRPORT:-9030}"
export EXITPOLICY="${EXITPOLICY:-reject *:*}"
export CONTROLPORT="${CONTROLPORT:-9051}"
export HASHEDCONTROLPASSWORD="${HASHEDCONTROLPASSWORD:-}"
export NICKNAME="${NICKNAME:-ididnteditheconfig}"
export CONTACTINFO="${CONTACTINFO:-Random Person <nobody AT example dot com>}"

# Variables below are optional and will be omitted from torrc if empty
export MYFAMILY="${MYFAMILY:-}"
export ADDRESS="${ADDRESS:-}"
export RELAY_BANDWIDTH_RATE="${RELAY_BANDWIDTH_RATE:-}"
export RELAY_BANDWIDTH_BURST="${RELAY_BANDWIDTH_BURST:-}"
export SOCKS_POLICY="${SOCKS_POLICY:-}"
export SOCKS_PORT="${SOCKS_PORT:-}"
