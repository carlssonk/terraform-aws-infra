data "local_file" "globals" {
  filename = "${path.root}/globals.json"
}

locals {
  globals = jsondecode(data.local_file.globals.content)
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
  value = module.generate_policy_document.policy_document
}