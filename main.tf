variable "environment" {}
variable "region" {}
variable "organization" {}

terraform {
  backend "s3" {}
}

module "portfolio" {
  source = "./apps/portfolio"
  environment = var.environment
  organization = var.organization
}
