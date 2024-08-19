// Bootstraps terraform backend for a new environment

variable "environment" {}
variable "region" {}
variable "organization" {}

provider "aws" {
  region = var.region
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "terraform-state-bucket"
  environment = var.environment
  organization = var.organization
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  table_name = "terraform-lock-table"
  environment = var.environment
  organization = var.organization
}