variable "organization" {}
variable "environment" {}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "portfolio"
  is_public_website = true
  organization = var.organization
  environment = var.environment
}

output "policy_json" {
  value = module.s3.bucket_policy_json
}