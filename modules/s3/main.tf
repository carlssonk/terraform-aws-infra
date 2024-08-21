variable "is_bootstrap_user" { 
  default = false
}

module "globals" {
  source = "../../global_constants"
}

module "iam" {
  count = var.is_bootstrap_user ? 0 : 1 // Bootstrap has its own iam policy
  source = "./iam"
}

resource "time_sleep" "wait_15_seconds" {
  depends_on = [module.iam]
  create_duration = "15s"
}

module "resources" {
  source = "./resources"
  bucket_name_full = "${module.globals.organization}-${var.bucket_name}-${terraform.workspace}"
  is_public_website = var.is_public_website
  depends_on = [time_sleep.wait_15_seconds]
}
