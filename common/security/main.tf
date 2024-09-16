module "globals" {
  source = "../../globals"
}

locals {
  allow_https_to_vpc_endpoints = {
    description                  = "Allow HTTPS to VPC endpoints"
    from_port                    = 443
    to_port                      = 443
    ip_protocol                  = "tcp"
    referenced_security_group_id = module.security_group_vpc_endpoints.id
  }

  allow_https_to_anywhere = {
    description = "Allow HTTPS to any destination"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    cidr_ipv6   = "::/0"
  }

  ecs_ports = {
    8080 = {
      egress_rules = [local.allow_https_to_vpc_endpoints, local.allow_https_to_anywhere]
    }
  }
}

module "security_group_alb" {
  source = "../../modules/security-group/default"
  name   = "alb"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_ecs_tasks" {
  source = "../../modules/security-group/default"
  name   = "ecs-tasks"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_vpc_endpoints" {
  source = "../../modules/security-group/default"
  name   = "vpc-endpoints"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_alb_rules" {
  source            = "../../modules/security-group-rules/default"
  name              = "alb"
  security_group_id = module.security_group_alb.id
  ingress_rules = [{
    description = "Allow HTTPS from Cloudflare"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = module.globals.var.cloudflare_ipv4_ranges
    cidr_ipv6   = module.globals.var.cloudflare_ipv6_ranges
  }]
  egress_rules = flatten([
    for port, _ in local.ecs_ports :
    {
      description                  = "Allow traffic to ECS tasks on port ${port}"
      from_port                    = port
      to_port                      = port
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.security_group_ecs_tasks.id
    }
  ])
}

module "security_group_ecs_tasks_rules" {
  source            = "../../modules/security-group-rules/default"
  name              = "ecs_tasks"
  security_group_id = module.security_group_ecs_tasks.id
  ingress_rules = flatten([
    for port, _ in local.ecs_ports :
    {
      description                  = "Allow traffic from ALB on port ${port}"
      from_port                    = port
      to_port                      = port
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.security_group_alb.id
    }
  ])
  egress_rules = flatten([
    for port, value in local.ecs_ports : flatten(value.egress_rules)
  ])
}

module "security_group_vpc_endpoints_rules" {
  source            = "../../modules/security-group-rules/default"
  name              = "vpc_endpoints"
  security_group_id = module.security_group_vpc_endpoints.id
  ingress_rules = [{
    description                  = "Allow HTTPS from ECS tasks"
    from_port                    = 443
    to_port                      = 443
    ip_protocol                  = "tcp"
    referenced_security_group_id = module.security_group_ecs_tasks.id
  }]
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoint/default"
  endpoints = [
    "com.amazonaws.${module.globals.var.AWS_REGION}.s3", // s3 vpc endpoints are free
    // Commented out for cost optimization
    # "com.amazonaws.${module.globals.var.AWS_REGION}.ecr.api",
    # "com.amazonaws.${module.globals.var.AWS_REGION}.ecr.dkr",
    # "com.amazonaws.${module.globals.var.AWS_REGION}.secretsmanager"
  ]
  vpc_id            = var.networking_outputs.main_vpc_id
  subnet_ids        = var.networking_outputs.main_vpc_private_subnet_ids
  security_group_id = module.security_group_vpc_endpoints.id
}
