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

`ENABLE_APK` is just for enabling the installation of `curl jq` which we need for the scripts ( or you maybe did that in your image already
)

## issues

 - https://github.com/hashicorp/consul/issues/4056
 
## migration from 0.7 to 1.x 

With 0.7.3+ the ACL system changed, forced with 0.9.x. The question is, how to use `gossip` and lock-down the entire instance ( no anon reads )
and have each client registerd with the server and be able to read/write KVs, register service checks

This stack is designed to be **production ready**. So locked down, encrypted and secured as much as sanity allows here

## Test structure

1. Configure `acl_master_token` for the server
2. Setup ACLs an even lock down `anon access` entirely
3. createa an acl_token for the `agent clients` with a ACL policy to let them access what we usually need ( events, nodes, services, kv)
4. configure `gossip` for encrypyion 
5. setup `tls` for `https` based communication including the deployment of the `CA` on the server. Also lock down the servers `8500` http port for outer communucations, only allow it for localhost. Enforce the https port on `8501`
6. start `agents clients` with all the secrets as soon as the secrets are there using `.boostrapped`

## Access GUI

You are only able to access the GUI using `https://localhost:8501`

## Versions tests

adjust `.env` CONSUL_VERSION

## MISC

1. we ar eusing wait-for-it to remove arbitrary sleeps, see https://github.com/vishnubob/wait-for-it
2. You should be able to cherry-pick what you need. Be it gossip or not, tls or not

## Running the test yourself

```
docker-compose up -d
# wait for about 10 second
./test.sh
```