terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

module "globals" {
  source = "../globals"
}

########################################################################
################################# AWS ##################################
########################################################################

module "vpc" {
  source = "../modules/vpc/default"
  name   = "main"
}

module "security_group_alb" {
  source = "../modules/security-group/default"
  name   = "alb"
  vpc_id = module.vpc.id
}

module "security_group_ecs_tasks" {
  source = "../modules/security-group/default"
  name   = "ecs-tasks"
  vpc_id = module.vpc.id
}

module "security_group_vpc_endpoints" {
  source = "../modules/security-group/default"
  name   = "vpc-endpoints"
  vpc_id = module.vpc.id
}

module "security_group_alb_rules" {
  source            = "../modules/security-group-rules/default"
  security_group_id = module.security_group_alb.id
  ingress_rules = [{
    description = "Allow HTTPS from Cloudflare"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.globals.var.cloudflare_id_ranges
  }]
  egress_rules = flatten([
    for port, _ in local.ecs_ports :
    {
      description     = "Allow traffic to ECS tasks on port ${port}"
      from_port       = port
      to_port         = port
      protocol        = "tcp"
      security_groups = [module.security_group_ecs_tasks.id]
    }
  ])
}

module "security_group_ecs_tasks_rules" {
  source            = "../modules/security-group-rules/default"
  security_group_id = module.security_group_ecs_tasks.id
  ingress_rules = flatten([
    for port, _ in local.ecs_ports :
    {
      description     = "Allow traffic from ALB on port ${port}"
      from_port       = port
      to_port         = port
      protocol        = "tcp"
      security_groups = [module.security_group_alb.id]
    }
  ])
  egress_rules = flatten([
    for port, value in local.ecs_ports : flatten(value.egress_rules)
  ])
}

module "security_group_vpc_endpoints_rules" {
  source            = "../modules/security-group-rules/default"
  security_group_id = module.security_group_vpc_endpoints.id
  ingress_rules = [{
    description     = "Allow HTTPS from ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.security_group_ecs_tasks.id]
  }]
}

module "alb" {
  source            = "../modules/alb/default"
  name              = "main"
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_group_alb.id
  root_domain_names = ["carlssonk.com"] // Creates ACM certificates for alb
}

module "ecs_cluster" {
  source       = "../modules/ecs-cluster/default"
  cluster_name = "MainCluster"
}

module "vpc_endpoints" {
  source = "../modules/vpc-endpoint/default"
  endpoints = [
    "com.amazonaws.${module.globals.var.REGION}.ecr.api",
    "com.amazonaws.${module.globals.var.REGION}.ecr.dkr",
    "com.amazonaws.${module.globals.var.REGION}.secretsmanager"
  ]
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_group_vpc_endpoints.id
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../iam_policy"
  name          = "common"
  policy_documents = [
    module.vpc.policy_document,
    module.security_group_alb.policy_document,
    module.security_group_ecs_tasks.policy_document,
    module.security_group_vpc_endpoints.policy_document,
    module.security_group_alb_rules.policy_document,
    module.security_group_ecs_tasks_rules.policy_document,
    module.security_group_vpc_endpoints_rules.policy_document,
    module.alb.policy_document,
    module.ecs_cluster.policy_document,
    module.vpc_endpoints.policy_document
  ]
}

########################################################################
############################# CLOUDFLARE ###############################
########################################################################

data "cloudflare_zone" "domain" {
  name = "carlssonk.com"
}

resource "cloudflare_ruleset" "main" {
  zone_id     = data.cloudflare_zone.domain.id
  name        = "Dynamic Main Ruleset"
  description = "Dynamic ruleset for managing app settings"
  kind        = "zone"
  phase       = "http_request_late_transform"

  dynamic "rules" {
    for_each = flatten([for _, value in local.apps : value.cloudflare_ruleset_rules])
    content {
      action = rules.value.action

      dynamic "action_parameters" {
        for_each = rules.value.action_parameters.ssl != null ? [rules.value.action_parameters.ssl] : []
        content {
          ssl = action_parameters.value
        }
      }

      expression  = rules.value.expression
      description = rules.value.description
    }
  }
}
