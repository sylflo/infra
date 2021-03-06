# Configure the Cloudflare provider.
# You may optionally use version directive to prevent breaking changes occurring unannounced.
provider "cloudflare" {
  email   = var.email
  api_key = var.api_token
}

resource "cloudflare_zone" "main" {
  zone = var.domain_name
}

resource "cloudflare_record" "public" {
  count   = length(var.public_records)

  zone_id = cloudflare_zone.main.id
  name    = var.public_records[count.index].name
  value   = var.public_records[count.index].ip_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "private" {
  count   = length(var.private_records)

  zone_id = cloudflare_zone.main.id
  name    = var.private_records[count.index].name
  value   = var.private_records[count.index].ip_address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "resume" {
  zone_id = cloudflare_zone.main.id

  name = "resume.${var.domain_name}"
  type = "CNAME"
  ttl = "1"
  proxied = true

  value = "${split(".", var.domain_name)[0]}.netlify.app"
}