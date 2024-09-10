variable "workflow_step" {}

variable "subnet_ids" {}
variable "cluster_id" {}
variable "security_group_id" {}
variable "alb_dns_name" {}
variable "alb_target_group_arn" {}

locals {
  repo_name      = "carlssonk/Blackjack-Game-Multiplayer"
  app_name       = "blackjack" // also subdomain
  root_domain    = "carlssonk.com"
  container_port = 3000
  container_name = "container-${local.app_name}"
}

module "ecs_task_definition" {
  workflow_step = var.workflow_step
  source        = "../../modules/ecs-task-definition"
  task_name     = "task-${local.app_name}"
  cpu           = 256
  memory        = 512
  container_definitions = jsonencode([{
    name  = local.container_name
    image = "node:22-alpine"
    portMappings = [{
      containerPort = local.container_port
      hostPort      = local.container_port
    }]
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:${local.container_port}/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])
}

module "ecs_service" {
  workflow_step        = var.workflow_step
  source               = "../../modules/ecs-service"
  app_name             = local.app_name
  subnet_ids           = var.subnet_ids
  cluster_id           = var.cluster_id
  task_definition_arn  = module.ecs_task_definition.task_definition_arn
  security_group_id    = var.security_group_id
  alb_target_group_arn = var.alb_target_group_arn
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
  zone_settings = {
    websockets = "on"
    ssl        = "full"
  }
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = local.app_name
  policy_documents = [
    module.ecs_task_definition.policy_document,
    module.ecs_service.policy_document
  ]
}

output "policy_document" {
  value = module.iam_policy.policy_document
}
