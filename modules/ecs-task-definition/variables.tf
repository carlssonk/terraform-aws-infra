variable "task_name" {
  description = "Name of ECS Task Definition"
  type        = string
}

variable "cpu" {
  description = "CPU limit"
  type        = number
}

variable "memory" {
  description = "Memory limit"
  type        = number
}

variable "container_definitions" {
  description = "Define Docker container json encoded"
  type        = string
}
