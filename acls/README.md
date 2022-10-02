# WAT 

Production boilerplate and ACL test at the same time

## Using as your boilerplate

This setup actually suits also as a boilerplate for a production setup. You can configure the most important aspects

using those env variables you can configure if ACL/Gossip/TLS should be enabled and configured or not. Everything happens
auto-magical - see the scripts in bin/ for the components. They are fairly simple

      ENABLE_APK: 1
      ENABLE_GOSSIP: 1
      ENABLE_ACL: 1
      ENABLE_TLS: 1

`ENABLE_APK` is just for enabling the installation of `curl jq` which we need for the scripts (or you maybe did that in your image already)

## Test structure

1. We enable gossip, tls and ACLs
2. anon-users cannot read or do anything on the server
3. provide the clients with most write permissions
4See `acls/bin/server_boot.sh` for how we setup

## Access GUI

You are only able to access the GUI using `https://localhost:8501`

## Versions tests

adjust `.env` CONSUL_VERSION

## MISC

1. You should be able to cherry-pick what you need. Be it gossip or not, tls or not
2. We handle major upgrades from pre 1.2 up to 1.13 (acl reconfiguration) - it is not lossless when it comes to ACL though

## Running the test yourself

```
docker-compose up -d
# wait for about 10-20 second
./test.sh
```
