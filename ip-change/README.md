# 0.7 

## Test

We start the stack using consul wiht IP1 and then, taking it down to start the same stack ( persisted consul data ) using a different IP.
We therefor provoke the only consul-leader in the cluster to lose his leadership because during startup. Reason is, that it thinks, there was a 
different leader (different IP) beforehand, with the IP2 - and since the new server has IP2 it thinks its split or not the leader - disabling the stack

## recovery

As per docs https://www.consul.io/docs/guides/outage.html we need to create a peers.json which includes only one entry, the IP2 server
We do this here for raft2, so jus the ip

    ["10.50.50.50:8300"]
    
**IMPORTANT**: you _have_ to add the port, or it will silently fail.    
    
Then we restart the consul server then and since the "peers" available are overriden, the old IP1 leader has been removed. Thus, since we use `bootstrap=1`
as config ( cluster with one server only ) the server becomes leader again.

During that process, no data or KVs are lost.

# 1.0+

With 1.0 the raft protocol changed to 3 by default and due to the autopilot it should auto-recover after ip changes.
This is the reason why we are not using recovery-ip2.sh when testing 1.0 and still - it works. Not using the peers.json trick (recovery-ip2.sh) would have broken 0.7 though.
   
## recovery

Happens automatically due to autopilot, nothing needs to be done   
