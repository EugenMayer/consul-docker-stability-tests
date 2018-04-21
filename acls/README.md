# 1.0

With 0.7.3+ the ACL system changed, forced with 0.9.x. The question is, how to use `gossip` and lock-down the entire instance ( no anon reads )
and have each client registerd with the server and be able to read/write KVs, register service checks

This stack is designed to be **production ready**. So locked down, encrypted and secured as much as sanity allows here

## Test

1. Configure `acl_master_token` for the server
2. Setup ACLs an even lockdown anon access
3. createa an acl_token for the `agent clients` with a ACL policy to let htem access what we usually need ( events, nodes, services, kv)
4. configure `gossip` for encrypyion 
5. setup `tls` for `https` based communication. Also lock down the servers `8500` http port for out communucations, only allow it for localhost. Enforce the https port on `8501`
6. start `agents clients` with all the secrets as soon as the secrets are there

## Access GUI

You are only able to access the GUI using `https://localhost:8501`

## Versions tests

adjust `.env` CONSUL_VERSION

## MISC

1. we ar eusing wait-for-it to remove arbitrary sleeps, see https://github.com/vishnubob/wait-for-it
2. You should be able to cherry-pick what you need. Be it gossip or not, tls or not