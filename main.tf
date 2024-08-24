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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.0"
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
  source = "./apps/portfolio"
}

output "current_policy_document" {
  value       = module.portfolio.current_policy_document
  description = "The current set of policies, including both old and new"
}

output "previous_policy_document" {
  value       = module.portfolio.previous_policy_document
  description = "The previous set of policies"
}
