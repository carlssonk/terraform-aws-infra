variable "workflow_step" {}

module "globals" {
  source = "../../globals"
}

module "generate_policy_document" {
  count          = var.workflow_step == "iam" ? 1 : 0
  source         = "./iam"
  aws_account_id = module.globals.var.AWS_ACCOUNT_ID
}

module "resources" {
  count           = var.workflow_step == "resources" ? 1 : 0
  source          = "./resources"
  aws_account_id  = module.globals.var.AWS_ACCOUNT_ID
  service_name    = var.service_name
  cluster_name    = var.service_name
  task_definition = var.task_definition
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}
