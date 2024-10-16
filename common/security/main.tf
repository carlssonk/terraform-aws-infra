module "globals" {
  source = "../../globals"
}

data "aws_region" "current" {}

locals {
  allow_https_to_vpc_endpoints = {
    description                  = "Allow HTTPS to VPC endpoints"
    from_port                    = 443
    to_port                      = 443
    ip_protocol                  = "tcp"
    referenced_security_group_id = module.security_group_vpc_endpoints.id
  }

  allow_dns_anywhere = {
    description = "Allow DNS"
    from_port   = 53
    to_port     = 53
    ip_protocol = "udp"
    cidr_ipv4   = "0.0.0.0/0"
  }

  allow_http_anywhere_ipv4 = {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }

  allow_https_anywhere_ipv4 = {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }

  allow_https_anywhere_ipv6 = {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv6   = "::/0"
  }

  ecs_ports = {
    8080 = {
      egress_rules = [local.allow_https_to_vpc_endpoints, local.allow_https_anywhere_ipv4, local.allow_https_anywhere_ipv6]
    }
  }
}

module "security_group_alb" {
  source = "../../modules/security-group"
  name   = "alb"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_nginx" {
  source = "../../modules/security-group"
  name   = "nginx"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_ecs_tasks" {
  source = "../../modules/security-group"
  name   = "ecs-tasks"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_vpc_endpoints" {
  source = "../../modules/security-group"
  name   = "vpc-endpoints"
  vpc_id = var.networking_outputs.main_vpc_id
}

module "security_group_alb_rules" {
  source            = "../../modules/security-group-rules"
  name              = "alb"
  security_group_id = module.security_group_alb.id
  ingress_rules = flatten([
    [for ip in module.globals.var.cloudflare_ipv4_ranges : {
      description = "Allow inbound HTTPS from Cloudflare IP: ${ip}"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = ip
    }],
    [for ip in module.globals.var.cloudflare_ipv6_ranges : {
      description = "Allow inbound HTTPS from Cloudflare IP: ${ip}"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv6   = ip
    }]
  ])
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

module "security_group_nginx_rules" {
  source            = "../../modules/security-group-rules"
  name              = "nginx"
  security_group_id = module.security_group_nginx.id
  ingress_rules = flatten([
    [for ip in module.globals.var.cloudflare_ipv4_ranges : {
      description = "Allow inbound HTTPS from Cloudflare IP: ${ip}"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = ip
    }],
    [for ip in module.globals.var.cloudflare_ipv6_ranges : {
      description = "Allow inbound HTTPS from Cloudflare IP: ${ip}"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv6   = ip
    }]
  ])
  egress_rules = flatten([
    [
      for port, _ in local.ecs_ports :
      {
        description                  = "Allow traffic to ECS tasks on port ${port}"
        from_port                    = port
        to_port                      = port
        ip_protocol                  = "tcp"
        referenced_security_group_id = module.security_group_ecs_tasks.id
      }
    ],
    [
      local.allow_dns_anywhere,
      local.allow_http_anywhere_ipv4,
      local.allow_https_anywhere_ipv4
    ]
  ])
}

module "security_group_ecs_tasks_rules" {
  source            = "../../modules/security-group-rules"
  name              = "ecs_tasks"
  security_group_id = module.security_group_ecs_tasks.id
  ingress_rules = flatten([
    for port, _ in local.ecs_ports :
    {
      description                  = "Allow traffic from ${var.reverse_proxy_type == "alb" ? "ALB" : "NGINX"} on port ${port}"
      from_port                    = port
      to_port                      = port
      ip_protocol                  = "tcp"
      referenced_security_group_id = var.reverse_proxy_type == "alb" ? module.security_group_alb.id : module.security_group_nginx.id
    }
  ])
  egress_rules = flatten([
    for port, value in local.ecs_ports : flatten(value.egress_rules)
  ])
}

module "security_group_vpc_endpoints_rules" {
  source            = "../../modules/security-group-rules"
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

// Gateway endpoints are free
module "vpc_endpoints_gateway" {
  source = "../../modules/vpc-endpoint"
  type   = "gateway"
  endpoints = [
    "com.amazonaws.${data.aws_region.current.name}.s3",
    "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  ]
  vpc_id          = var.networking_outputs.main_vpc_id
  route_table_ids = var.networking_outputs.main_vpc_private_route_table_ids
}

// Commented out for cost optimization
# module "vpc_endpoints_interface" {
#   source = "../../modules/vpc-endpoint"
#   type   = "interface"
#   endpoints = [
#     "com.amazonaws.${data.aws_region.current.name}.ecr.api",
#     "com.amazonaws.${data.aws_region.current.name}.ecr.dkr",
#   ]
#   vpc_id            = var.networking_outputs.main_vpc_id
#   subnet_ids        = var.networking_outputs.main_vpc_private_subnet_ids
#   security_group_id = module.security_group_vpc_endpoints.id
# }
