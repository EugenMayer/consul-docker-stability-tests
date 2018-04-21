#!/bin/sh

# locks down our consul server from leaking any data to anybody - full anon block


if [ -z "${ENABLE_GOSSIP}" ]; then
    echo "GOSSIP should be disabled"
    exit 0
fi

echo "enable gossip encryption"

GOSSIP_KEY=`consul keygen`
echo "{\"encrypt\": \"${GOSSIP_KEY}\"}" > ${SERVER_CONFIG_STORE}/gossip.json
echo "{\"encrypt\": \"${GOSSIP_KEY}\"}" > ${CLIENTS_CONFIG_STORE}/gossip.json

