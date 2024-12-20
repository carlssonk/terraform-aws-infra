

locals {
  domain_name = "${var.subdomain}.${var.root_domain}"
}

module "subdomain_bucket" {
  source      = "../../modules/s3"
  bucket_name = local.domain_name
  website_config = {
    is_website = true
  }
  bucket_policy = {
    name        = "cloudflare"
    permissions = ["s3:GetObject"]
  }
  is_public = true
}

module "root_bucket" {
  count       = var.subdomain == "www" ? 1 : 0
  source      = "../../modules/s3"
  bucket_name = var.root_domain
  website_config = {
    redirect_to = local.domain_name
  }
  depends_on = [module.subdomain_bucket]
}

module "cloudflare" {
  source      = "../../modules/cloudflare-record"
  root_domain = var.root_domain
  dns_records = merge(
    {
      "${var.app_name}_subdomain_record" = {
        name  = var.subdomain
        value = module.subdomain_bucket.website_endpoint
      }
    },
    var.subdomain == "www" ? {
      "${var.app_name}_root_record" = {
        name  = "@"
        value = module.root_bucket[0].website_endpoint
      }
    } : {}
  )
}
