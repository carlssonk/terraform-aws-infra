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
      for _, app_config in var.apps : app_config
      if app_config.root_domain == root_domain
    ]
  }

  ruleset_rules = {
    for root_domain, apps in local.apps_grouped_by_root_domain : root_domain => flatten([
      for app in apps : flatten([
        try(app.cloudflare.ssl_mode, null) != null ? [{
          action = "set_config"
          action_parameters = {
            ssl = app.cloudflare.ssl_mode
          }
          expression  = app.subdomain == "www" ? "(http.host eq \"${app.root_domain}\" or http.host eq \"${app.subdomain}.${app.root_domain}\")" : "(http.host eq \"${app.subdomain}.${app.root_domain}\")"
          description = "Cloudflare rules for ${app.app_name} (${terraform.workspace})"
        }] : []
      ])
    ])
  }
}

data "cloudflare_zone" "domain" {
  for_each = local.apps_grouped_by_root_domain
  name     = each.key
}

// Resource can only be created once globally across all environments
# resource "cloudflare_zone_settings_override" "this" {
#   for_each = local.apps_grouped_by_root_domain
#   zone_id  = data.cloudflare_zone.domain[each.key].id

#   settings {
#     ssl              = "full"
#     always_use_https = "on"
#   }
# }

resource "null_resource" "cloudflare_zone_settings_override" {
  for_each = local.apps_grouped_by_root_domain

  triggers = {
    cloudflare_api_token = var.cloudflare_api_token
    zone_id              = data.cloudflare_zone.domain[each.key].id
    ssl                  = "full"
    always_use_https     = "on"
  }

  provisioner "local-exec" {
    command = "${path.module}/cloudflare_zone_settings_override.sh"
    environment = {
      CLOUDFLARE_API_TOKEN = self.triggers.cloudflare_api_token
      ZONE_ID              = self.triggers.zone_id
      SSL                  = self.triggers.ssl
      ALWAYS_USE_HTTPS     = self.triggers.always_use_https
    }
  }
}

// Resource can only be created once globally across all environments
# resource "cloudflare_ruleset" "this" {
#   for_each    = local.apps_grouped_by_root_domain
#   zone_id     = data.cloudflare_zone.domain[each.key].id
#   name        = "Dynamic Main Ruleset"
#   description = "Dynamic ruleset for managing app settings"
#   kind        = "zone"
#   phase       = "http_config_settings"

#   dynamic "rules" {
#     for_each = local.ruleset_rules[each.key]
#     content {
#       action = rules.value.action

#       dynamic "action_parameters" {
#         for_each = rules.value.action_parameters.ssl != null ? [rules.value.action_parameters.ssl] : []
#         content {
#           ssl = action_parameters.value
#         }
#       }

#       expression  = rules.value.expression
#       description = rules.value.description
#     }
#   }
# }

resource "null_resource" "cloudflare_ruleset" {
  for_each = local.apps_grouped_by_root_domain

  triggers = {
    cloudflare_api_token = var.cloudflare_api_token
    zone_id              = data.cloudflare_zone.domain[each.key].id
    kind                 = "zone"
    phase                = "http_config_settings"
    ruleset_rules        = jsonencode(local.ruleset_rules[each.key])
  }

  provisioner "local-exec" {
    command = "${path.module}/cloudflare_ruleset.sh"
    environment = {
      CLOUDFLARE_API_TOKEN = self.triggers.cloudflare_api_token
      ZONE_ID              = self.triggers.zone_id
      KIND                 = self.triggers.kind
      PHASE                = self.triggers.phase
      RULESET_RULES        = self.triggers.ruleset_rules
    }
  }
}
