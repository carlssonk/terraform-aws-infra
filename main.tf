terraform {
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
  region = var.AWS_REGION
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  backend "s3" {}
}

########################################################################
######################## COMMON INFRASTRUCTURE #########################
########################################################################

module "common" {
  workflow_step = var.workflow_step
  source        = "./common"
}
output "common_policy_document" {
  value = module.common.policy_document
}

########################################################################
######################## APPLICATIONS/SERVICES #########################
########################################################################

module "portfolio" {
  workflow_step = var.workflow_step
  source        = "./apps/portfolio"
}
output "portfolio_policy_document" {
  value = module.portfolio.policy_document
}

########################################################################

module "diagram" {
  workflow_step = var.workflow_step
  source        = "./apps/terraform-diagram"
}
output "diagram_policy_document" {
  value = module.diagram.policy_document
}

########################################################################

module "blackjack" {
  workflow_step     = var.workflow_step
  source            = "./apps/blackjack-game-multiplayer"
  cluster_id        = module.main_ecs_cluster.cluster_id
  subnet_ids        = module.main_vpc.public_subnet_ids
  security_group_id = module.main_vpc.security_group_id
  vpc_id            = module.main_vpc.vpc_id
  alb_dns_name      = module.main_alb.alb_dns_name
  alb_listener_arn  = module.main_alb.alb_listener_arn
  root_domain       = module.common.apps.root_domain
  container_port    = module.common.apps.container_port
}
output "blackjack_policy_document" {
  value = module.blackjack.policy_document
}
