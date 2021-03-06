locals {
  domain = "${cloudflare_record.basic-rum-host.name}.${var.domain}"
}

resource "hcloud_server" "catcher-host" {
  image = "ubuntu-18.04"
  name = "catcher"
  server_type = var.instance_type
  location = var.location
  ssh_keys = var.ssh_keys
  user_data = file("${path.root}/scripts/cloud-init.cfg")
}

resource "null_resource" "init-docker-swarm" {
  connection {
    host = hcloud_server.catcher-host.ipv4_address
    type = "ssh"
    user = var.provision_user
    private_key = file(var.provision_ssh_key)
    timeout = var.connection_timeout
  }

  provisioner "remote-exec" { # Initialise 1 node docker swarm
    script = "${path.root}/scripts/init_docker_swarm.sh"
  }
}

data "template_file" "docker_compose" {
  template = file("${path.module}/docker/docker-compose.yml")
  vars = {
    DOMAIN = local.domain
    HOST_IP = hcloud_server.catcher-host.ipv4_address
    LETSENCRYPT_EMAIL = var.letsencrypt_email
  }
}

resource "null_resource" "start-catcher" {
  depends_on = [null_resource.init-docker-swarm]
  triggers = {
    docker_compose_md5 = md5(data.template_file.docker_compose.rendered)
  }
  connection {
    host = hcloud_server.catcher-host.ipv4_address
    type = "ssh"
    user = var.provision_user
    private_key = file(var.provision_ssh_key)
    timeout = var.connection_timeout
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.docker/services/catcher"
    ]
  }

  provisioner "file" {
    content = data.template_file.docker_compose.rendered
    destination = "~/.docker/services/catcher/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker stack deploy -c ~/.docker/services/catcher/docker-compose.yml catcher"
    ]
  }
}

resource "hcloud_server_network" "basic-rum-attach" {
  server_id = hcloud_server.catcher-host.id
  network_id = var.network_id
  ip = var.local_ip
}

resource "cloudflare_record" "basic-rum-host" {
  domain = var.domain
  name = "catcher"
  type = "A"
  value = hcloud_server.catcher-host.ipv4_address
  ttl = 1
  proxied = false
}
