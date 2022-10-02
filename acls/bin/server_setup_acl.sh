#!/bin/sh

set -e

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

echo "starting server in local 127.0.0.1 for ACL setup only"
docker-entrypoint.sh agent -bind 127.0.0.1 --log-file=/tmp/bootstrap &
CONSUL_PID="$!"
echo -n "Waiting for consul server to start"
until curl -f http://127.0.0.1:8500/v1/status/leader > /dev/null 2>&1
do
    echo -n '.'
    sleep 2
done
echo 'server up'

server_acl_bootstrap.sh
server_acl_client_general_token.sh

# it's all done, let out bootstrap no longer repeat this, see converge
touch ${SERVER_CONFIG_STORE}/.aclsetupfinished

echo "--- shutting down 'local only' pid: ${CONSUL_PID}"
kill ${CONSUL_PID}
