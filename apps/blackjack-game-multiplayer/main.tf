module "globals" {
  source = "../../globals"
}

locals {
  app_name       = "blackjack"
  root_domain    = var.root_domain
  container_name = "container-${local.app_name}"
  container_port = var.container_port
}

module "ecs_task_definition" {
  source   = "../../modules/ecs-task-definition/default"
  app_name = local.app_name
  cpu      = 256
  memory   = 512
  container_definitions = jsonencode([{
    name  = local.container_name
    image = "${module.globals.var.AWS_ACCOUNT_ID}.dkr.ecr.${module.globals.var.region}.amazonaws.com/repo-${local.app_name}:latest"
    portMappings = [{
      containerPort = local.container_port
    }]
  }])
}

module "ecs_target_group" {
  source       = "../../modules/alb-target-group/default"
  app_name     = local.app_name
  port         = local.container_port
  vpc_id       = var.vpc_id
  listener_arn = var.listener_arn
  host_header  = "${local.app_name}.${local.root_domain}"
}

module "ecs_service" {
  source               = "../../modules/ecs-service/default"
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
  source      = "../../modules/cloudflare/default"
  root_domain = local.root_domain
  dns_records = [{
    name  = local.app_name,
    value = var.alb_dns_name
  }]
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = local.app_name
  policy_documents = [
    module.ecs_task_definition.policy_document,
    module.ecs_target_group.policy_document,
    module.ecs_service.policy_document
  ]
}
