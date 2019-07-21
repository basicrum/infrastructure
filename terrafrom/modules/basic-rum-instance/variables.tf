variable "instance_type" {}
variable "ip" {}
variable "network_id" {}
variable "name" {}
variable "server_type" {
  default = "cx11"
}
variable "ssh_keys" {
  type = "list"
}
variable "apt_packages" {
  type = "list"
  default = ["docker.io"]
}
variable "provision_user" {
  default = "root"
}
variable "provision_ssh_key" {}
variable "connection_timeout" {
  default = "2m"
}
