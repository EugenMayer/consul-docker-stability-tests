#!/bin/sh

CONFIG_STORE=/consul/config

ACL_MASTER_TOKEN=`cat ${CONFIG_STORE}/acl_master_token.json | jq -r -M '.acl_master_token'`
#echo "using ACL MASTER TOKEN: ${ACL_MASTER_TOKEN}"

# this is actually not neede with 1.0 - thats the defaul. So no permissions at all
curl -sS -X PUT --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" \
    --data \
'{
  "ID": "anonymous",
  "Type": "client",
  "Rules": "node \"\" { policy = \"deny\" }"
}' http://127.0.0.1:8500/v1/acl/update > /dev/null
