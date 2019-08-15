variable "local_ip" {}
variable "network_id" {}
variable "ssh_keys" {
  type = "list"
}
variable "provision_ssh_key" {}
variable "instance_type" {}

variable "apt_packages" {
  type = "list"
  default = ["docker.io"]
}


variable "provision_user" {
  default = "root"
}
variable "connection_timeout" {
  default = "2m"
}

variable "domain" {}
