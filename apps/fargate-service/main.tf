module "globals" {
  source = "../../globals"
}

locals {
  domain_name    = "${var.app_name}.${var.root_domain}"
  container_name = "container-${var.app_name}"
  port_name      = "port-${var.app_name}"
}

module "cloudwatch" {
  source         = "../../modules/cloudwatch/default"
  log_group_name = "/ecs/${var.app_name}"
}

module "ecs_task_definition" {
  source   = "../../modules/ecs-task-definition/default"
  app_name = var.app_name
  cpu      = 256
  memory   = 512
  container_definitions = jsonencode([{
    name  = local.container_name
    image = "${module.globals.var.aws_account_id}.dkr.ecr.${module.globals.var.aws_region}.amazonaws.com/repo-${var.app_name}:latest"
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      name          = local.port_name
    }]
    environment = [
      {
        name  = "DOMAIN_NAME"
        value = local.domain_name
      },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.app_name}"
        awslogs-region        = module.globals.var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

module "alb_target_group" {
  count                  = var.reverse_proxy_type == "alb" ? 1 : 0
  source                 = "../../modules/alb-target/default"
  app_name               = var.app_name
  container_port         = var.container_port
  vpc_id                 = var.vpc_id
  listener_arn           = var.alb_listener_arn
  host_header            = local.domain_name
  use_stickiness         = var.use_stickiness
  listener_rule_priority = var.alb_listener_rule_priority
}

module "ecs_service" {
  source             = "../../modules/ecs-service/default"
  reverse_proxy_type = var.reverse_proxy_type

  # Common attributes
  app_name                = var.app_name
  subnet_ids              = var.subnet_ids
  cluster_id              = var.cluster_id
  task_definition_arn     = module.ecs_task_definition.arn
  security_group_id       = var.ecs_security_group_id
  assign_public_ip        = var.assign_public_ip
  fargate_spot_percentage = var.fargate_spot_percentage

  # ALB-specific attributes
  alb_target_group_arn = try(module.alb_target_group[0].arn, null)
  container_port       = var.container_port
  container_name       = local.container_name

  # NGINX-specific attributes
  port_name                      = local.port_name
  discovery_name                 = var.subdomain
  service_discovery_namespace_id = var.service_discovery_namespace_id
}

module "cloudflare" {
  source      = "../../modules/cloudflare-record"
  root_domain = var.root_domain
  dns_records = [{
    name  = var.subdomain
    value = var.reverse_proxy_type == "alb" ? var.alb_dns_name : var.nginx_proxy_public_ip
    type  = var.reverse_proxy_type == "alb" ? "CNAME" : "A"
  }]
}
