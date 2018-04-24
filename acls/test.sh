#!/bin/bash

ACL_MASTER_TOKEN=`docker-compose exec server bash -l -c "cat /consul/config/server_acl_master_token.json | jq -r -M '.acl_master_token'"`
echo "ACL_MASTER_TOKEN is ${ACL_MASTER_TOKEN}"

# all those request work since we used the ACL_MASTER_TOKEN durint the bootstrap to set acl_token on the consul server
echo "----------- server: raft version"
if docker-compose  exec server consul info| grep -a20 raft | grep 'protocol_version = 3'; then
  echo "[ok] raft is v3"
else
  echo "[ERROR] raft is not version 3"
  exit 1
fi

echo "----------- server: encryption / gossip status"
if docker-compose  exec server consul info| grep encrypted; then
  echo "[ok] gossip encryption activated"
else
  echo "[ERROR] encryption not activated"
  exit 1
fi

echo "----------- server:  members (servers acl_token which is the master token)"
if docker-compose  exec server consul members; then
  echo "[ok]"
else
  echo "[ERROR] cannot query members using servers acl_token"
  exit 1
fi

echo "----------- anon access without token - member list should be empty"
docker-compose  exec server consul members -token=anonymous

if docker-compose  exec server consul members | grep encrypted; then
  echo "[ERROR] list not empty - anon can access list"
  exit 1
else
  echo "[ok]"
fi

echo "----------- server: writing KW value"
# this works due to our
if docker-compose  exec server /usr/bin/curl -sS -X PUT -d 'myvalue' http://localhost:8500/v1/kv/test_value; then
    echo -n  "[ok]"
else
  echo "[ERROR] could not set KV on server using the acl_token"
  exit 1
fi

# TODO: that test does not work due to ember - its never redirected if the client does not have js support
#echo "----------- server: cannot access ACLs using the GUI"
## this works due to our
#if docker-compose  exec server /usr/bin/curl -LsSk https://localhost:8501/ui/#/stable/acls ; then
#  echo "[ERROR] GUI seems to be open and anons can access anything"
#  exit 1
#else
#  echo -n  "[ok]"
#fi

echo "----------- agent client access using curl (and the acl_token)"
if docker-compose  exec client1 consul members; then
    echo -n "[ok]"
else
  echo "[ERROR] client1 cannot access member list using its acl_token"
  exit 1
fi


echo "----------- agent client access (acl_token)"
if docker-compose  exec client1 /usr/bin/curl -sS -X GET http://localhost:8500/v1/kv/test_value; then
    echo "\n[ok]"
else
  echo "[ERROR] client1 cannot read kv value using the acl_token"
  exit 1
fi

