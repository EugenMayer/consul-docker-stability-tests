#!/bin/bash

VERSION=${1:-0.7}

echo " STARTING RECOVERY .... "
echo "deploying peers.json to fix the leadership issue"
docker cp peers.json consuliptest_server_1:/consul/data/raft/peers.json
docker-compose -f docker-compopose-${VERSION}.yml -f docker-compose-ip2.yml restart server

sleep 2s
echo "retrieving test-value which should be of value' migrated'"
docker-compose -f docker-compopose-${VERSION}.yml -f docker-compose-ip2.yml exec server /usr/bin/curl -sS -X GET http://localhost:8500/v1/kv/test-value

