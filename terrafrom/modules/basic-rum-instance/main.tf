resource "hcloud_server" "basic-rum-host" {
  image = "ubuntu-18.04"
  name = "${var.name}"
  server_type = "${var.server_type}"
  location = "nbg1"
  ssh_keys = var.ssh_keys

  user_data = <<EOF
#!/usr/bin/env bash
while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done;
apt-get update;
apt-get install -yq ufw ${join(" ", var.apt_packages)}
EOF


}
resource "null_resource" "start-nginx-container" {
  connection {
    host = "${hcloud_server.basic-rum-host.ipv4_address}"
    type        = "ssh"
    user        = "${var.provision_user}"
    private_key = "${file("${var.provision_ssh_key}")}"
    timeout     = "${var.connection_timeout}"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ -z \"$(docker info | grep CPUs)\" ]; do echo 'Waiting for Docker to start...' && sleep 2;done",
      "docker pull basicrum/nginx:test",
      "docker rm -f $(docker ps -q)",
      "docker run -d -p 80:80 --restart=always basicrum/nginx:test"
    ]
  }
}

resource "hcloud_server_network" "basic-rum-attach" {
  server_id = "${hcloud_server.basic-rum-host.id}"
  network_id = "${var.network_id}"
  ip = var.ip
}
