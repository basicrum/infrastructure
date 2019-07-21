resource "cloudflare_record" "basic-rum-host" {
  domain = "${var.domain}"
  name = "${var.subdomain}"
  type = "A"
  value = "${var.ip_address}"
  ttl = 1
  proxied = true
}
