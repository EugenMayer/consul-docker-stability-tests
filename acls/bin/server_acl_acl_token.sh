#!/bin/sh

CONFIG_STORE=/consul/config
CLIENTS_CONFIG_STORE=/consul/clients-general

mkdir -p ${CLIENTS_CONFIG_STORE}

ACL_MASTER_TOKEN=`cat ${CONFIG_STORE}/acl_master_token.json | jq -r -M '.acl_master_token'`

# this generates a token for all our agent clients to register with the server, write kvs and register services
ACL_TOKEN=`curl -sS -X PUT --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" \
    --data \
'{
  "Name": "GENERAL_ACL_TOKEN",
  "Type": "client",
  "Rules":  "key \"\" { policy = \"write\" } node \"\" { policy = \"write\" } service \"\" { policy = \"write\" } operator = \"read\""
}' http://127.0.0.1:8500/v1/acl/create | jq -r -M '.ID'`

# echo "Agent client token: ${AGENT_CLIENT_TOKEN}"
echo "{\"acl_token\": \"${ACL_TOKEN}\"}" > ${CLIENTS_CONFIG_STORE}/general_acl_token.json

