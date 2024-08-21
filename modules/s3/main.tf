module "globals" {
  source = "../../global_constants"
}

locals {
  bucket_name_full = "${module.globals.organization}-${var.bucket_name}-${terraform.workspace}"
}

module "iam" {
  source = "./iam"

  bucket_name_full = local.bucket_name_full
  is_public_website = var.is_public_website
}

resource "time_sleep" "wait_for_iam" {
  create_duration = "15s"
}

module "resources" {
  source = "./resources"
  depends_on = [time_sleep.wait_for_iam]

  bucket_name_full = local.bucket_name_full
  is_public_website = var.is_public_website
}

output "policy_document" {
  value = module.iam.policy_document
}