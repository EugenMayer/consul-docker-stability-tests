#!/bin/sh

until [ -f ${CLIENTS_SHARED_CONFIG_STORE}/.bootstrapped ]; do sleep 1;echo 'waiting for consul configuration for agent clients to be generated'; done;

if [ -f ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.json ]; then
    ln -s ${CLIENTS_SHARED_CONFIG_STORE}/general_acl_token.json /consul/config/general_acl_token.json
else
    rm -f /consul/config/general_acl_token.json > /dev/null
fi

if [ -f ${CLIENTS_SHARED_CONFIG_STORE}/gossip.json ]; then
    ln -s ${CLIENTS_SHARED_CONFIG_STORE}/gossip.json /consul/config/gossip.json
else
    rm -f /consul/config/gossip.jsonn > /dev/null
fi
exec docker-entrypoint.sh "$@"
