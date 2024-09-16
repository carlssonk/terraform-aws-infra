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
  count   = length(var.dns_records)
  zone_id = data.cloudflare_zone.domain.id
  name    = var.dns_records[count.index].name
  content = var.dns_records[count.index].value
  type    = var.dns_records[count.index].type
  ttl     = var.dns_records[count.index].ttl
  proxied = var.dns_records[count.index].proxied
}
