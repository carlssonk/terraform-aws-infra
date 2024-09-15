variable "app_name" {
  description = "Name of app"
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
