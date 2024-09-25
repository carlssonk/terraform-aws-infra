variable "apps" {
  description = "App configurations. cloudflare properties: ssl_mode"
  type        = map(any)
}

variable "environment" {
  description = "Environment name"
  type        = string
}
