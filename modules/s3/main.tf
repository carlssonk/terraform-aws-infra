module "globals" {
  source = "${path.root}/globals"
}

locals {
  globals = module.globals.workflow_step
  workflow_step = local.globals.workflow_step
  bucket_name_full = "${local.globals.organization}-${var.bucket_name}-${terraform.workspace}"
}

module "generate_policy_document" {
  count = local.workflow_step == "iam" ? 1 : 0
  source = "./iam"
  bucket_name_full = local.bucket_name_full
  is_public_website = var.is_public_website
}

module "resources" {
  count = local.workflow_step == "resources" ? 1 : 0
  source = "./resources"
  bucket_name_full = local.bucket_name_full
  is_public_website = var.is_public_website
}

output "policy_document" {
  value = local.workflow_step == "iam" ? module.generate_policy_document[0].policy_document : null
}