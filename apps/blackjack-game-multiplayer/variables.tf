variable "workflow_step" {
  description = "iam|resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDS"
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

variable "alb_dns_name" {
  description = "Application load balancer DNS name"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of alb listener"
  type        = string
}

variable "alb_listener_rule_priority" {
  description = "Priority for listener rule, must be unique per alb"
  type        = number
}
