variable "app_name" {
  description = "Name of application"
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
  description = "ARN for ALB Target Group"
  type        = string
}

variable "container_name" {
  description = "Docker container name"
  type        = string
}

variable "container_port" {
  description = "Docker container port"
  type        = number
}
