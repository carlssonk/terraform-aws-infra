variable "apps" {
  description = "App configurations. cloudflare properties: ssl_mode"
  type        = any
}

variable "environments" {
  description = "List of environments that are active"
  type        = list(string)
}
