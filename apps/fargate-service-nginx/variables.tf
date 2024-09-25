variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "app_name" {
  description = "Name"
  type        = string
}

variable "root_domain" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomains. Use 'www' if website is root"
  type        = string
}

variable "container_port" {
  description = "Port of Docker container"
  type        = number
}

variable "github_repo_name" {
  description = "Repository name for deployment policy. '[github name]/[repo name]'"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDS. If you use private subnets and you're not using a NAT gatewat/instance, you need to add VPC endpoints for ECR pull etc."
  type        = list(string)
}

variable "cluster_id" {
  description = "Cluster ID to use"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID of Security Group"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "assign_public_ip" {
  description = "Set this to true if you dont have a NAT gateway/instance and you need your service to make outbound requests (service must also be in a public subnet in this case)"
  type        = bool
  default     = false
}

variable "service_discovery_namespace_arn" {
  description = "ARN of service discovery http namespace"
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
