variable "apps" {
  description = "App configurations. cloudflare properties: ssl_mode"
  type        = any
}

variable "environments" {
  description = "All environments that uses cloudflare"
  type        = list(string)
}
