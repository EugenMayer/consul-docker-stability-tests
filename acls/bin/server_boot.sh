#!/bin/sh

## ensure consul is yet not running - important due to supervisor restart
pkill consul

set -e

mkdir -p ${SERVER_CONFIG_STORE}
mkdir -p ${CLIENTS_SHARED_CONFIG_STORE}

if [ -z "${ENABLE_APK}" ]; then
	echo "disabled apk, hopefully you got all those things installed: bash curl jq openssl"
else
	apk update
	apk add bash curl jq openssl
fi

mkdir -p ${SERVER_CONFIG_STORE}

if [ -f ${SERVER_CONFIG_STORE}/.firstsetup ]; then
  server_setup_converge.sh
else
  server_setup_firstboot.sh
fi

# normal startup
exec docker-entrypoint.sh "$@"

