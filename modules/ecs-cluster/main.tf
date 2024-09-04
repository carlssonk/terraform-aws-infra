variable "workflow_step" {}

module "generate_policy_document" {
  count        = var.workflow_step == "iam" ? 1 : 0
  source       = "./iam"
  cluster_name = var.cluster_name
}

module "resources" {
  count        = var.workflow_step == "resources" ? 1 : 0
  source       = "./resources"
  cluster_name = var.cluster_name
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "cluster_id" {
  value = module.resources.cluster_id
}
