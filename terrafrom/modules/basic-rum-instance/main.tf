resource "hcloud_server" "basic-rum-host" {
  image = "ubuntu-18.04"
  name = var.name
  server_type = var.instance_type
  location = var.location
  ssh_keys = var.ssh_keys

  user_data = file("${path.root}/scripts/cloud-init.cfg")
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
    script = "${path.root}/scripts/init_docker_swarm.sh"
  }
}

resource "null_resource" "start-basic-rum-stack" {
  depends_on = [null_resource.init-docker-swarm]
  triggers = {
    docker_compose_md5 = md5(file("${path.module}/docker-compose.yml"))
    deploy_script_md5 = md5(file("${path.module}/scripts/deploy.sh"))
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
    script = "${path.module}/scripts/deploy.sh"
  }
}

resource "hcloud_server_network" "basic-rum-attach" {
  server_id = hcloud_server.basic-rum-host.id
  network_id = var.network_id
  ip = var.ip
}
