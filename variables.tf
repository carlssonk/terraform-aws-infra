variable "workflow_step" {
  description = "Type of workflow: iam, resources"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}
