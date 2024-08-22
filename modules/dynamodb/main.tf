module "globals" {
  source = "../../globals"
}

locals {
  workflow_step = module.globals.var.workflow_step
  table_name_full = "${module.globals.var.organization}-${var.table_name}-${terraform.workspace}"
}

module "generate_policy_document" {
  count = workflow_step == "iam" ? 1 : 0
  source = "./iam"
  table_name_full = local.table_name_full
}

module "resources" {
  count = workflow_step == "resources" ? 1 : 0
  source = "./resources"
  table_name_full = local.table_name_full
}

output "policy_document" {
  value = local.workflow_step == "iam" ? module.generate_policy_document[0].policy_document : null
}