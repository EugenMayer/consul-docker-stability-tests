#!/bin/sh

mkdir -p ${SERVER_CONFIG_STORE}
mkdir -p ${CLIENTS_SHARED_CONFIG_STORE}

if [ -f ${SERVER_CONFIG_STORE}/.firstsetup ]; then
	touch ${CLIENTS_SHARED_CONFIG_STORE}/.bootstrapped

	# this is a moveable pointer, so in 2023 we will use .updatecerts2018 to regenerate all certificates since tey are valid for 5 years only
	if [ ! -f ${SERVER_CONFIG_STORE}/.updatecerts2018 ]; then
        server_tls.sh `hostname -f`
	    touch ${SERVER_CONFIG_STORE}/.updatecerts2018
    fi
fi

if [ -z "${ENABLE_APK}" ]; then
	echo "disabled apk, hopefully you got all those things installed: bash curl jq openssl"
else
	apk update
	apk add bash curl jq openssl
fi

mkdir -p ${SERVER_CONFIG_STORE}

if [ -f ${SERVER_CONFIG_STORE}/.firstsetup ]; then
   echo "Server already bootstrapped"
   echo "ensuring acl is configured" && server_acl.sh

   exec docker-entrypoint.sh "$@"
else
  echo "--- First bootstrap of the server..configuring ACL/GOSSIP/TLS as configured"

  server_tls.sh `hostname -f`
  server_gossip.sh
  if [ -n "${ENABLE_ACL}" ] && [ ! "${ENABLE_ACL}" -eq "0" ] ; then
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

  echo "--- shutting down 'local only' server and starting usual server"
  kill ${pid}

  # that does secure we do not rerun this initial bootstrap configuration
  touch ${SERVER_CONFIG_STORE}/.firstsetup

  # tell our clients they can startup, finding the configuration they need on the shared volume
  touch ${CLIENTS_SHARED_CONFIG_STORE}/.bootstrapped
  exec docker-entrypoint.sh "$@"
fi