variable "is_bootstrap_user" { 
  default = false
}

module "globals" {
  source = "../../global_constants"
}

locals {
  bucket_name_full = "${module.globals.organization}-${var.bucket_name}-${terraform.workspace}"
}

module "iam" {
  count = var.is_bootstrap_user ? 0 : 1 // Bootstrap has its own iam policy
  source = "./iam"

  bucket_name_full = local.bucket_name_full
  is_public_website = var.is_public_website
}

resource "time_sleep" "wait_15_seconds" {
  count = var.is_bootstrap_user ? 0 : 1
  depends_on = [module.iam]
  create_duration = "15s"
}

module "resources" {
  source = "./resources"
  depends_on = [time_sleep.wait_15_seconds]

  bucket_name_full = local.bucket_name_full
  is_public_website = var.is_public_website
}
