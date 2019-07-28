output "public_ip" {
  value = hcloud_server.rundeck-host.ipv4_address
}
