variable "workflow_step" {}

variable "subnet_ids" {}
variable "cluster_id" {}
variable "security_group_id" {}
variable "alb_dns_name" {}
variable "vpc_id" {}
variable "listener_arn" {}
variable "cluster_name" {}

locals {
  repo_name      = "carlssonk/Blackjack-Game-Multiplayer"
  app_name       = "blackjack"
  root_domain    = "carlssonk.com"
  container_port = 3000
  container_name = "container-${local.app_name}"
  task_name      = "task-${local.app_name}"
}

module "ecs_task_definition" {
  workflow_step = var.workflow_step
  source        = "../../modules/ecs-task-definition"
  task_name     = local.task_name
  cpu           = 256
  memory        = 512
  container_definitions = jsonencode([{
    name  = local.container_name
    image = "752502408032.dkr.ecr.eu-north-1.amazonaws.com/repo-blackjack:latest"
    portMappings = [{
      containerPort = local.container_port
      hostPort      = local.container_port
    }]
  }])
}

module "ecs_target_group" {
  workflow_step = var.workflow_step
  source        = "../../modules/alb-target-group"
  app_name      = local.app_name
  port          = local.container_port
  vpc_id        = var.vpc_id
  listener_arn  = var.listener_arn
}

module "ecs_service" {
  workflow_step        = var.workflow_step
  source               = "../../modules/ecs-service"
  app_name             = local.app_name
  subnet_ids           = var.subnet_ids
  cluster_id           = var.cluster_id
  task_definition_arn  = module.ecs_task_definition.task_definition_arn
  security_group_id    = var.security_group_id
  alb_target_group_arn = module.ecs_target_group.target_group_arn
  container_name       = local.container_name
  container_port       = local.container_port
}

module "cloudflare" {
  workflow_step = var.workflow_step
  source        = "../../modules/cloudflare"
  root_domain   = local.root_domain
  dns_records = [{
    name  = local.app_name,
    value = var.alb_dns_name
  }]
}

module "ecs_troubleshoot" {
  workflow_step       = var.workflow_step
  source              = "../../modules/automation-execution"
  service_name        = module.ecs_service.service_name
  cluster_name        = var.cluster_name
  task_definition_arn = module.ecs_task_definition.task_definition_arn
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = local.app_name
  policy_documents = [
    module.ecs_task_definition.policy_document,
    module.ecs_target_group.policy_document,
    module.ecs_service.policy_document,
    module.ecs_troubleshoot.policy_document
  ]
}

output "policy_document" {
  value = module.iam_policy.policy_document
}

output "service_name" {
  value = module.ecs_service.service_name
}
