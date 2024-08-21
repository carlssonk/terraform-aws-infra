terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }
  }
}
terraform {
  backend "s3" {}
}

module "portfolio" {
  source = "./apps/portfolio"
}