#!/bin/sh

set -e

# fairly odd we actually need to add an agent acl token to the server since the server has an acl_master_token
# but well... this lets us get rid of
# [WARN] agent: Node info update blocked by ACLs
# [WARN] agent: Coordinate update blocked by ACLs
if [ -f ${SERVER_CONFIG_STORE}/server_acl_agent_acl_token.json ]; then
    current_acl_agent_token=$(cat ${SERVER_CONFIG_STORE}/server_acl_agent_acl_token.json | jq -r -M '.acl_agent_token')
fi

if [ ! -f ${SERVER_CONFIG_STORE}/server_acl_agent_acl_token.json ] || [ ! -f ${SERVER_CONFIG_STORE}/server_general_acl_token.json ] || [ -z "${current_acl_agent_token}" ]; then
    echo "generate server agent token to let the server access by ACLs"
    ACL_MASTER_TOKEN=`cat ${SERVER_CONFIG_STORE}/server_acl_master_token.json | jq -r -M '.acl_master_token'`

    # this is actually not neede with 1.0 - thats the defaul. So no permissions at all
    ACL_AGENT_TOKEN=`curl -sS -X PUT --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" \
        --data \
    '{
      "Name": "Server agent token",
      "Type": "client",
      "Rules": "agent \"\" { policy = \"write\" } event \"\" { policy = \"read\" } key \"\" { policy = \"write\" } node \"\" { policy = \"write\" } service \"\" { policy = \"write\" } operator = \"read\""
    }' http://127.0.0.1:8500/v1/acl/create | jq -r -M '.ID'`
    if [ -z "$ACL_AGENT_TOKEN" ]; then
      echo "FATAL: error generating ACL agent token, return acl token was empty when talking the the REST endpoint - no permissions?"
    else
      echo "setting acl agent token for the server"
      echo "{\"acl_agent_token\": \"${ACL_AGENT_TOKEN}\"}" > ${SERVER_CONFIG_STORE}/server_acl_agent_acl_token.json
      echo "setting acl token for the server"
      echo "{\"acl_token\": \"${ACL_AGENT_TOKEN}\"}" > ${SERVER_CONFIG_STORE}/server_general_acl_token.json
    fi
else
    echo "skipping acl_agent_token setup .. already configured";
fi
