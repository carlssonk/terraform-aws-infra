module "globals" {
  source = "../../global_variables"
}

module "iam" {
  source = "./iam"
}

resource "time_sleep" "wait_5_seconds" {
  depends_on = [module.iam]
  create_duration = "5s"
}

module "resources" {
  source = "./resources"
  bucket_name_full = "${module.globals.organization}-${var.bucket_name}-${terraform.workspace}"
  is_public_website = var.is_public_website
  depends_on = [time_sleep.wait_5_seconds]
}
