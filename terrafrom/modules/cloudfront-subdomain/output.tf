output "domain" {
  value = "${cloudflare_record.basic-rum-host.name}.${cloudflare_record.basic-rum-host.domain}"
}
