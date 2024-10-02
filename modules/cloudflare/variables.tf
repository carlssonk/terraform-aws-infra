variable "apps" {
  description = "App configurations. cloudflare properties: ssl_mode"
  type        = any
}

variable "environments" {
  description = "All environments that uses cloudflare"
  type        = list(string)
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  sensitive   = true
  type        = string
}
