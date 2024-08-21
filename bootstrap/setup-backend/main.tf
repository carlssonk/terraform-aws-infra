// Bootstraps terraform backend for a new environment

variable "backend_bucket_name" {}
variable "backend_table_name" {}
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
  organization = var.organization
}