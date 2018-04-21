#!/bin/sh

# locks down our consul server from leaking any data to anybody - full anon block


if [ -z "${ENABLE_GOSSIP}" ]; then
    echo "GOSSIP should be disabled"
    exit 0
fi

echo "enable gossip encryption"

if [ ! -f ${SERVER_CONFIG_STORE}/gossip.json ]; then
	GOSSIP_KEY=`consul keygen`
	echo "{\"encrypt\": \"${GOSSIP_KEY}\"}" > ${SERVER_CONFIG_STORE}/gossip.json
	cp ${SERVER_CONFIG_STORE}/gossip.json ${CLIENTS_CONFIG_STORE}/gossip.json
else
	cp ${SERVER_CONFIG_STORE}/gossip.json ${CLIENTS_CONFIG_STORE}/gossip.json
fi

