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
  region = var.region
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

module "simple_vpc" {
  workflow_step = var.workflow_step
  source        = "./modules/vpc"
}

module "simple_alb" {
  workflow_step     = var.workflow_step
  source            = "./modules/alb"
  vpc_id            = module.simple_vpc.vpc_id
  public_subnet_ids = module.simple_vpc.public_subnet_ids
}

module "simple_ecs_cluster" {
  workflow_step = var.workflow_step
  source        = "./modules/ecs-cluster"
  cluster_name  = "SimpleCluster"
}

module "common_infrastructure_policy" {
  workflow_step = var.workflow_step
  source        = "./iam_policy"
  name          = "common"
  policy_documents = [
    module.simple_vpc.policy_document,
    module.simple_alb.policy_document,
    module.simple_ecs_cluster.policy_document
  ]
}

output "common_policy_document" {
  value = module.common_infrastructure_policy.policy_document
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

#######################################################################

module "blackjack" {
  workflow_step        = var.workflow_step
  source               = "./apps/blackjack-game-multiplayer"
  cluster_id           = module.simple_ecs_cluster.cluster_id
  subnet_ids           = module.simple_vpc.public_subnet_ids
  security_group_id    = module.simple_vpc.security_group_id
  alb_dns_name         = module.simple_alb.alb_dns_name
  alb_target_group_arn = module.simple_alb.target_group_arn
}
output "blackjack_policy_document" {
  value = module.blackjack.policy_document
}
