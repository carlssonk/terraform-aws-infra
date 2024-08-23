module "globals" {
  source = "../../globals"
}

locals {
  bucket_name_full = "${module.globals.var.organization}-${var.bucket_name}-${terraform.workspace}"
}

module "generate_policy_document" {
  count             = module.globals.run_iam
  source            = "./iam"
  bucket_name_full  = local.bucket_name_full
  is_public_website = var.is_public_website
}

module "resources" {
  count             = module.globals.run_resources
  source            = "./resources"
  bucket_name_full  = local.bucket_name_full
  is_public_website = var.is_public_website
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "website_endpoint" {
  value = try(module.resources[0].website_endpoint, null)
}
