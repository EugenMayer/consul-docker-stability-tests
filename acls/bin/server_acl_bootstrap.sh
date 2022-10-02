#!/bin/sh

set -e

echo "Setting up initial master token for initial ACL bootstrap"
# we are clearing the CONSUL_HTTP_TOKEN_FILE= definition for this call, since the file cannot exist yet
# and it is used by consul otherwise. So if it is defined, ensure we bootstrap without it for now
ACL_MASTER_TOKEN=`CONSUL_HTTP_TOKEN_FILE= consul acl bootstrap --format=json | jq -r -M '.SecretID'`
if [[ ! -z "$CONSUL_HTTP_TOKEN_FILE" ]]; then
  echo "Setting up token-file to '$CONSUL_HTTP_TOKEN_FILE'"
  echo "${ACL_MASTER_TOKEN}" > $CONSUL_HTTP_TOKEN_FILE
  chown consul:consul $CONSUL_HTTP_TOKEN_FILE
else
  # no token file path was defined, so using ENV based authentication
  export CONSUL_HTTP_TOKEN="${ACL_MASTER_TOKEN}"
fi

# setup out initial bootstrap token and the agent token
# FIXME: agent does not work on our server, it does only work for the clients. Means, the the consul cli on the server
#  will not utilize the agent token to talk to the server. On the clients, this does work
cat > ${SERVER_CONFIG_STORE}/server_tokens.hcl <<EOL
acl {
  tokens {
    initial_management = "${ACL_MASTER_TOKEN}"
    agent = "${ACL_MASTER_TOKEN}"
  }
}
EOL

# to reload the config to apply all the above
consul reload
