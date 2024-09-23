variable "apps" {
  description = "App configurations"
  type = map(object({
    root_domain = optional(string)
    ruleset_rules = optional(list(object({
      action = optional(string)
      action_parameters = optional(object({
        ssl = optional(string)
      }))
      expression  = optional(string)
      description = optional(string)
    })))
  }))
}
