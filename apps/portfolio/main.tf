module "s3" {
  source            = "../../modules/s3"
  bucket_name       = "portfolio"
  is_public_website = true
}

module "cloudflare" {
  source              = "../../modules/cloudflare"
  domain_name         = "carlssonk.com"
  s3_website_endpoint = module.s3.bucket_regional_domain_name
}

module "iam_policy" {
  source           = "../../iam_policy"
  name             = "portfolio"
  policy_documents = [module.s3.policy_document]
}
