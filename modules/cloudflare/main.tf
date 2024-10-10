terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

locals {
  apps_grouped_by_root_domain = {
    for root_domain in distinct(values(var.apps)[*].root_domain) :
    root_domain => [
      for app_config in var.apps : app_config
      if app_config.root_domain == root_domain
    ]
  }

  ruleset_rules = {
    for root_domain, apps in local.apps_grouped_by_root_domain : root_domain => flatten([
      for app in apps :
      can(app.cloudflare.ssl_mode) ? [{
        action = "set_config"
        action_parameters = {
          ssl = app.cloudflare.ssl_mode
        }
        expression = app.subdomain == "www" ? (
          format(
            "(http.host eq \"%s\" or http.host eq \"%s.%s\" or %s)",
            app.root_domain,
            app.subdomain,
            app.root_domain,
            join(" or ", [for env in var.environments :
              format("http.host eq \"%s.%s\"", env, app.root_domain)
              if env != "prod"
            ])
          )
          ) : join(" or ", [for env in var.environments :
            env == "prod" ?
            format("http.host eq \"%s.%s\"", app.subdomain, app.root_domain) :
            format("http.host eq \"%s-%s.%s\"", app.subdomain, env, app.root_domain)
        ])
        description = "Cloudflare rules for ${app.app_name}"
      }] : []
    ])
  }
}

data "cloudflare_zone" "domain" {
  for_each = local.apps_grouped_by_root_domain
  name     = each.key
}

resource "cloudflare_zone_settings_override" "this" {
  for_each = local.apps_grouped_by_root_domain
  zone_id  = data.cloudflare_zone.domain[each.key].id

  settings {
    ssl              = "full"
    always_use_https = "on"
  }
}

resource "cloudflare_ruleset" "this" {
  for_each    = local.apps_grouped_by_root_domain
  zone_id     = data.cloudflare_zone.domain[each.key].id
  name        = "Dynamic Main Ruleset"
  description = "Dynamic ruleset for managing app settings"
  kind        = "zone"
  phase       = "http_config_settings"

  dynamic "rules" {
    for_each = local.ruleset_rules[each.key]
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
