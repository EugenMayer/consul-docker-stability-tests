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
elif [ ! -f ${SERVER_CONFIG_STORE}/.upgraded.1.13 ]; then
  if [ "$CONSUL_ALLOW_MAJOR_UPGRADE" -ne "1" ]; then
     echo "Detected major upgrade, but CONSUL_ALLOW_MAJOR_UPGRADE=1 not set. Failing hard"
     exit 1
  fi

  echo "Detected upgrade from pre 1.13 version. Re-configuring ACL, tls and gossip entirely."
  echo "If you migrate from pre 1.13 be sure to set CONSUL_ALLOW_RESET_ACL=1 for the auto migration."
  echo "Removing the entire old configuration now"
  rm -f ${SERVER_CONFIG_STORE}/tls.json ${SERVER_CONFIG_STORE}/server_config.json ${SERVER_CONFIG_STORE}/server_acl.json \
   ${SERVER_CONFIG_STORE}/server_acl_master_token.json ${SERVER_CONFIG_STORE}/server_acl_agent_acl_token.json ${SERVER_CONFIG_STORE}/gossip.json \
   ${SERVER_CONFIG_STORE}/server_general_acl_token.json ${SERVER_CONFIG_STORE}/tls.key ${SERVER_CONFIG_STORE}/ca.crt ${SERVER_CONFIG_STORE}/cert.crt \
   ${SERVER_CONFIG_STORE}/cert.csr ${SERVER_CONFIG_STORE}/ca.srl ${SERVER_CONFIG_STORE}/ca.key ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.json
  echo "Recreating configuration"
  server_setup_tls.sh `hostname -f`
  server_setup_gossip.sh
  server_setup_acl.sh

  touch ${SERVER_CONFIG_STORE}/.upgraded.1.13
elif [ ! -f ${SERVER_CONFIG_STORE}/.aclsetupfinished ]; then
  echo "WARN ACL Setup not finished (but configured). Re-configuring ACL."
  server_setup_acl.sh
else
  echo "Server is configured and converged - starting"
fi
