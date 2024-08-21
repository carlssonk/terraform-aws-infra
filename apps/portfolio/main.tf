module "s3" {
  source = "../../modules/s3"
  bucket_name = "portfolio"
  is_public_website = true
}

module "s3_2" {
  source = "../../modules/s3"
  bucket_name = "portfolio-2"
  is_public_website = true
}

module "iam" {
  source = "../../modules/iam"
  name = "portfolio"
  policy_documents = [module.s3.policy_document, module.s3_2.policy_document]
}