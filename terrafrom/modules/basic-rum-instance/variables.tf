variable "instance_type" {}
variable "ip" {}
variable "location" {}
variable "network_id" {}
variable "name" {}
variable "ssh_keys" {
  type = "list"
}
variable "provision_user" {
  default = "root"
}
variable "provision_ssh_key" {}
variable "connection_timeout" {
  default = "2m"
}
variable "letsencrypt_email" {}
variable "domain" {}
