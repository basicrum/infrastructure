variable "local_ip" {}
variable "network_id" {}
variable "location" {}
variable "ssh_keys" {
  type = "list"
}
variable "subdomain" {}
variable "provision_ssh_key" {}

variable "domain" {}
variable "instance_type" {}

variable "letsencrypt_email" {}
