module "globals" {
  source = "../../globals"
}

locals {
  table_name_full = "${module.globals.var.organization}-${var.table_name}-${terraform.workspace}"
}

module "generate_policy_document" {
  count           = module.globals.run_iam
  source          = "./iam"
  table_name_full = local.table_name_full
}

module "resources" {
  count           = module.globals.run_resources
  source          = "./resources"
  table_name_full = local.table_name_full
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}
