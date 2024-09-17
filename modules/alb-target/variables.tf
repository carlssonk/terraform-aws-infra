variable "app_name" {
  description = "Name of application"
  type        = string
}

variable "container_port" {
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

variable "listener_rule_priority" {
  description = "Specify load balancer priority"
  type        = number
}

variable "host_header" {
  description = "Domain name"
  type        = string
}

variable "use_stickiness" {
  description = "Tells load balancer to route to the same target group (Needed for stateful applications eg. Sessions or Websockets)"
  type        = string
}
