variable "workflow_step" {}

locals {
  root_domain = "carlssonk.com"
  subdomain   = "blackjack"
}

module "subdomain_bucket" {
  workflow_step = var.workflow_step
  source        = "../../modules/s3"
  bucket_name   = "${local.subdomain}.${local.root_domain}"
  website_config = {
    is_website = true
  }
  bucket_access_and_policy = "cloudflare"
}

module "cloudflare" {
  workflow_step = var.workflow_step
  source        = "../../modules/cloudflare"
  root_domain   = local.root_domain
  dns_records = [{
    name  = local.subdomain,
    value = module.subdomain_bucket.website_endpoint
  }]
}

module "iam_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "blackjack"
  policy_documents = [module.subdomain_bucket.policy_document]
}

output "policy_document" {
  value = module.iam_policy.policy_document
}
