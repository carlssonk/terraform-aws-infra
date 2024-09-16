variable "apps" {
  description = "App configurations"
  type = map(object({
    root_domain = string
    cloudflare_ruleset_rules = list(object({
      action = string
      action_parameters = object({
        ssl = string
      })
      expression  = string
      description = string
    }))
  }))
}
