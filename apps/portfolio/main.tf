// s3 + cloudflare website setup guide: https://developers.cloudflare.com/support/third-party-software/others/configuring-an-amazon-web-services-static-site-to-use-cloudflare/

locals {
  app_name = "portfolio"
}

module "www_bucket" {
  source      = "../../modules/s3/default"
  bucket_name = var.domain_name
  website_config = {
    is_website = true
  }
  bucket_access_and_policy = "cloudflare"
}

module "apex_bucket" {
  source      = "../../modules/s3/default"
  bucket_name = var.root_domain
  website_config = {
    redirect_to = var.domain_name
  }
  depends_on = [module.www_bucket]
}

module "cloudflare" {
  source      = "../../modules/cloudflare/default"
  root_domain = var.root_domain
  dns_records = [
    {
      name  = "www",
      value = module.www_bucket.website_endpoint,
    },
    {
      name  = "@",
      value = module.apex_bucket.website_endpoint,
    }
  ]
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = local.app_name
  policy_documents = [
    module.www_bucket.policy_document,
    module.apex_bucket.policy_document
  ]
}
