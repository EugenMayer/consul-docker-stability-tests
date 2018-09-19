#!/bin/sh

set -e

# generates an acl_token with all usual ops a agent client need to fully utilize the consul server
# stores it on a share volume so it can be consumed by out consul agent clients

mkdir -p ${CLIENTS_SHARED_CONFIG_STORE}

if [ ! -f ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.json ]; then
    echo "generating consul client general ACL token for usual access"
    ACL_MASTER_TOKEN=`cat ${SERVER_CONFIG_STORE}/server_acl_master_token.json | jq -r -M '.acl_master_token'`

    # this generates a token for all our agent clients to register with the server, write kvs and register services
    ACL_TOKEN=`curl -sS -X PUT --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" \
        --data \
    '{
      "Name": "GENERAL_ACL_TOKEN",
      "Type": "client",
      "Rules": "agent \"\" { policy = \"write\" } event \"\" { policy = \"read\" } key \"\" { policy = \"write\" } node \"\" { policy = \"write\" } service \"\" { policy = \"write\" } operator = \"read\""
    }' http://127.0.0.1:8500/v1/acl/create | jq -r -M '.ID'`

    # let the consul server properly adjust that this ACL exist - when we write the token below all our clients start to boot
    #sleep 1
    # echo "Agent client token: ${AGENT_CLIENT_TOKEN}"
    echo "{\"acl_token\": \"${ACL_TOKEN}\"}" > ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.json
else
    echo "skipping acl_token setup .. already configured";
fi


