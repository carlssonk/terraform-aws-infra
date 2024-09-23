module "globals" {
  source = "../../globals"
}

locals {
  github_repo_name = "carlssonk/flag-racer"
  app_name         = "flagracer"
  subdomain        = local.app_name
  root_domain      = "carlssonk.com"
  domain_name      = "${local.app_name}.${local.root_domain}"
  container_port   = 8080
  container_name   = "container-${local.app_name}"
  port_name        = "port-${local.app_name}"
}

module "cloudwatch" {
  source         = "../../modules/cloudwatch/default"
  log_group_name = "/ecs/${local.app_name}"
}

module "ecs_task_definition" {
  source   = "../../modules/ecs-task-definition/default"
  app_name = local.app_name
  cpu      = 256
  memory   = 512
  container_definitions = jsonencode([{
    name  = local.container_name
    image = "${module.globals.var.aws_account_id}.dkr.ecr.${module.globals.var.aws_region}.amazonaws.com/repo-${local.app_name}:latest"
    portMappings = [{
      containerPort = local.container_port
      hostPort      = local.container_port
      name          = local.port_name
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${local.app_name}"
        awslogs-region        = module.globals.var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

module "alb_target_group" {
  source                 = "../../modules/alb-target/default"
  app_name               = local.app_name
  container_port         = local.container_port
  vpc_id                 = var.vpc_id
  listener_arn           = var.alb_listener_arn
  host_header            = local.domain_name
  use_stickiness         = true
  listener_rule_priority = var.alb_listener_rule_priority
}

module "ecs_service" {
  source               = "../../modules/ecs-service/default"
  app_name             = local.app_name
  subnet_ids           = var.subnet_ids
  cluster_id           = var.cluster_id
  task_definition_arn  = module.ecs_task_definition.arn
  security_group_id    = var.ecs_security_group_id
  alb_target_group_arn = module.alb_target_group.arn
  container_name       = local.container_name
  container_port       = local.container_port
  assign_public_ip     = true
}

module "cloudflare" {
  source      = "../../modules/cloudflare-record/default"
  root_domain = local.root_domain
  dns_records = [{
    name  = local.subdomain
    value = var.alb_dns_name
  }]
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = local.app_name
  policy_documents = [
    module.ecs_task_definition.policy_document,
    module.alb_target_group.policy_document,
    module.ecs_service.policy_document,
    module.cloudwatch.policy_document
  ]
}
