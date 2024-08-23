module "s3" {
  source            = "../../modules/s3"
  bucket_name       = "portfolio"
  is_public_website = true
}

module "cloudflare" {
  source              = "../../modules/cloudflare"
  domain_name         = "carlssonk.com"
  s3_website_endpoint = module.s3.website_endpoint
  domain_zone_id      = "5b869b9d7f7b447b870967d819ec76dd"
}

module "iam_policy" {
  source           = "../../iam_policy"
  name             = "portfolio"
  policy_documents = [module.s3.policy_document]
}
