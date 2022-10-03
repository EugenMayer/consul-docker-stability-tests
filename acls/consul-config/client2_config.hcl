node_name = "test-client2"
datacenter = "stable"
disable_remote_exec = true
server = false
data_dir = "/consul/data"
auto_reload_config=true
ui = false
dns_config = {
  allow_stale = false
}
addresses = {
  http = "127.0.0.1"
}
retry_join = ["server"]
disable_update_check = true
