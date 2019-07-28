# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  email = var.cloudflare_email
  token = var.cloudflare_token
}


locals {
  registry_ip = "10.0.1.5"
  instance_count = 1
  instance_type = "cx11"
  rundeck_instance_type = "cx21"
}

resource "hcloud_network" "privNet" {
  name = "basic-rum-saas"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "shared-services" {
  network_id = hcloud_network.privNet.id
  type = "server"
  network_zone = "eu-central"
  ip_range = "10.0.1.0/24"
}

resource "hcloud_network_subnet" "basic-rum-instances" {
  network_id = hcloud_network.privNet.id
  type = "server"
  network_zone = "eu-central"
  ip_range = "10.0.2.0/24"
}


resource "hcloud_ssh_key" "eliskovets" {
  name = "eliskovets"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuhvuGRwFAxaZSr1LEOUGKPZH5+Nd0DD5Fdt1N0glwH4xkpzT9ESIYb44cJEPmixY1t2dVEk50k3FCtpg0ZaqYFrwY0VsLt9iKhYFNeXECNcWkTi0SX6UmCv/k2reiltGiEw2uS8kNR14AHmd/65JU401qOIUQqILPQ9LP21i8AqwvC+ZD7gNAbPHYMdc7vmivX/qa/MrMWGjflaYBNxJ7Q88QcVTEPJysUz8wKtKCNe8LTI1YVhlGSjPUaTTXIrJ8gcLbhqV/mM/GY3x4DM5pf5zIjnPlntDXolE7xeXYfioDUGSbJzHcX1UeYZmO6p6oLF4pTa+io736tRzGB4Z1 eugene.liskovets@gmail.com"
}

resource "hcloud_ssh_key" "tstoychev" {
  name = "tstoychev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgj17jXLNnThacFnWhNBKcJF5aYh+ihg2BQK5VfvYT0j14tTKP/OYkgb7VWDk68Z/O6OE9C/FzImfzrJA0KO7LJa66X/Dm7puDaO9XYrURxZ7UgyxGftBrK7C9WzOlJPnTVAa9NqCfmsgU7niU28dRMRCFPMxaED4VKx3Bm7rCisoQFiM4EaQRAKU4y2D0X+yELq+jQQbnFlRuVFFZ5aQXo6vKyzNPFlDXDGi6Z3Ba84XrXc2vvkgJO569+KUSNekj0gHUnvXaOSwWKnAlz86b9yeaXuCpWtBn/0E9hG/eH8hdwYHjuLT10MXtEMxLUtFiTS4NWBHI01yp6fodvHPKw7t9zq0sB3Egvbmlva0lJwgPYdM5PXHvk/gJJJd1SUxbSF/qhgPG2LoKc3rDqmAy4/M5E9pX7zURb5U+6Vlw6P+uVr6k6v7hf1YfcLcQvNh5UkDSR5pRtQPVP9/r2VDPF9g8ssL98VkAfTmFZrFXH/qLBPL6ud12mIkbtF9VRrLcRy+jMpDto1fiskPv05Aeq0qJRf3tgirs0fbxQ+DarFm+xk6wdaTl4EXLF7g+P57+CnGNgopF5BJ/h1iqHW9AjLH+EbtAN5wlSH4sanl1JyRh733sCvg3jWD3QDpw4utrCbgOj3R62WEJxTXu3MDQSwxP45VxqUK7SyhzN0fd9w== ceckoslab@gmail.com"
}

module "basic-rum-app-test-1" {
  source = "./modules/basic-rum-app"
  local_ip = "${cidrhost(hcloud_network_subnet.basic-rum-instances.ip_range, 1)}"
  network_id = hcloud_network.privNet.id
  subdomain = "test-1"
  ssh_keys = [
    hcloud_ssh_key.tstoychev.id,
    hcloud_ssh_key.eliskovets.id
  ]

  provision_ssh_key = var.provision_ssh_key
  domain = var.domain
  instance_type = local.instance_type
}

module "rundeck" {
  source = "./modules/rundeck"
  local_ip = "${cidrhost(hcloud_network_subnet.basic-rum-instances.ip_range, 254)}"
  network_id = hcloud_network.privNet.id
  ssh_keys = [
    hcloud_ssh_key.tstoychev.id,
    hcloud_ssh_key.eliskovets.id
  ]

  provision_ssh_key = var.provision_ssh_key
  instance_type = local.rundeck_instance_type
  domain = var.domain
  admin_password = var.rundeck_admin_pass
  user_password = var.rundeck_user_pass
}
