output "public_ip" {
  value = "${module.instance.host.ipv4_address}"
}
