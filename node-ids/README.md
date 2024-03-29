# 1.0

This test should ensure that node-ids are no longer getting in our way as with < 0.8.5 where they have been automatically
generated using the host-hardware, which leads to all the same node-ids when running on the same docker-engine and thus to issues.
With 0.8.5+ this behavior is no longer the default (but needs a opt-in), node-ids are generated and stored in the client data folder

## Test

1. We test if that actually happens when we re-create a client with the same name
2. Test what happens if we do not persist the client storage, thus a node-id is generated every start

## Result with 1.0.7

It seems like not persisting the `agent client` data directories does actually not harm in docker-envs since 
it seems like the nodes are de-registered automatically when the node is removed / stopped thus no orphaned nodes
exists when we shutdown client1 (and it de-register) and then starts again with a new node-id. 
This is part of the docs https://www.consul.io/docs/agent/options.html#leave_on_terminate where clients are always auto-leaving on shutdown, so that's expected.
