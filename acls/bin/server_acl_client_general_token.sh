#!/bin/sh

set -e

# Generates an acl_token with all usual ops an agent client needs to fully utilize the consul server.
# Stores it on a shared volume so it can be consumed by the actual consul agent clients.

mkdir -p ${CLIENTS_SHARED_CONFIG_STORE}

if [ ! -f ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl ]; then
  echo "generating consul client general ACL token for usual access"
  cat > ${SERVER_CONFIG_STORE}/policy_agents.policy <<EOL
node_prefix "" {
  policy = "write"
}
agent_prefix "" {
  policy = "write"
}
event_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "write"
}
key_prefix "" {
  policy = "write"
}
EOL
  # if the policy already exists, replace
  consul acl policy delete -name agents > /dev/null 2>&1 || true
  consul acl policy create -name agents -rules @${SERVER_CONFIG_STORE}/policy_agents.policy
  rm -f ${SERVER_CONFIG_STORE}/policy_agents.policy
  ACL_AGENT_TOKEN=`consul acl token create -description "agents" -policy-name agents --format json  | jq -r -M '.SecretID'`
	cat > ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl <<EOL
acl {
  tokens {
    default  = "${ACL_AGENT_TOKEN}"
  }
}
EOL
  CLIENT_HTTP_TOKEN_FILE="${CLIENTS_SHARED_CONFIG_STORE}/.consul_cli_token"

  echo "Setting up client-token-file to '$CLIENT_HTTP_TOKEN_FILE'"
  echo "${ACL_AGENT_TOKEN}" > $CLIENT_HTTP_TOKEN_FILE
  chown consul:consul ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl $CLIENT_HTTP_TOKEN_FILE
else
  echo "skipping acl_token setup .. already configured";
fi


