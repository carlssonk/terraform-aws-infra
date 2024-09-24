variable "workflow_step" {
  description = "Type of workflow: iam, resources"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "organization" {
  description = "Github account or organization name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
