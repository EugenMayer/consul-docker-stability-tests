#!/bin/bash

VERSION=1.13
./start-ip1.sh ${VERSION}
sleep 10s
./start-ip2.sh ${VERSION}

sleep 4s
echo "retrieving test-value which should be of value' migrated'"
docker-compose -f docker-compopose-${VERSION}.yml -f docker-compose-ip2.yml exec server consul kv get test-value

