variable "domain_name" {
  description = "The domain name to route to the S3 bucket"
  type        = string
}

variable "s3_website_endpoint" {
  description = "The S3 bucket website endpoint"
  type        = string
}

variable "domain_zone_id" {
  description = "Zone ID for domain name"
  type        = string
}

module "globals" {
  source = "../../../globals"
}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = module.globals.var.cloudflare_api_token
}

resource "cloudflare_record" "www_cname" {
  zone_id = var.domain_zone_id
  name    = var.domain_name
  value   = var.s3_website_endpoint
  type    = "CNAME"
  ttl     = 3600
  proxied = true
}
