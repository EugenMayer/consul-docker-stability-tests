#!/bin/bash

#docker-compose down -v
docker-compose up -d
sleep 10s
ACL_MASTER_TOKEN=`docker-compose  exec server cat /consul/config/acl_master_token.json | jq -r -M '.acl_master_token'`
echo "ACL_MASTER_TOKEN is ${ACL_MASTER_TOKEN}"

echo "-----------raft version"
docker-compose  exec server consul info -token=${ACL_MASTER_TOKEN} | grep -a20 raft | grep protocol_version

echo "----------- encryption / gossip status"
docker-compose  exec server consul info -token=deee924d-da3f-1f2d-b8d9-2da413b0e288 | grep encrypted

echo "----------- members"
docker-compose  exec server consul members -token=${ACL_MASTER_TOKEN}

echo "----------- anon access without token"
docker-compose  exec server consul members

echo "----------- agent client access (acl_token)"
ACL_TOKEN=`docker-compose  exec server cat /consul/clients-general/general_acl_token.json | jq -r -M '.acl_token'`
docker-compose  exec server consul members -token=${ACL_TOKEN}