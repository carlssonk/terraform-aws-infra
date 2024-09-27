variable "root_domain" {
  description = "The root domain name for zone id lookup"
  type        = string
}

variable "dns_records" {
  description = "List of DNS records to create"
  type = map({
    name    = string
    value   = string
    type    = optional(string, "CNAME")
    ttl     = optional(number, 1)
    proxied = optional(bool, true)
  })
}
