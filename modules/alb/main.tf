variable "workflow_step" {}

module "generate_policy_document" {
  count  = var.workflow_step == "iam" ? 1 : 0
  source = "./iam"
}

module "resources" {
  count             = var.workflow_step == "resources" ? 1 : 0
  source            = "./resources"
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "alb_dns_name" {
  value = try(module.resources[0].alb_dns_name, null)
}

output "target_group_arn" {
  value = try(module.resources[0].target_group_arn, null)
}
