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

output "policy_document" {
  value = module.iam.policy_document
}

resource "time_sleep" "wait_for_iam" {
  create_duration = "15s"
}

module "resources" {
  source = "./resources"
  depends_on = [time_sleep.wait_for_iam]

  table_name_full = local.table_name_full
}