locals {
  root_domains = {
    carlssonk_com = "carlssonk.com"
  }

  env_subdomain_prefx = var.environment == "prod" ? "" : "${var.environment}."

  s3-websites = {
    portfolio = {
      app_name         = "Portfolio"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = var.environment == "prod" ? "www" : var.environment
      github_repo_name = "carlssonk/website"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    fps = {
      app_name         = "FirstPersonShooter"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "${local.env_subdomain_prefx}fps"
      github_repo_name = "carlssonk/fps"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
    terraform = {
      app_name         = "TerraformDiagram"
      root_domain      = local.root_domains.carlssonk_com
      subdomain        = "${local.env_subdomain_prefx}terraform"
      github_repo_name = "carlssonk/terraform-diagram"
      cloudflare = {
        ssl_mode = "flexible"
      }
    }
  }

  fargate-services = {
    blackjack = {
      app_name                = "Blackjack"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "${local.env_subdomain_prefx}blackjack"
      github_repo_name        = "carlssonk/Blackjack-Game-Multiplayer"
      container_port          = 8080
      use_stickiness          = true
      assign_public_ip        = true
      fargate_spot_percentage = var.fargate_spot_percentage
    }
    flagracer = {
      app_name                = "FlagRacer"
      root_domain             = local.root_domains.carlssonk_com
      subdomain               = "${local.env_subdomain_prefx}flagracer"
      github_repo_name        = "carlssonk/flagracer"
      container_port          = 8080
      use_stickiness          = true
      assign_public_ip        = true
      fargate_spot_percentage = var.fargate_spot_percentage
    }
  }
}
