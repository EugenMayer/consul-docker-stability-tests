#!/bin/bash

VERSION=${1:-0.7}

echo "STARTING STACK WItH CONSUL IP2"
docker-compose -f docker-compose-${VERSION}.yml down

echo "starting stack with new ip - should be broken"
docker-compose -f docker-compose-${VERSION}.yml -f docker-compose-ip2.yml up -d