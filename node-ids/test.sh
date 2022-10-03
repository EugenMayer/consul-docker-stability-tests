#!/bin/bash

docker-compose -f docker-compose-nodata.yml up -d
echo "------------ waiting for clients to be registered"
sleep 15s
echo "------------ removing clients again (stopping)"
docker-compose -f docker-compose-nodata.yml rm -s -f client1
docker-compose -f docker-compose-nodata.yml rm -s -f client2
sleep 15s
echo "------------ registering clients again and checking for conflicts"
docker-compose -f docker-compose-nodata.yml up -d
echo "waiting for the clients to re-register"
sleep 10s
docker-compose exec server consul members
