#!/bin/sh

set -e

# locks down our consul server from leaking any data to anybody - full anon block

if [ -z "${ENABLE_GOSSIP}" ] || [ "${ENABLE_GOSSIP}" -eq "0" ]; then
    echo "GOSSIP is disabled, skipping configuration"
    exit 0
fi

echo "enable gossip encryption"

if [ ! -f ${SERVER_CONFIG_STORE}/gossip.json ]; then
	GOSSIP_KEY=`consul keygen`
	echo "{\"encrypt\": \"${GOSSIP_KEY}\"}" > ${SERVER_CONFIG_STORE}/gossip.json
	cp ${SERVER_CONFIG_STORE}/gossip.json ${CLIENTS_SHARED_CONFIG_STORE}/gossip.json
else
	cp ${SERVER_CONFIG_STORE}/gossip.json ${CLIENTS_SHARED_CONFIG_STORE}/gossip.json
fi