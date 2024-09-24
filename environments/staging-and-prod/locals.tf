locals {
  root_domain = "carlssonk.com"
  env_prefix  = var.environment == "prod" ? "" : "${var.environment}."

  apps = {
    portfolio = {
      app_name         = "Portfolio"
      root_domain      = local.root_domain
      subdomain        = "www"
      github_repo_name = "carlssonk/website"
    }
    fps = {
      app_name         = "FirstPersonShooter"
      root_domain      = local.root_domain
      subdomain        = "fps"
      github_repo_name = "carlssonk/fps"
    }
    terraform = {
      app_name         = "TerraformDiagram"
      root_domain      = local.root_domain
      subdomain        = "terraform"
      github_repo_name = "carlssonk/terraform-diagram"
    }
  }

  # cloudflare_configuration = {
  #   for app, config in local.apps : app => {
  #     root_domain = local.base_domain
  #     ruleset_rules = [
  #       for subdomain in config.subdomains : {
  #         action = "set_config"
  #         action_parameters = {
  #           ssl = "flexible"
  #         }
  #         expression  = "(http.host eq \"${local.env_prefix}${subdomain}${subdomain == "" ? "" : "."}${local.base_domain}\")"
  #         description = "Cloudflare rules for ${app}"
  #       }
  #     ]
  #   }
  # }
}
