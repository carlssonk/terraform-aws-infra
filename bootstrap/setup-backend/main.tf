// Bootstraps terraform backend for a new environment

variable "region" {}
variable "organization" {}

provider "aws" {
  region = var.region
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "terraform-state-bucket"
  is_bootstrap_user = true
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  table_name = "terraform-lock-table"
}