locals {
  root_domain = "carlssonk.com"
  domain_name = "www.${local.root_domain}"
}

module "subdomain_bucket" {
  source      = "../../modules/s3"
  bucket_name = local.domain_name
  website_config = {
    is_website = true
  }
  bucket_access_and_policy = "cloudflare"
}

// The apex bucket will be used to redirect to the main subdomain_bucket
module "apex_bucket" {
  source      = "../../modules/s3"
  bucket_name = local.root_domain
  website_config = {
    redirect_to = local.domain_name
  }
  depends_on = [module.subdomain_bucket]
}

module "cloudflare" {
  source              = "../../modules/cloudflare"
  root_domain         = local.root_domain
  s3_website_endpoint = module.subdomain_bucket.website_endpoint
}

module "iam_policy" {
  source           = "../../iam_policy"
  name             = "portfolio"
  policy_documents = [module.subdomain_bucket.policy_document, module.apex_bucket.policy_document]
}
