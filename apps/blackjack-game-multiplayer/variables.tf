variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "root_domain" {
  description = "Domain name excluding subdomains"
  type        = string
}

variable "container_port" {
  description = "Port of the ECS task's Docker container"
  type        = number
}


variable "subnet_ids" {
  description = "List of subnet IDS"
  type        = list(string)
}

variable "cluster_id" {
  description = "Cluster ID to use"
  type        = string
}

variable "security_group_id" {
  description = "ID of Security Group"
  type        = string
}

variable "alb_dns_name" {
  description = "Application load balancer DNS name"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of alb listener"
  type        = string
}
