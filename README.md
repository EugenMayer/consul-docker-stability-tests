# WAT

Different test to test the stability of different aspects with consul under a docker stack environment.

The ACL variant can also be used as a production full-auto configuration startup. It supports gossip, TLS and ACLs to make the
setup zero-trust compliant.

### 1. IP changes

Since one usually do not want to have a fixed network in a docker stack, IPs can change and this can make a consul server to go banana.
With consul 0.7 or rather "raft protocol 3" a ip-change of a consul server would need a manual recovery, see the `ip-change/recovery-ip2.sh`

With consul 1.0, or rather raft 3 (which is the default version starting with 1.0+) this is no longer needed and a stack would automatically recover.
This even works with only one cluster leader.

Ensures this up to 1.13.

### 2. Node IDs

This test should ensure that node-ids are no longer getting in our way as with < 0.8.5 where they have been automatically
generated using the host-hardware (host-id was on by default), which leads to all the same node-ids when running on the same docker-engine and thus to issues.

Starting with 0.9+ host-id is off by default, so the node-ids are unique for every docker-container started.

### 3. ACLs

With 0.7.3+ the ACL system changed, forced with 0.9.x. With 1.6 and 1.13 the ACL system has been changed once again.
Ensure the configuration can still secure the communication and the access as expected. Also ensure a transition to the newer versions.
