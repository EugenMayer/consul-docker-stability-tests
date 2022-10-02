#!/bin/sh

shutdown ()
{
  echo "shutdown"
  kill $(pgrep -f 'consul agent')
}

until [ -f ${CLIENTS_SHARED_CONFIG_STORE}/.bootstrapped ]; do
  sleep 2;
  echo 'waiting for consul to be bootstrapped';
done;

if [ -f ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl ]; then
    ln -s ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.hcl /consul/config/general_acl_token.hcl
else
    rm -f /consul/config/general_acl_token.hcl > /dev/null
fi

if [ -f ${CLIENTS_SHARED_CONFIG_STORE}/gossip.hcl ]; then
    ln -s ${CLIENTS_SHARED_CONFIG_STORE}/gossip.hcl /consul/config/gossip.hcl
else
    rm -f /consul/config/gossip.hcl > /dev/null
fi

# traps for fast shutdown
trap shutdown INT TERM
exec docker-entrypoint.sh "$@" &
echo "Started consul client"
wait
