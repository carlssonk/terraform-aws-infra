variable "workflow_step" {}

module "generate_policy_document" {
  count  = var.workflow_step == "iam" ? 1 : 0
  source = "./iam"
}

module "resources" {
  count        = var.workflow_step == "resources" ? 1 : 0
  source       = "./resources"
  vpc_id       = var.vpc_id
  port         = var.port
  listener_arn = var.listener_arn
  app_name     = var.app_name
  host_header  = var.host_header
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "target_group_arn" {
  value = try(module.resources[0].target_group_arn, null)
}
