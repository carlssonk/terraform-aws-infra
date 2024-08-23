variable "domain_name" {
  description = "The domain name to route to the S3 bucket"
  type        = string
}

variable "s3_website_endpoint" {
  description = "The S3 bucket website endpoint"
  type        = string
}

data "cloudflare_zones" "domain_zone" {
  filter {
    name = var.domain_name
  }
}

resource "cloudflare_record" "www_cname" {
  zone_id = data.cloudflare_zones.domain_zone.zones[0].id
  name    = ar.domain_name
  value   = var.s3_website_endpoint
  type    = "CNAME"
  ttl     = 3600
  proxied = true
}
