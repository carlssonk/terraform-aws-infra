module "bucket" {
  source      = "../../modules/s3"
  bucket_name = var.bucket_name
  bucket_policy = {
    name = "cloudflare"
    permissions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
  }
  block_public_policy = false
}

module "cloudflare" {
  source      = "../../modules/cloudflare-record"
  root_domain = var.root_domain
  dns_records = {
    "${var.subdomain}_record" = {
      name  = var.subdomain
      value = module.bucket.bucket_regional_domain_name
    }
  }
}
