#!/bin/sh

set -e

CONSUL_PID=
ACL_MASTER_TOKEN=

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
  OUTPUT=$(CONSUL_HTTP_TOKEN_FILE= consul acl bootstrap --format=json)
  ACL_MASTER_TOKEN=$(echo $OUTPUT | jq -r -M '.SecretID')
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
  sleep 4
  startOfflineServer
  set -e
}

echo "- Enabling ACL support"
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

startOfflineServer

boostrapAcl || true

if [[ -z "$ACL_MASTER_TOKEN" ]]; then
  if [[ -n "$CONSUL_ALLOW_RESET_ACL" ]]; then
    resetAclSystem
    boostrapAcl

    if [[ -z "$ACL_MASTER_TOKEN" ]]; then
      echo "failed resetting"
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
