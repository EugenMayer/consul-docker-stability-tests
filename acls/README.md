# 1.0

With 0.7.3+ the ACL system changed, forced with 0.9.x. The question is, how to use `gossip` and lock-down the entire instance ( no anon reads )
and have each client registerd with the server and be able to read/write KVs, register service checks

## Test

1. Configure `acl_master_token` for the server, createa an acl_token for the `agent clients` and a ACL defintion for the client tokens / and a no-read for anons 
2. ensure we can register services, write KVs and have health checks
