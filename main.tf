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

locals {
  // App configurations used by common infrastrucutre
  apps = {
    portfolio = {
      root_domain = "carlssonk.com"
      cloudflare_ruleset_rules = [{
        action = "set_config"
        action_parameters = {
          ssl = "flexible"
        }
        expression  = "(http.host eq \"carlssonk.com\" or http.host eq \"www.carlssonk.com\")"
        description = "Cloudflare rules for portfolio"
      }]
    }
    terraform_diagram = {
      root_domain = "carlssonk.com"
      cloudflare_ruleset_rules = [{
        action = "set_config"
        action_parameters = {
          ssl = "flexible"
        }
        expression  = "(http.host eq \"terraform.carlssonk.com\")"
        description = "Cloudflare rules for terraform-diagram"
      }]
    }
  }
}

########################################################################
######################## COMMON INFRASTRUCTURE #########################
########################################################################

module "networking" {
  source = "./common/networking"
}

module "security" {
  source             = "./common/security"
  networking_outputs = module.networking
}

module "services" {
  source             = "./common/services"
  networking_outputs = module.networking
  security_outputs   = module.security
}

module "cloudflare" {
  source = "./modules/cloudflare/default"
  apps   = local.apps
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "./iam_policy"
  name          = "common"
  policy_documents = flatten([
    module.networking.policy_documents,
    module.security.policy_documents,
    module.services.policy_documents
  ])
}

output "common_policy_document" {
  value = module.iam_policy.policy_document
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

module "terraform_diagram" {
  workflow_step = var.workflow_step
  source        = "./apps/terraform-diagram"
}
output "terraform_diagram_policy_document" {
  value = module.terraform_diagram.policy_document
}

########################################################################

module "blackjack" {
  workflow_step         = var.workflow_step
  source                = "./apps/blackjack-game-multiplayer"
  vpc_id                = module.networking.main_vpc_id
  subnet_ids            = module.networking.main_vpc_public_subnet_ids
  ecs_security_group_id = module.security.security_group_ecs_tasks_id
  cluster_id            = module.services.main_ecs_cluster_id
  alb_dns_name          = module.services.main_alb_dns_name
  alb_listener_arn      = module.services.main_alb_listener_arn
}
output "blackjack_policy_document" {
  value = module.blackjack.policy_document
}
