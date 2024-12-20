variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "networking_outputs" {
  description = "All outputs from the networking module"
  type        = any
}

variable "security_outputs" {
  description = "All outputs from the security module"
  type        = any
}

variable "root_domains" {
  description = "Map of all root domains"
  type        = map(any)
}

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
}

variable "fargate_services" {
  description = "Configuration for fargate services"
  type        = map(any)
}

variable "ec2_instances" {
  description = "Set spot_max_price_multiplier to about 0.5-0.7 (50-70%) of the On-Demand price. This balances cost savings with availability."
  type = map(object({
    instance_type             = string
    use_spot                  = optional(bool)
    spot_max_price_multiplier = optional(number)
    spot_max_price            = optional(number)
    spot_instance_type        = optional(string)
  }))
}
