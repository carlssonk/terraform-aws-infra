variable "app_name" {
  description = "Name of application"
  type        = string
}

variable "reverse_proxy_type" {
  description = "nginx|alb - nginx will use a custom ec2 instance with a public Elastic IP, as a replacement for alb because its cheaper"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet ID's to use"
  type        = list(string)
}

variable "cluster_id" {
  description = "Cluster ID to use"
  type        = string
}

variable "task_definition_arn" {
  description = "Task definition to use"
  type        = string
}

variable "security_group_id" {
  description = "ID of a security group"
  type        = string
}

variable "alb_target_group_arn" {
  type        = string
  description = "ARN of the ALB target group. Required if reverse_proxy_type is 'alb'"
  default     = null
}

variable "container_name" {
  description = "Docker container name. Required if reverse_proxy_type is 'alb'"
  type        = string
  default     = null
}

variable "container_port" {
  description = "Docker container port. Required if reverse_proxy_type is 'alb'"
  type        = number
  default     = null
}

variable "port_name" {
  description = "Used for service discovery. Required if reverse_proxy_type is 'nginx'"
  type        = string
  default     = null
}

variable "discovery_name" {
  description = "Used for service discovery. Required if reverse_proxy_type is 'nginx'"
  type        = string
  default     = null
}

variable "service_discovery_namespace_arn" {
  description = "ARN of service discovery http namespace. Required if reverse_proxy_type is 'nginx'"
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Should be true if service needs access to internet and is not using NAT Gateway"
  type        = bool
  default     = false
}

variable "fargate_spot_percentage" {
  description = "Percentage of tasks to run on Fargate Spot (0-100). Eg. if you specify 50, 50% of tasks will be run on spot and 50% on On-Demand instances. Spot is cheaper but less stable."
  type        = number
  validation {
    condition     = var.fargate_spot_percentage >= 0 && var.fargate_spot_percentage <= 100
    error_message = "fargate_spot_percentage must be between 0 and 100."
  }
}
