#!/bin/sh

apk update
apk add bash curl jq

CONFIG_STORE=/consul/config
mkdir -p ${CONFIG_STORE}


if [ -f ${CONFIG_STORE}/acl_master_token.json ]; then
   echo "Server already bootstrapped"
   exec docker-entrypoint.sh "$@"
else
  echo "--- First bootstrap of the server..configuring ACL"

  echo "---- Starting server in local 127.0.0.1 to not allow node registering during configuration"
  docker-entrypoint.sh "$@" -bind 127.0.0.1 &
  pid="$!"

  echo "waiting for the server to come up"
  sleep 5

  echo "generating master token"
  ACL_MASTER_TOKEN=`curl -sS -X PUT http://127.0.0.1:8500/v1/acl/bootstrap | jq -r -M '.ID'`
  #echo "ACL_MASTER_TOKEN IS: ${ACL_MASTER_TOKEN}"
  echo "{\"acl_master_token\": \"${ACL_MASTER_TOKEN}\"}" > ${CONFIG_STORE}/acl_master_token.json

  echo "forbid any anon access"
  server_acl_anon.sh

  echo "allowing usual node access using a token"
  server_acl_acl_token.sh
  echo "--- shutting down local only server and starting usual server"
  kill ${pid}

  exec docker-entrypoint.sh "$@"
fi
