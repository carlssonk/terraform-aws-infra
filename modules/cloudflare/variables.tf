variable "apps" {
  description = "App configurations. cloudflare properties: ssl_mode"
  type        = any
}

variable "environment" {
  description = "Environment name"
  type        = string
}
