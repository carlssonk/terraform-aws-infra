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
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  backend "s3" {}
}

locals {
  cloudflare_configuration = {
    portfolio = {
      root_domain = "carlssonk.com"
      ruleset_rules = [{
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
      ruleset_rules = [{
        action = "set_config"
        action_parameters = {
          ssl = "flexible"
        }
        expression  = "(http.host eq \"terraform.carlssonk.com\")"
        description = "Cloudflare rules for terraform-diagram"
      }]
    }
    fps = {
      root_domain = "carlssonk.com"
      ruleset_rules = [{
        action = "set_config"
        action_parameters = {
          ssl = "flexible"
        }
        expression  = "(http.host eq \"fps.carlssonk.com\")"
        description = "Cloudflare rules for fps"
      }]
    }
  }

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
  source = "../../modules/cloudflare/default"
  apps   = local.cloudflare_configuration
}

module "iam_policy" {
  workflow_step = var.workflow_step
  source        = "../../iam_policy"
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
  source        = "../../apps/portfolio"
  root_domain   = "carlssonk.com"
  app_name      = "portfolio"
}

output "portfolio_policy_document" {
  value = module.portfolio.policy_document
}

module "terraform_diagram" {
  workflow_step = var.workflow_step
  source        = "../../apps/terraform-diagram"
}

output "terraform_diagram_policy_document" {
  value = module.terraform_diagram.policy_document
}

module "fps" {
  workflow_step = var.workflow_step
  source        = "../../apps/fps"
}

output "fps_policy_document" {
  value = module.fps.policy_document
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
output "blackjack_policy_document" {
  value = module.blackjack.policy_document
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
output "flagracer_policy_document" {
  value = module.flagracer.policy_document
}
