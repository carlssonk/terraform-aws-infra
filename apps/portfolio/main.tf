module "globals" {
  source = "${path.root}/globals"
}

module "create_bucket" {
  source = "../../modules/s3"
  bucket_name = "portfolio"
  is_public_website = true
}

module "create_policy" {
  count = module.globals.workflow_step == "iam" ? 1 : 0
  source = "../../modules/iam"
  name = "portfolio"
  policy_documents = [module.create_bucket.policy_document]
}