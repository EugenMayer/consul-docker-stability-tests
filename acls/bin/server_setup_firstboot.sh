#!/bin/sh

set -e

echo "--- First bootstrap of the server ... configuring ACL/GOSSIP/TLS as requested"

server_setup_tls.sh `hostname -f`
server_setup_gossip.sh

if [ -z "$ENABLE_ACL" ] || [ "$ENABLE_ACL" -eq "0" ]; then
  echo "ACLs is disabled, skipping configuration"
  mkdir -p ${CLIENTS_SHARED_CONFIG_STORE}
  echo "" > ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl
  exit 0
else
  server_setup_acl.sh
fi

# that does secure we do not rerun this initial bootstrap configuration
touch ${SERVER_CONFIG_STORE}/.firstsetup

# tell our clients they can startup, finding the configuration they need on the shared volume
touch ${CLIENTS_SHARED_CONFIG_STORE}/.bootstrapped


