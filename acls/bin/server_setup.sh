#!/bin/sh

mkdir -p ${SERVER_CONFIG_STORE}
mkdir -p ${CLIENTS_CONFIG_STORE}

if [ -z "${ENABLE_APK}" ]; then
	echo "disabled apk, hopefully you got all those things installed.."
else
	apk update
	apk add bash curl jq openssl
fi

mkdir -p ${SERVER_CONFIG_STORE}

if [ -f ${SERVER_CONFIG_STORE}/.firstsetup ]; then
   echo "Server already bootstrapped"
   exec docker-entrypoint.sh "$@"
else
  echo "--- First bootstrap of the server..configuring ACL/GOSSIP/TLS as configured"

  server_tls.sh 127.0.0.1
  server_gossip.sh
  if [ -n "$ENABLE_ACL" ] && [ ! "$ENABLE_ACL" -eq "0" ] ; then
  	# this needs to be done before the server starts, we cannot move that into server_acl.sh
	cat > ${SERVER_CONFIG_STORE}/server_acl.json <<EOL
{
  "acl_datacenter": "stable",
  "acl_default_policy": "deny",
  "acl_down_policy": "deny"
}
EOL
  fi

  echo "---- Starting server in local 127.0.0.1 to not allow node registering during configuration"
  docker-entrypoint.sh "$@" -bind 127.0.0.1 &
  pid="$!"

  echo "waiting for the server to come up"
  wait-for-it -t 30 -h 127.0.0.1 -p 8500 -- echo "consul server is up"
  sleep 5s

  server_acl.sh

  echo "--- shutting down local only server and starting usual server"
  kill ${pid}

  touch ${SERVER_CONFIG_STORE}/.firstsetup
  exec docker-entrypoint.sh "$@"
fi
