variable "cluster_name" {
  description = "Name of ECS Cluster"
  type        = string
}

variable "service_name" {
  description = "Name of ECS Service"
  type        = string
}

variable "task_definition" {
  description = "Name of ECS Task Definition"
  type        = string
}
