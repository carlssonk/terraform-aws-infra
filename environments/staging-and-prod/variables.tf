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

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
}

variable "fargate_spot_percentage" {
  description = "Percentage of tasks to run on Fargate Spot (0-100). Eg. if you specify 50, 50% of tasks will be run on spot and 50% on On-Demand instances. Spot is cheaper but less stable."
  type        = number
  default     = 0
  validation {
    condition     = var.fargate_spot_percentage >= 0 && var.fargate_spot_percentage <= 100
    error_message = "fargate_spot_percentage must be between 0 and 100."
  }
}
