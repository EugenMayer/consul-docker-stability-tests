# WAT

Differen test to test the stability of differnt aspects with consul under a docker stack environemnt

### 1. IP changes

Since one usually do not want to have a fixed network in a docker stack, IPs can change and this can make a consul server to go banana.
With consul 0.7 or rather "raft protocol 3" a ip-change of a consul server would need a manual recovery, see the `ip-change/recovery-ip2.sh`

With consul 1.0, or rather raft 3 ( which is the default version starting with 1.0+ ) this is no longer needed and a stack would automatically recover.
This even works with only one cluster leader.


### 2. Node IDs

This test should ensure that node-ids are no longer getting in our way as with < 0.8.5 where they have been automatically
generated using the host-hardware, which leads to all the same node-ids when running on the same docker-engine and thus to issues.

### 3. ACLs

With 0.7.3+ the ACL system changed, forced with 0.9.x. The question is, how to use `gossip` and lock-down the entire instance ( no anon reads )
and have each client registerd with the server and be able to read/write KVs, register service checks