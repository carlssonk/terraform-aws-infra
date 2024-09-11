variable "workflow_step" {}

module "globals" {
  source = "../../globals"
}

resource "random_id" "document_suffix" {
  byte_length = 8
}

locals {
  document_name = "TroubleshootECSTaskFailedToStart-${random_id.document_suffix.hex}"
}

module "generate_policy_document" {
  count          = var.workflow_step == "iam" ? 1 : 0
  source         = "./iam"
  aws_account_id = module.globals.var.AWS_ACCOUNT_ID
  document_name  = local.document_name
}

module "resources" {
  count           = var.workflow_step == "resources" ? 1 : 0
  source          = "./resources"
  aws_account_id  = module.globals.var.AWS_ACCOUNT_ID
  service_name    = var.service_name
  cluster_name    = var.service_name
  task_definition = var.task_definition
  document_name   = local.document_name
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}
