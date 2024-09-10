variable "workflow_step" {}

locals {
  service_name = "service-${var.app_name}"
  repo_name    = "repo-${var.app_name}"
}

module "generate_policy_document" {
  count        = var.workflow_step == "iam" ? 1 : 0
  source       = "./iam"
  service_name = local.service_name
  repo_name    = local.repo_name
}

module "resources" {
  count               = var.workflow_step == "resources" ? 1 : 0
  source              = "./resources"
  service_name        = local.service_name
  repo_name           = local.repo_name
  subnet_ids          = var.subnet_ids
  cluster_id          = var.cluster_id
  task_definition_arn = var.task_definition_arn
  security_group_id   = var.security_group_id
  container_name      = var.container_name
  container_port      = var.container_port
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "service_name" {
  value = local.service_name
}

output "repo_name" {
  value = local.repo_name
}
