variable "apps" {
  description = "App configurations. cloudflare properties: ssl_mode"
  type        = any
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  sensitive   = true
  type        = string
}
