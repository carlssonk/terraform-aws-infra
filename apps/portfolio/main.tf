variable "workflow_step" {}

locals {
  root_domain = "carlssonk.com"
  domain_name = "www.${local.root_domain}"
}

module "test_bucket" {
  workflow_step = var.workflow_step
  source        = "../../modules/s3"
  bucket_name   = "carlssonk-test123-bucket"
}

// s3 + cloudflare website setup guide: https://developers.cloudflare.com/support/third-party-software/others/configuring-an-amazon-web-services-static-site-to-use-cloudflare/

module "subdomain_bucket" {
  workflow_step = var.workflow_step
  source        = "../../modules/s3"
  bucket_name   = local.domain_name
  website_config = {
    is_website = true
  }
  bucket_access_and_policy = "cloudflare"
}

module "apex_bucket" {
  workflow_step = var.workflow_step
  source        = "../../modules/s3"
  bucket_name   = local.root_domain
  website_config = {
    redirect_to = local.domain_name
  }
  depends_on = [module.subdomain_bucket]
}

module "cloudflare" {
  workflow_step         = var.workflow_step
  source                = "../../modules/cloudflare"
  root_domain           = local.root_domain
  s3_subdomain_endpoint = module.subdomain_bucket.website_endpoint
  s3_apex_endpoint      = module.apex_bucket.website_endpoint
}

module "iam_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "portfolio"
  policy_documents = [module.subdomain_bucket.policy_document, module.apex_bucket.policy_document, module.test_bucket.policy_document]
}

output "policy_document" {
  value = module.iam_policy.policy_document
}
