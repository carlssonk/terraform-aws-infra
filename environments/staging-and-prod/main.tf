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

locals {
  reverse_proxy_type = "custom" // alb | custom - Custom will use a ec2 instance configured with nginx as a reverse proxy (more cost efficient than alb)
  # nat_type           = "nat-instance" // nat-gateway | nat-instance | none
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
}

module "cloudflare" {
  source      = "../../modules/cloudflare"
  apps        = local.apps
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
  for_each         = local.apps
  workflow_step    = var.workflow_step
  source           = "../../apps/s3-website"
  root_domain      = each.value.root_domain
  app_name         = each.value.app_name
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

module "blackjack" {
  workflow_step              = var.workflow_step
  source                     = "../../apps/blackjack-game-multiplayer"
  vpc_id                     = module.networking.main_vpc_id
  subnet_ids                 = module.networking.main_vpc_public_subnet_ids
  ecs_security_group_id      = module.security.security_group_ecs_tasks_id
  cluster_id                 = module.services.main_ecs_cluster_id
  alb_dns_name               = module.services.main_alb_dns_name
  alb_listener_arn           = module.services.main_alb_listener_arn
  alb_listener_rule_priority = 100
}

module "blackjack_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "blackjack"
  policy_documents = module.blackjack.policy_documents
}

########################################################################

module "flagracer" {
  workflow_step              = var.workflow_step
  source                     = "../../apps/flag-racer"
  vpc_id                     = module.networking.main_vpc_id
  subnet_ids                 = module.networking.main_vpc_public_subnet_ids
  ecs_security_group_id      = module.security.security_group_ecs_tasks_id
  cluster_id                 = module.services.main_ecs_cluster_id
  alb_dns_name               = module.services.main_alb_dns_name
  alb_listener_arn           = module.services.main_alb_listener_arn
  alb_listener_rule_priority = 99
}

module "flagracer_policy" {
  workflow_step    = var.workflow_step
  source           = "../../iam_policy"
  name             = "flagracer"
  policy_documents = module.flagracer.policy_documents
}
