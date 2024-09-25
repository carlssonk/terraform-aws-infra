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

module "ecs_service" {
  source                          = "../../modules/ecs-service/default"
  reverse_proxy_type              = "nginx"
  app_name                        = var.app_name
  subnet_ids                      = var.subnet_ids
  cluster_id                      = var.cluster_id
  task_definition_arn             = module.ecs_task_definition.arn
  security_group_id               = var.ecs_security_group_id
  assign_public_ip                = var.assign_public_ip
  discovery_name                  = var.subdomain
  port_name                       = local.port_name
  fargate_spot_percentage         = var.fargate_spot_percentage
  service_discovery_namespace_arn = var.service_discovery_namespace_arn
}

# module "cloudflare" {
#   source      = "../../modules/cloudflare-record"
#   root_domain = var.root_domain
#   dns_records = [{
#     name  = var.subdomain
#     value = "reverse proxy elastic ip address"
#   }]
# }
