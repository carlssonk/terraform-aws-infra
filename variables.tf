variable "workflow_step" {
  description = "Type of workflow: iam, resources"
  type        = string
}

variable "AWS_REGION" {
  description = "AWS Region"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}
