variable "workflow_step" {}

module "generate_policy_document" {
  count  = var.workflow_step == "iam" ? 1 : 0
  source = "./iam"
}

module "resources" {
  count  = var.workflow_step == "resources" ? 1 : 0
  source = "./resources"
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "private_subnet_ids" {
  value = try(module.resources[0].private_subnet_ids, null)
}

output "public_subnet_ids" {
  value = try(module.resources[0].public_subnet_ids, null)
}

output "security_group_id" {
  value = try(module.resources[0].security_group_id, null)
}
