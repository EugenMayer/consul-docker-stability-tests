#!/bin/sh

# locks down our consul server from leaking any data to anybody - full anon block
SERVER_CONFIG_STORE=/consul/config
CLIENTS_CONFIG_STORE=/consul/clients-general

ACL_MASTER_TOKEN=`cat ${SERVER_CONFIG_STORE}/acl_master_token.json | jq -r -M '.acl_master_token'`

# this is actually not neede with 1.0 - thats the defaul. So no permissions at all
GOSSIP_KEY=`consul keygen`
`curl -sS -X PUT --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" \
    --data \
"{
   \"Key\": \"${GOSSIP_KEY}\",
}" http://127.0.0.1:8500/v1/operator/keyring | jq -r -M '.ID'`

curl -sS -X POST --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" http://127.0.0.1:8500/v1//operator/keyring > /dev/null
echo "{\"encrypt\": \"${GOSSIP_KEY}\"}" > ${SERVER_CONFIG_STORE}/gossip.json
echo "{\"encrypt\": \"${GOSSIP_KEY}\"}" > ${CLIENTS_CONFIG_STORE}/gossip.json

