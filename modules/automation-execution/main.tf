variable "workflow_step" {}

module "globals" {
  source = "../../globals"
}

locals {
  document_name = "TroubleshootECSTaskFailedToStart-Wrapper"
}

module "generate_policy_document" {
  count          = var.workflow_step == "iam" ? 1 : 0
  source         = "./iam"
  aws_account_id = module.globals.var.AWS_ACCOUNT_ID
  document_name  = local.document_name
}

module "resources" {
  count               = var.workflow_step == "resources" ? 1 : 0
  source              = "./resources"
  aws_account_id      = module.globals.var.AWS_ACCOUNT_ID
  service_name        = var.service_name
  cluster_name        = var.cluster_name
  task_definition_arn = var.task_definition_arn
  document_name       = local.document_name
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}
