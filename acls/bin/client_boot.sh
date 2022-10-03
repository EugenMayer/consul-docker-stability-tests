#!/bin/sh

shutdown ()
{
  echo "shutdown"
  # even though this is slower, it avoids that we do not properly de-register this node and when we start
  # it again with a new node-id, consul might assume that name is still taken by a different node-id
  # avoid using -KILL here, faster but problematic
  # consul leave
  kill -TERM $(pgrep -f 'consul agent')
  #kill -KILL $(pgrep -f 'consul agent')
}

echo -n "waiting for consul to be bootstrapped"
until [ -f ${CLIENTS_SHARED_CONFIG_STORE}/.bootstrapped ]; do
  sleep 2
  echo -n '.'
done
echo ''

if [ -f ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl ]; then
    ln -sf ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl /consul/config/general_acl_token.hcl
else
    rm -f /consul/config/general_acl_token.hcl > /dev/null
fi

if [ -f ${CLIENTS_SHARED_CONFIG_STORE}/gossip.hcl ]; then
    ln -sf ${CLIENTS_SHARED_CONFIG_STORE}/gossip.hcl /consul/config/gossip.hcl
else
    rm -f /consul/config/gossip.hcl > /dev/null
fi

# traps for fast shutdown
trap shutdown INT TERM KILL

##############  UUID generation
####### uuidgen based uuid
#export NODE_ID=$(uuidgen -N "foo" --namespace "@dns" --sha1)
####### shasum based uuid
IDBASE=$(echo `hostname`| sha512sum)
# 8-4-4-4-12
NODE_ID="$(echo $IDBASE | cut -c1-8)-$(echo $IDBASE | cut -c9-12)-$(echo $IDBASE | cut -c13-16)-$(echo $IDBASE | cut -c17-20)-$(echo $IDBASE | cut -c21-32)"

echo "node_id = \"$NODE_ID\"" > /consul/config/node_id.hcl

exec docker-entrypoint.sh "$@" &
echo "Started consul client"
wait
