variable "app_name" {
  description = "Name of application"
  type        = string
}

variable "port" {
  description = "Should match container port"
  type        = number
}

variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "listener_arn" {
  description = "ARN of alb listener"
  type        = string
}
