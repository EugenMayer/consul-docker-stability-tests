#!/bin/bash

VERSION=${1:-1.2}

echo "STARTING STACK WItH CONSUL IP1"
docker-compose -f docker-compose-$VERSION.yml up -d
# docker-compose exec server cat /mnt/config/consul/conf.d/acl_master_token.json
# takes a bit for consul to become a leader, so wait a little
sleep 3
docker-compose -f docker-compose-$VERSION.yml exec server /usr/bin/curl -sS -X PUT -d 'migrated' http://localhost:8500/v1/kv/test-value
