data_dir = "/consul/data"
ui = true
dns_config = {
  allow_stale = false
}
node_name = "consulserver"
client_addr = "0.0.0.0"
server = true
bootstrap_expect = 1
disable_update_check = true
