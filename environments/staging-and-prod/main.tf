terraform {
  required_version = "1.9.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  backend "s3" {}
}

// TODO
// Spin up a ec2 micro instance with nginx and proxypass (a more cost efficient alternative to application load balancer)
// Change my farget services to Spot Fargate (Up to 70% cost reduction)
// Set up a NAT instance for fck-nat and remove Assign public IP for my ecs services

########################################################################
######################## COMMON INFRASTRUCTURE #########################
########################################################################

module "networking" {
  source = "../../common/networking"
}

module "security" {
  source             = "../../common/security"
  networking_outputs = module.networking
}

module "services" {
  source             = "../../common/services"
  networking_outputs = module.networking
  security_outputs   = module.security
  reverse_proxy_type = var.reverse_proxy_type
  root_domains       = local.root_domains
}

module "cloudflare" {
  source      = "../../modules/cloudflare"
  apps        = local.s3-websites
  environment = var.environment
}

module "common_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
  name          = "common"
  policy_documents = flatten([
    module.networking.policy_documents,
    module.security.policy_documents,
    module.services.policy_documents
  ])
}

########################################################################
######################## APPLICATIONS/SERVICES #########################
########################################################################

module "s3_websites" {
  for_each         = local.s3-websites
  workflow_step    = var.workflow_step
  source           = "../../apps/s3-website"
  app_name         = each.value.app_name
  root_domain      = each.value.root_domain
  subdomain        = each.value.subdomain
  github_repo_name = each.value.github_repo_name
}

module "s3_websites_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "s3_websites"
  policy_documents = flatten(values(module.s3_websites)[*].policy_documents)
}

########################################################################

module "fargate_services" {
  for_each = local.fargate-services
  source   = "../../apps/fargate-service-${var.reverse_proxy_type}"

  # Common attributes
  workflow_step           = var.workflow_step
  vpc_id                  = module.networking.main_vpc_id
  subnet_ids              = try(each.value.assign_public_ip, false) || try(each.value.use_public_subnets, false) ? module.networking.main_vpc_public_subnet_ids : module.networking.main_vpc_private_subnet_ids
  ecs_security_group_id   = module.security.security_group_ecs_tasks_id
  cluster_id              = module.services.main_ecs_cluster_id
  app_name                = each.value.app_name
  root_domain             = each.value.root_domain
  subdomain               = each.value.subdomain
  github_repo_name        = each.value.github_repo_name
  container_port          = each.value.container_port
  assign_public_ip        = try(each.value.assign_public_ip, null)
  fargate_spot_percentage = try(each.value.fargate_spot_percentage, null)

  # ALB-specific attributes
  alb_dns_name               = var.reverse_proxy_type == "alb" ? module.services.main_alb_dns_name : null
  alb_listener_arn           = var.reverse_proxy_type == "alb" ? module.services.main_alb_listener_arn : null
  alb_listener_rule_priority = var.reverse_proxy_type == "alb" ? 100 - index(keys(local.fargate-services), each.key) : null
  use_stickiness             = var.reverse_proxy_type == "alb" ? try(each.value.use_stickiness, null) : null

  # NGINX-specific attributes
  service_discovery_namespace_arn = var.reverse_proxy_type == "nginx" ? module.service.service_discovery_namespace.arn : null
}

module "fargate_services_policy" {
  count            = length(local.fargate-services) > 0 ? 1 : 0
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "fargate_services_${var.reverse_proxy_type}"
  policy_documents = flatten(values(module.fargate_services)[*].policy_documents)
}
