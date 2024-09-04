variable "workflow_step" {}
variable "aws_account_id" {}

module "globals" {
  source = "../../globals"
}

module "generate_policy_document" {
  count                     = var.workflow_step == "iam" ? 1 : 0
  source                    = "./iam"
  task_definition_arn_query = "${module.globals.var.region}:${var.aws_account_id}:task-definition/${var.task_name}"
}

module "resources" {
  count                 = var.workflow_step == "resources" ? 1 : 0
  source                = "./resources"
  task_name             = var.task_name
  cpu                   = var.cpu
  memory                = var.memory
  container_definitions = var.container_definitions
  execution_role_arn    = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
}

output "policy_document" {
  value = try(module.generate_policy_document[0].policy_document, null)
}

output "task_definition_arn" {
  value = try(module.resources[0].task_definition_arn, null)
}
