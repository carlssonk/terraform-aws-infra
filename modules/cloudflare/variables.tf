variable "root_domain" {
  description = "The root domain name to route to the S3 bucket"
  type        = string
}

variable "dns_records" {
  description = "List of DNS records to create"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "zone_settings" {
  description = "Settings for the Cloudflare zone"
  type = object({
    websockets = string
    ssl        = string
  })
  default = {
    websockets = "on"
    ssl        = "flexible"
  }
}
