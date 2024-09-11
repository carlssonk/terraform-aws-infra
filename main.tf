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
    random = {
      source  = "hashicorp/random"
      version = "2.3.0"
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

module "main_vpc" {
  workflow_step = var.workflow_step
  source        = "./modules/vpc"
}

module "main_alb" {
  workflow_step     = var.workflow_step
  source            = "./modules/alb"
  alb_name          = "main-alb"
  vpc_id            = module.main_vpc.vpc_id
  public_subnet_ids = module.main_vpc.public_subnet_ids
}

module "main_ecs_cluster" {
  workflow_step = var.workflow_step
  source        = "./modules/ecs-cluster"
  cluster_name  = "MainCluster"
}

module "common_infrastructure_policy" {
  workflow_step = var.workflow_step
  source        = "./iam_policy"
  name          = "common"
  policy_documents = [
    module.main_vpc.policy_document,
    module.main_alb.policy_document,
    module.main_ecs_cluster.policy_document
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
  workflow_step     = var.workflow_step
  source            = "./apps/blackjack-game-multiplayer"
  cluster_id        = module.main_ecs_cluster.cluster_id
  subnet_ids        = module.main_vpc.private_subnet_ids
  security_group_id = module.main_vpc.security_group_id
  vpc_id            = module.main_vpc.vpc_id
  alb_dns_name      = module.main_alb.alb_dns_name
  listener_arn      = module.main_alb.listener_arn
  cluster_name      = module.main_ecs_cluster.cluster_name
}
output "blackjack_policy_document" {
  value = module.blackjack.policy_document
}
