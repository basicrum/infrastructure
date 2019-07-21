module "instance" {
  source = "../basic-rum-instance"
  instance_type = "cx11"
  ip = var.ip
  network_id = var.network_id
  name = var.subdomain
  ssh_keys = var.ssh_keys
  provision_ssh_key = var.provision_ssh_key
}

module "host" {
  source = "../cloudfront-subdomain"
  domain = "basicrum.com"
  ip_address = module.instance.host.ipv4_address
  subdomain = var.subdomain
}
