#!/bin/sh

apk update
apk add bash curl jq openssl

SERVER_CONFIG_STORE=/consul/config
mkdir -p ${SERVER_CONFIG_STORE}


if [ -f ${SERVER_CONFIG_STORE}/acl_master_token.json ]; then
   echo "Server already bootstrapped"
   exec docker-entrypoint.sh "$@"
else
  echo "--- First bootstrap of the server..configuring ACL"

  echo "setup tls"
  server_tls.sh 127.0.0.1

  echo "---- Starting server in local 127.0.0.1 to not allow node registering during configuration"
  docker-entrypoint.sh "$@" -bind 127.0.0.1 &
  pid="$!"

  echo "waiting for the server to come up"
  wait-for-it -t 30 -h 127.0.0.1 -p 8500 -- echo "consul server is up"

  echo "generating master token"
  ACL_MASTER_TOKEN=`curl -sS -X PUT http://127.0.0.1:8500/v1/acl/bootstrap | jq -r -M '.ID'`
  # save our token
  echo "{\"acl_master_token\": \"${ACL_MASTER_TOKEN}\"}" > ${SERVER_CONFIG_STORE}/acl_master_token.json

  server_acl_agent_token.sh

  echo "forbid any anon access"
  server_acl_anon.sh

  echo "allowing usual node access using a token"
  server_acl_acl_token.sh

  echo "enable gossip encryption"
  server_gossip.sh


  echo "--- shutting down local only server and starting usual server"
  kill ${pid}

  exec docker-entrypoint.sh "$@"
fi
