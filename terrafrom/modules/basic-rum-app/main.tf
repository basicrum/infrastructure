module "instance" {
  source = "../basic-rum-instance"
  instance_type = var.instance_type
  ip = var.local_ip
  network_id = var.network_id
  name = var.subdomain
  ssh_keys = var.ssh_keys
  provision_ssh_key = var.provision_ssh_key
  location = var.location
}

module "host" {
  source = "../cloudfront-subdomain"
  domain = var.domain
  ip_address = module.instance.host.ipv4_address
  subdomain = var.subdomain
}
