variable "workflow_step" {}

module "generate_policy_document" {
  count        = var.workflow_step == "iam" ? 1 : 0
  source       = "./iam"
  service_name = var.service_name
}

module "resources" {
  count                = var.workflow_step == "resources" ? 1 : 0
  source               = "./resources"
  service_name         = var.service_name
  subnet_ids           = var.subnet_ids
  cluster_id           = var.cluster_id
  task_definition_arn  = var.task_definition_arn
  security_group_id    = var.security_group_id
  alb_target_group_arn = var.alb_target_group_arn
  container_name       = var.container_name
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}
