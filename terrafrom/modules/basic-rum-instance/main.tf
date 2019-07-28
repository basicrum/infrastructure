resource "hcloud_server" "basic-rum-host" {
  image = "ubuntu-18.04"
  name = var.name
  server_type = var.server_type
  location = "nbg1"
  ssh_keys = var.ssh_keys

  user_data = <<EOF
#!/usr/bin/env bash
while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done;
apt-get update;
apt-get install -yq ufw ${join(" ", var.apt_packages)}
EOF


}
resource "null_resource" "init-docker-swarm" {
  connection {
    host = hcloud_server.basic-rum-host.ipv4_address
    type = "ssh"
    user = var.provision_user
    private_key = file(var.provision_ssh_key)
    timeout = var.connection_timeout
  }

  provisioner "remote-exec" { # Initialise 1 node docker swarm
    script = "${path.module}/scripts/init_docker_swarm.sh"
  }
}

resource "null_resource" "start-basic-rum-stack" {
  depends_on = [null_resource.init-docker-swarm]
  triggers = {
    docker_compose_md5 = md5(file("${path.module}/docker-compose.yml"))
  }

  connection {
    host = hcloud_server.basic-rum-host.ipv4_address
    type        = "ssh"
    user        = var.provision_user
    private_key = file(var.provision_ssh_key)
    timeout     = var.connection_timeout
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.docker/services"
    ]
  }

  provisioner "file" {
    source = "${path.module}/docker-compose.yml"
    destination = "~/.docker/services/basic-rum.yml"
  }

  # start stack
  provisioner "remote-exec" {
    inline = [
      "docker stack deploy -c ~/.docker/services/basic-rum.yml --prune basic-rum"
    ]
  }
}

resource "hcloud_server_network" "basic-rum-attach" {
  server_id = hcloud_server.basic-rum-host.id
  network_id = var.network_id
  ip = var.ip
}
