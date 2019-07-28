output "host_ip" {
  value = module.basic-rum-app-test-1.public_ip
}

output "rundeck_ip" {
  value = module.rundeck.public_ip
}
