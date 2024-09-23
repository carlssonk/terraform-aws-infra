variable "apps" {
  description = "App configurations"
  type = map(object({
    root_domain = optional(string)
    cloudflare_ruleset_rules = optional(list(object({
      action = optional(string)
      action_parameters = optional(object({
        ssl = optional(string)
      }))
      expression  = optional(string)
      description = optional(string)
    })))
    alb_listener_rule_priority = optional(number)
  }))
}
