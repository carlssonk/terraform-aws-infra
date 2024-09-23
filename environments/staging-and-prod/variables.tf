variable "workflow_step" {
  description = "Type of workflow: iam, resources"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}
