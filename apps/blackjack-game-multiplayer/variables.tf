
variable "subnet_ids" {}
variable "cluster_id" {}
variable "security_group_id" {}
variable "alb_dns_name" {}
variable "vpc_id" {}
variable "listener_arn" {}

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
