// Bootstraps terraform backend for a new environment

variable "backend_bucket_name" {}
variable "backend_table_name" {}
variable "environment" {}
variable "region" {}
variable "organization" {}

provider "aws" {
  region = var.region
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = var.backend_bucket_name
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  table_name = var.backend_table_name
  environment = var.environment
  organization = var.organization
}