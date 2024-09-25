variable "apps" {
  description = "App configurations"
  type        = map(object)
}

variable "environment" {
  description = "Environment name"
  type        = string
}
