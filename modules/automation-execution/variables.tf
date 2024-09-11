variable "cluster_name" {
  description = "Name of ECS Cluster"
  type        = string
}

variable "service_name" {
  description = "Name of ECS Service"
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of ECS Task Definition"
  type        = string
}

variable "task_id" {
  description = "ID of ECS Task Definition"
  type        = string
}
