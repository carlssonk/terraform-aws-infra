// Subdomain website setup

locals {
  app_name    = "terraform_diagram"
  subdomain   = "terraform"
  root_domain = "carlssonk.com"
  domain_name = "${local.subdomain}.${local.root_domain}"
}

module "bucket" {
  source      = "../../modules/s3/default"
  bucket_name = local.domain_name
  website_config = {
    is_website = true
  }
  bucket_access_and_policy = "cloudflare"
}

module "cloudflare" {
  source      = "../../modules/cloudflare-record/default"
  root_domain = local.root_domain
  dns_records = [{
    name  = local.subdomain
    value = module.bucket.website_endpoint
  }]
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = local.app_name
  policy_documents = [
    module.bucket.policy_document
  ]
}
