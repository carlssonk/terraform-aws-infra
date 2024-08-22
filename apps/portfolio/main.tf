module "create_bucket" {
  source = "../../modules/s3"
  bucket_name = "portfolio"
  is_public_website = true
}

module "create_policy" {
  source = "../../modules/iam"
  name = "portfolio"
  policy_documents = [module.create_bucket.policy_document]
}