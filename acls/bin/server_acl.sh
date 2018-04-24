#!/bin/sh

set -e
if [ -z "$ENABLE_ACL" ] || [ "$ENABLE_ACL" -eq "0" ] ; then
    echo "ACLs is disabled, skipping configuration"
    echo "creating dummy general_acl_token.json file so the clients can start"
    exit 0
fi

# locks down our consul server from leaking any data to anybody - full anon block

if [ ! -f ${SERVER_CONFIG_STORE}/server_acl_master_token.json ]; then
	echo "generating master token"
	ACL_MASTER_TOKEN=`curl -sS -X PUT http://127.0.0.1:8500/v1/acl/bootstrap | jq -r -M '.ID'`
	# save our token
	cat > ${SERVER_CONFIG_STORE}/server_acl_master_token.json <<EOL
{
  "acl_master_token": "${ACL_MASTER_TOKEN}"
}
EOL

# we also put the master token as acl_token for our consul server so we can operated without token on the local cli
# TODO: this is not allowed, see https://github.com/hashicorp/consul/issues/4056 and will open the UI wide open
  cat > ${SERVER_CONFIG_STORE}/server_acl_token.json <<EOL
{
  "acl_token": "${ACL_MASTER_TOKEN}"
}
EOL
fi

echo "our server should have an agent token"
server_acl_agent_token.sh

echo "forbid any anon access"
server_acl_anon.sh

echo "allowing usual node access using a token"
server_acl_acl_token.sh
