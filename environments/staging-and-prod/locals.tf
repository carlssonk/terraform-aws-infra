locals {
  root_domain         = "carlssonk.com"
  env_subdomain_prefx = var.environment == "prod" ? "" : "${var.environment}."

  apps = {
    portfolio = {
      app_name         = "Portfolio"
      root_domain      = local.root_domain
      subdomain        = var.environment == "prod" ? "www" : var.environment
      github_repo_name = "carlssonk/website"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    fps = {
      app_name         = "FirstPersonShooter"
      root_domain      = local.root_domain
      subdomain        = "${local.env_subdomain_prefx}fps"
      github_repo_name = "carlssonk/fps"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    terraform = {
      app_name         = "TerraformDiagram"
      root_domain      = local.root_domain
      subdomain        = "${local.env_subdomain_prefx}terraform"
      github_repo_name = "carlssonk/terraform-diagram"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
  }
}
