#!/bin/sh

set -e
if [ -z "$ENABLE_ACL" ]; then
    echo "ACLs should be disabled"
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
fi


echo "our server should have an agent token"
server_acl_agent_token.sh

echo "forbid any anon access"
server_acl_anon.sh

echo "allowing usual node access using a token"
server_acl_acl_token.sh