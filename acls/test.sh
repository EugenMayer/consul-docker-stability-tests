#!/bin/bash

echo "----------- server: raft version"
if docker-compose  exec server consul info | grep 'acl = enabled'; then
  echo "[ok] acl is enabled"
else
  echo "[ERROR] acl is not enabled"
  exit 1
fi

echo "----------- server: raft version"
if docker-compose  exec server consul info | grep -a20 raft | grep 'protocol_version = 3'; then
  echo "[ok] raft is v3"
else
  echo "[ERROR] raft is not version 3"
  exit 1
fi

echo "----------- server: encryption / gossip status"
if docker-compose  exec server consul info | grep encrypted; then
  echo "[ok] gossip encryption activated"
else
  echo "[ERROR] encryption not activated"
  exit 1
fi

echo "----------- server: server has access"
if docker-compose  exec server consul members; then
  echo "[ok]"
else
  echo "[ERROR] cannot query members using servers acl_token"
  exit 1
fi

echo "----------- anon access on server without token - member list should be empty"
docker-compose exec server consul members -token=anonymous

if docker-compose  exec server consul members | grep encrypted; then
  echo "[ERROR] list not empty - anon can access list"
  exit 1
else
  echo "[ok]"
fi

echo "----------- server: writing KV value"
# this works due to our default token on the server
if docker-compose  exec server consul kv put mykey myvalue; then
    echo -n  "[ok]"
else
  echo "[ERROR] could not set KV on server using the acl_token"
  exit 1
fi

echo "----------- server: reading KV value"
if docker-compose  exec server consul kv get mykey; then
    echo -n  "[ok]"
else
  echo "[ERROR] could not get KV on server using the acl_token"
  exit 1
fi

echo "----------- GUI: cannot access ACLs using the GUI"
# this works due to our
if curl -LsfSk https://localhost:8501/v1/acl/tokens?dc=stable ; then
  echo "[ERROR] GUI seems to be open and anons can access anything"
  exit 1
else
  echo -n  "[ok]"
fi

echo "----------- client: encryption / gossip status"
if docker-compose  exec client1 consul info| grep encrypted; then
  echo "[ok] gossip encryption activated"
else
  echo "[ERROR] encryption not activated"
  exit 1
fi

echo "----------- client: can access member list"
if docker-compose  exec client1 consul members; then
    echo -n "[ok]"
else
  echo "[ERROR] client1 cannot access member list using its acl_token"
  exit 1
fi

echo "----------- client: can access KV read (acl_token)"
if docker-compose  exec client1 consul kv get mykey; then
    echo -n "[ok]"
else
  echo "[ERROR] client1 cannot read kv value using the acl_token"
  exit 1
fi

