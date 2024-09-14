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
  egress_rules = [{
    description     = "Allow traffic to ECS tasks on port 3000"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.security_group_ecs_tasks.id]
  }]
}

module "security_group_ecs_tasks_rules" {
  source            = "../modules/security-group-rules/default"
  security_group_id = module.security_group_ecs_tasks.id
  ingress_rules = [{
    description     = "Allow traffic from ALB on port 3000"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.security_group_alb.id]
  }]
  egress_rules = [
    {
      description     = "Allow HTTPS to VPC endpoints"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [module.security_group_vpc_endpoints.id]
    },
    {
      description = "Allow HTTPS to any destination"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
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
}

module "ecs_cluster" {
  source       = "../modules/ecs-cluster/default"
  cluster_name = "MainCluster"
}

module "vpc_endpoints" {
  source = "../modules/vpc-endpoint/default"
  endpoints = [
    "com.amazonaws.${module.globals.var.region}.ecr.api",
    "com.amazonaws.${module.globals.var.region}.ecr.dkr",
    "com.amazonaws.${module.globals.var.region}.secretsmanager"
  ]
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_group_vpc_endpoints.id
}

module "common_infrastructure_policy" {
  workflow_step = var.workflow_step
  source        = "./iam_policy"
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

# resource "cloudflare_ruleset" "ssl_mode_rules" {
#   zone_id     = var.zone_id
#   name        = "SSL Mode Configuration"
#   description = "Configure SSL modes based on host headers"
#   kind        = "root"
#   phase       = "http_request_late"

#   rules {
#     action = "set_ssl"
#     action_parameters {
#       value = "flexible"
#     }
#     expression  = "(http.host eq \"example.com\")"
#     description = "Set Flexible SSL for example.com"
#   }
# }
