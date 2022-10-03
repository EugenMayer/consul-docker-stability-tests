#!/bin/bash

VERSION=1.2
./start-ip1.sh ${VERSION}
sleep 10s
./start-ip2.sh ${VERSION}

sleep 4s
echo "retrieving test-value which should be of value' migrated'"
docker-compose -f docker-compose-${VERSION}.yml -f docker-compose-ip2.yml exec server /usr/bin/curl -sS -X GET http://localhost:8500/v1/kv/test-value

