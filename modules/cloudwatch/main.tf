variable "workflow_step" {}

module "generate_policy_document" {
  count  = var.workflow_step == "iam" ? 1 : 0
  source = "./iam"
}

module "resources" {
  count          = var.workflow_step == "resources" ? 1 : 0
  source         = "./resources"
  log_group_name = var.log_group_name
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "log_group_name" {
  value = try(module.resources[0].log_group_name, null)
}
