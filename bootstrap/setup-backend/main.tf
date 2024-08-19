// Bootstraps terraform backend for a new environment

variable "environment" {}
variable "region" {}
variable "organization" {}

provider "aws" {
  region = var.region
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "${var.organization}-terraform-state-bucket-${var.environment}"
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  table_name = "${var.organization}-terraform-lock-table-${var.environment}"
}