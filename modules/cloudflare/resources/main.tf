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

variable "s3_website_endpoint" {
  description = "The S3 bucket website endpoint"
}

data "cloudflare_zone" "domain" {
  name = var.root_domain
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "www"
  value   = var.s3_website_endpoint
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "@"
  value   = var.s3_website_endpoint
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
