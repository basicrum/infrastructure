resource "hcloud_server" "rundeck-host" {
  image = "ubuntu-18.04"
  name = "rundeck"
  server_type = var.instance_type
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
    host = hcloud_server.rundeck-host.ipv4_address
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
    DOMAIN = var.domain
    HOST_IP = hcloud_server.rundeck-host.ipv4_address
  }
}

data "template_file" "realm_properties" {
  template = file("${path.module}/docker/realm.properties")
  vars = {
    ADMIN_PASS = var.admin_password
    USER_PASS = var.user_password
  }
}

resource "null_resource" "start-rundeck" {
  depends_on = [null_resource.init-docker-swarm]
  triggers = {
    docker_compose_md5 = md5(file("${path.module}/docker/docker-compose.yml"))
    realm_properties_md5 = md5(file("${path.module}/docker/realm.properties"))
  }
  connection {
    host = hcloud_server.rundeck-host.ipv4_address
    type = "ssh"
    user = var.provision_user
    private_key = file(var.provision_ssh_key)
    timeout = var.connection_timeout
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.docker/services/rundeck"
    ]
  }

  provisioner "file" {
    content = data.template_file.docker_compose.rendered
    destination = "~/.docker/services/rundeck/docker-compose.yml"
  }

  provisioner "file" {
    content = data.template_file.realm_properties.rendered
    destination = "~/.docker/services/rundeck/realm.properties"
  }

  provisioner "remote-exec" {
    inline = [
      "docker stack deploy -c ~/.docker/services/rundeck/docker-compose.yml rundeck"
    ]
  }
}

resource "cloudflare_record" "basic-rum-host" {
  domain = var.domain
  name = "rundeck"
  type = "A"
  value = hcloud_server.rundeck-host.ipv4_address
  ttl = 1
  proxied = true
}
