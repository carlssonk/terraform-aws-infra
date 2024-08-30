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

module "portfolio" {
  source        = "./apps/portfolio"
  workflow_step = var.workflow_step
}

output "portfolio_policy_document" {
  value = module.portfolio.policy_document
}

output "previous_policy" {
  value = module.portfolio.previous_policy
}

output "previous_policy2" {
  value = module.portfolio.previous_policy2
}
