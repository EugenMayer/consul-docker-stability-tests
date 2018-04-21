#!/bin/sh

# fairly odd we actually need to add an agent acl token to the server since the server has an acl_master_token
# but well... this lets us get rid of
# [WARN] agent: Node info update blocked by ACLs
# [WARN] agent: Coordinate update blocked by ACLs

CONFIG_STORE=/consul/config

ACL_MASTER_TOKEN=`cat ${CONFIG_STORE}/acl_master_token.json | jq -r -M '.acl_master_token'`

# this is actually not neede with 1.0 - thats the defaul. So no permissions at all
ACL_AGENT_TOKEN=`curl -sS -X PUT --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" \
    --data \
'{
  "Name": "Server agent token",
  "Type": "client",
  "Rules": "agent \"\" { policy = \"write\" } event \"\" { policy = \"read\" } key \"\" { policy = \"write\" } node \"\" { policy = \"write\" } service \"\" { policy = \"write\" } operator = \"read\""
}' http://127.0.0.1:8500/v1/acl/create | jq -r -M '.ID'`

echo "{\"acl_agent_token\": \"${ACL_AGENT_TOKEN}\"}" > ${CONFIG_STORE}/acl_agent_token.json
