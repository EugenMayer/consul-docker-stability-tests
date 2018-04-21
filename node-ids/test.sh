#!/bin/bash

docker-compose -f docker-compose-nodata.yml up -d
echo "------------ clients registered"
sleep 5s
echo "------------  removing clients again"
docker-compose -f docker-compose-nodata.yml rm -s -f client1
docker-compose -f docker-compose-nodata.yml rm -s -f client2
sleep 5s
echo "------------ registering clients again and checking for conflicts"
docker-compose -f docker-compose-nodata.yml up -d
