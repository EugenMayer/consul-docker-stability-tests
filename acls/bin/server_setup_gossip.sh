#!/bin/sh

set -e

if [ -z "${ENABLE_GOSSIP}" ] || [ "${ENABLE_GOSSIP}" -eq "0" ]; then
    echo "GOSSIP is disabled, skipping configuration"
    exit 0
fi

echo "- Enable gossip encryption"

if [ ! -f ${SERVER_CONFIG_STORE}/gossip.hcl ]; then
	GOSSIP_KEY=`consul keygen`
	cat > ${SERVER_CONFIG_STORE}/gossip.hcl <<EOL
encrypt = "${GOSSIP_KEY}"
EOL
	cp ${SERVER_CONFIG_STORE}/gossip.hcl ${CLIENTS_SHARED_CONFIG_STORE}/gossip.hcl
else
	cp ${SERVER_CONFIG_STORE}/gossip.hcl ${CLIENTS_SHARED_CONFIG_STORE}/gossip.hcl
fi
