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

variable "use_single_subnet" {
  description = "Reduces costs associated with multiple NAT Gateways/Instances and data transfer between AZs, but gives less availability/stability"
  type        = bool
  default     = false
}

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
  default     = "alb"
}

variable "nat_type" {
  description = "fck-nat|null - Allows outbound traffic from services that are in private subnets. By default one nat per AZ will be created, set use_single_subnet to true to only use one"
  type        = string
  default     = null
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

variable "nginx_proxy_instance_settings" {
  description = "Set spot_max_price_multiplier to about 0.5-0.7 (50-70%) of the On-Demand price. This balances cost savings with availability."
  type = object({
    instance_type             = string
    use_spot                  = optional(bool)
    spot_max_price_multiplier = optional(number)
    spot_instance_type        = optional(string)
  })
  default = {
    instance_type = "t4g.nano"
  }
  validation {
    condition     = var.nginx_proxy_instance_settings.spot_max_price_multiplier >= 0 && var.nginx_proxy_instance_settings.spot_max_price_multiplier <= 1
    error_message = "spot_max_price_multiplier must be between 0 and 1."
  }
}

variable "fck_nat_settings" {
  description = "Settings for fck-nat module https://registry.terraform.io/modules/RaJiska/fck-nat/aws/latest"
  type = object({
    instance_type     = string
    use_spot          = optional(bool)
    high_availability = optional(bool)
  })
  default = {
    instance_type = "t4g.nano"
  }
}
