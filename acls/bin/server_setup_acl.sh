#!/bin/sh

set -e

CONSUL_PID=
ACL_MASTER_TOKEN=

# sets CONSUL_PIDm which you can use to stop the server again
# waits for the server to come up before continuing
startOfflineServer() {
  echo "starting server in local 127.0.0.1 for ACL setup only"
  docker-entrypoint.sh agent -bind 127.0.0.1 > /dev/null &
  CONSUL_PID="$!"
  echo -n "Waiting for consul server to start"
  until curl -f http://127.0.0.1:8500/v1/status/leader > /dev/null 2>&1
  do
      echo -n '.'
      sleep 2
  done
  echo ''
  echo 'server up'
}

stopOfflineServer()
{
  echo "--- shutting down 'local only' pid: ${CONSUL_PID}"
  kill ${CONSUL_PID}
}

boostrapAcl() {
  set +e
  OUTPUT=$(CONSUL_HTTP_TOKEN_FILE= consul acl bootstrap --format=json)
  ACL_MASTER_TOKEN=$(echo $OUTPUT | jq -r -M '.SecretID')
  set -e
}

resetAclSystem() {
  set +e
  echo "Resetting ACL system"
  OUTPUT=$(CONSUL_HTTP_TOKEN_FILE= consul acl bootstrap --format=json 2>&1)
  RESET_INDEX=`echo $OUTPUT | sed -E 's/^.*\(reset index:\s?(.*)\)\)$/\1/'`
  if [[ -z "$RESET_INDEX" ]]; then
    echo "Failed to find reset index"
    exit 1
  fi
  echo "ACL RESET INDEX: $RESET_INDEX"
  echo $RESET_INDEX > /consul/data/acl-bootstrap-reset
  stopOfflineServer
  # ensure it has shutdown
  sleep 8
  startOfflineServer
  # ensure it has started for sure and has selected a cluster leader
  sleep 4
  set -e
}

echo "- Enabling ACL support"
# we fist need to enable ACL support, prior starting the server
cat > ${SERVER_CONFIG_STORE}/server_acl_base.hcl <<EOL
datacenter = "stable"
primary_datacenter = "stable"
acl {
  enabled = true
  default_policy = "deny"
  down_policy = "extend-cache"
  enable_token_persistence = true
}
EOL

chown consul:consul ${SERVER_CONFIG_STORE}/server_acl_base.hcl

# start the server with enabled ACL support, so we can bootstrap ACL
startOfflineServer

# try to bootstrap, if it succeeds ACL_MASTER_TOKEN will be set
boostrapAcl

if [[ -z "$ACL_MASTER_TOKEN" ]]; then
  # ACL cannot be bootstrapped, most probably it has been bootstrapped beforehand
  if [[ -n "$CONSUL_ALLOW_RESET_ACL" ]]; then
    # reset ACL system
    resetAclSystem
    # now should we be able to boostrap
    boostrapAcl

    if [[ -z "$ACL_MASTER_TOKEN" ]]; then
      echo "failed resetting and rebootstrapping - we cannot recover automatically, please try yourself"
      exit 1
    fi
  else
    echo "Cannot bootstrap ACL - most probably it (was) already bootstrapped before. CONSUL_ALLOW_RESET_ACL not set - failing hard"
    exit 1
  fi
else
  echo "ACL token bootstrapped"
fi

server_acl_bootstrap.sh $ACL_MASTER_TOKEN
server_acl_client_general_token.sh

# it's all done, let out bootstrap no longer repeat this, see converge
touch ${SERVER_CONFIG_STORE}/.aclsetupfinished
stopOfflineServer
