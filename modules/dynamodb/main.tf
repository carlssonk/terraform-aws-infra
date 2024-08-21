module "globals" {
  source = "../../global_constants"
}

locals {
  table_name_full = "${module.globals.organization}-${var.table_name}-${terraform.workspace}"
}

module "iam" {
  source = "./iam"

  table_name_full = local.table_name_full
}

resource "time_sleep" "wait_15_seconds" {
  depends_on = [module.iam]
  create_duration = "15s"
}

module "resources" {
  source = "./resources"
  depends_on = [time_sleep.wait_15_seconds]

  table_name_full = local.table_name_full
}
