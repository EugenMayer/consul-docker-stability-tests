#!/bin/sh

CLIENTS_CONFIG_STORE=/consul/clients-general

until [ -f ${CLIENTS_CONFIG_STORE}/general_acl_token.json ]; do sleep 1;echo 'waiting for consul configuration for agent clients to be generated'; done;

ln -s ${CLIENTS_CONFIG_STORE}/general_acl_token.json /consul/config/general_acl_token.json
ln -s ${CLIENTS_CONFIG_STORE}/gossip.json /consul/config/gossip.json

exec docker-entrypoint.sh "$@"
