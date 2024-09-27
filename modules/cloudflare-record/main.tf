terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

data "cloudflare_zone" "domain" {
  name = var.root_domain
}

resource "cloudflare_record" "dns_records" {
  for_each = var.dns_records
  zone_id  = data.cloudflare_zone.domain.id
  name     = each.value.name
  content  = each.value.value
  type     = each.value.type
  ttl      = each.value.ttl
  proxied  = each.value.proxied
}
