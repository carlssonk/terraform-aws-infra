terraform {
  required_version = "1.9.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
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

// Set up a separate aws account for storing artifacts
// Create a script merging iam policies together

########################################################################
######################## COMMON INFRASTRUCTURE #########################
########################################################################

module "networking" {
  workflow_step     = var.workflow_step
  source            = "../../common/networking"
  use_single_subnet = var.use_single_subnet
  nat_type          = var.nat_type
  fck_nat_settings  = var.fck_nat_settings
}

module "security" {
  source             = "../../common/security"
  networking_outputs = module.networking

  reverse_proxy_type = var.reverse_proxy_type
}

module "services" {
  workflow_step      = var.workflow_step
  source             = "../../common/services"
  networking_outputs = module.networking
  security_outputs   = module.security

  reverse_proxy_type = var.reverse_proxy_type
  root_domains       = local.root_domains
  fargate_services   = local.fargate_services
  ec2_instances      = local.ec2_instances
}

# Cloudflare is shared across all environments
module "cloudflare" {
  count        = var.environment == "prod" ? 1 : 0
  source       = "../../modules/cloudflare"
  apps         = local.cloudflare_app_settings
  environments = local.environments
}

module "networking_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "networking"
  policy_documents = module.networking.policy_documents
}

module "security_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "security"
  policy_documents = module.security.policy_documents
}

module "services_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "services"
  policy_documents = module.services.policy_documents
}

########################################################################
######################## APPLICATIONS/SERVICES #########################
########################################################################

module "s3_websites" {
  for_each         = local.s3_websites
  workflow_step    = var.workflow_step
  source           = "../../apps/s3-website"
  app_name         = each.value.app_name
  root_domain      = each.value.root_domain
  subdomain        = each.value.subdomain
  github_repo_name = each.value.github_repo_name
}

module "s3_websites_policy" {
  count            = length(local.s3_websites) > 0 ? 1 : 0
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "s3_websites"
  policy_documents = flatten(values(module.s3_websites)[*].policy_documents)
}

########################################################################

module "s3_media" {
  for_each      = local.s3_media
  workflow_step = var.workflow_step
  source        = "../../apps/s3-media"
  bucket_name   = each.value.bucket_name
  root_domain   = each.value.root_domain
  subdomain     = each.value.subdomain
}

module "s3_media_policy" {
  count            = length(local.s3_media) > 0 ? 1 : 0
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "s3_media"
  policy_documents = flatten(values(module.s3_media)[*].policy_documents)
}

########################################################################

module "fargate_services" {
  for_each = local.fargate_services
  source   = "../../apps/fargate-service"

  # Common attributes
  workflow_step           = var.workflow_step
  reverse_proxy_type      = var.reverse_proxy_type
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
  alb_dns_name               = module.services.main_alb_dns_name
  alb_listener_arn           = module.services.main_alb_listener_arn
  alb_listener_rule_priority = try(100 - index(keys(local.fargate_services), each.key), null)
  use_stickiness             = try(each.value.use_stickiness, null)

  # NGINX-specific attributes
  service_discovery_namespace_id = module.services.service_discovery_namespace_id
  nginx_proxy_public_ip          = module.services.nginx_proxy_public_ip
}

module "fargate_services_policy" {
  count            = length(local.fargate_services) > 0 ? 1 : 0
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "fargate_services"
  policy_documents = flatten(values(module.fargate_services)[*].policy_documents)
}
