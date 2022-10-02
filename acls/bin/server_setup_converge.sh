#!/bin/sh

set -e

echo "Server already bootstrapped - checking config and converging"

if [ -z "$ENABLE_ACL" ] || [ "$ENABLE_ACL" -eq "0" ]; then
  echo "de-configuring ACL, it has been disabled"
  # de-configure ACL, no longer present
  # old legacy configs
  rm -f ${SERVER_CONFIG_STORE}/.aclanonsetup ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.json ${SERVER_CONFIG_STORE}/server_acl_master_token.json ${SERVER_CONFIG_STORE}/server_acl_agent_acl_token.josn
  # new configs, hcl based
  rm -f ${SERVER_CONFIG_STORE}/.aclanonsetup ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl ${SERVER_CONFIG_STORE}/server_tokens.hcl ${SERVER_CONFIG_STORE}/.aclsetupfinished
elif [ ! -f ${SERVER_CONFIG_STORE}/.aclsetupfinished ]; then
  echo "WARN ACL Setup not finished, but configured. Re-configuring ACL"
  server_setup_acl.sh
else
  echo "Server is configured and converged - starting"
fi

