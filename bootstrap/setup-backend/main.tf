// Bootstraps terraform backend for a new environment
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.ORGANIZATION}-terraform-state-bucket-${terraform.workspace}"
}

resource "aws_dynamodb_table" "this" {
  name         = "${var.ORGANIZATION}-terraform-lock-table-${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
