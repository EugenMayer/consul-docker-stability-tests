#!/bin/bash

docker-compose down -v
docker-compose up -d
dc exec server cat /consul/config/acl_master_token.json
