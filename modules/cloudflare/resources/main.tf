terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

variable "root_domain" {
  description = "The root domain name to route to the S3 bucket"
}

variable "dns_records" {
  description = "List of DNS records to create"
}

variable "zone_settings" {
  description = "Settings for the Cloudflare zone"
}

data "cloudflare_zone" "domain" {
  name = var.root_domain
}

resource "cloudflare_zone_settings_override" "websocket_support" {
  zone_id = data.cloudflare_zone.domain.id
  settings {
    websockets = var.zone_settings.websockets
    ssl        = var.zone_settings.ssl
  }
}

resource "cloudflare_record" "dns_records" {
  count   = length(var.dns_records)
  zone_id = data.cloudflare_zone.domain.id
  name    = var.dns_records[count.index].name
  content = var.dns_records[count.index].value
  type    = var.dns_records[count.index].type
  ttl     = 1
  proxied = true
}
