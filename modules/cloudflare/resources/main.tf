terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

locals {
  // Group apps by root_domain
  apps_grouped = {
    for root_domain in distinct(values(var.apps)[*].root_domain) :
    root_domain => [
      for _, app_config in var.apps : app_config
      if app_config.root_domain == root_domain
    ]
  }
}

data "cloudflare_zone" "domain" {
  for_each = local.apps_grouped
  name     = each.key
}

resource "cloudflare_zone_settings_override" "this" {
  for_each = local.apps_grouped
  zone_id  = data.cloudflare_zone.domain[each.key].id

  settings {
    ssl              = "full"
    always_use_https = "on"
  }
}

resource "cloudflare_ruleset" "this" {
  for_each    = local.apps_grouped
  zone_id     = data.cloudflare_zone.domain[each.key].id
  name        = "Dynamic Main Ruleset"
  description = "Dynamic ruleset for managing app settings"
  kind        = "zone"
  phase       = "http_config_settings"

  dynamic "rules" {
    for_each = flatten([for _, value in local.apps_grouped[each.key] : value.ruleset_rules])
    content {
      action = rules.value.action

      dynamic "action_parameters" {
        for_each = rules.value.action_parameters.ssl != null ? [rules.value.action_parameters.ssl] : []
        content {
          ssl = action_parameters.value
        }
      }

      expression  = rules.value.expression
      description = rules.value.description
    }
  }
}
